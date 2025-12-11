#!/usr/bin/env python3
"""
Council Session Visualizer

Creates professional, deterministic visualizations of AI Council session files.
Supports PDF, PNG, and SVG output formats.

Usage:
    python council_viz.py <session.md> [--format pdf|png|svg] [--output <path>]
"""

import argparse
import hashlib
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# Third-party imports (will be checked at runtime)
try:
    from jinja2 import Template
except ImportError:
    Template = None

try:
    from weasyprint import HTML, CSS
except ImportError:
    HTML = CSS = None

try:
    import svgwrite
except ImportError:
    svgwrite = None


# ============================================================================
# Data Structures
# ============================================================================

@dataclass
class RoundEntry:
    """A single round in the council session."""
    round_number: int
    claude_response: str
    gemini_response: str
    gemini_prose: str = ""
    gemini_status: Optional[str] = None
    gemini_agreement: Optional[str] = None
    gemini_confidence: Optional[float] = None
    gemini_key_points: list[str] = field(default_factory=list)
    gemini_action_items: list[str] = field(default_factory=list)


@dataclass
class CouncilSession:
    """Parsed council session data."""
    timestamp: str
    topic: str
    stance: str
    participants: list[str]
    mode: str
    rounds: list[RoundEntry] = field(default_factory=list)
    consensus_reached: Optional[bool] = None
    agreed_position: Optional[str] = None
    action_items: list[str] = field(default_factory=list)
    raw_content: str = ""


# ============================================================================
# Color Palette (Professional Monochrome + Accents)
# ============================================================================

class ColorPalette:
    """Professional monochrome palette with subtle accent colors."""

    # Text colors
    TEXT_PRIMARY = "#1F2937"        # Gray-800
    TEXT_SECONDARY = "#6B7280"      # Gray-500
    TEXT_MUTED = "#9CA3AF"          # Gray-400

    # Background colors
    PAGE_BG = "#FFFFFF"             # White
    CARD_BG = "#FFFFFF"             # White
    SECTION_BG = "#F9FAFB"          # Gray-50

    # Header (dark, professional)
    HEADER_BG = "#1F2937"           # Gray-800
    HEADER_TEXT = "#FFFFFF"         # White

    # Accent colors (subtle, used only for borders/lines)
    CLAUDE_ACCENT = "#3B82F6"       # Blue-500
    GEMINI_ACCENT = "#059669"       # Emerald-600

    # Status colors (muted)
    STATUS_RESOLVED_BG = "#ECFDF5"  # Emerald-50
    STATUS_RESOLVED_TEXT = "#065F46" # Emerald-800
    STATUS_CONTINUE_BG = "#FEF3C7"  # Amber-100
    STATUS_CONTINUE_TEXT = "#92400E" # Amber-800
    STATUS_DEADLOCK_BG = "#FEE2E2"  # Red-100
    STATUS_DEADLOCK_TEXT = "#991B1B" # Red-800

    # Consensus box
    CONSENSUS_BG = "#F9FAFB"        # Gray-50
    CONSENSUS_BORDER = "#D1D5DB"    # Gray-300

    # Borders
    BORDER_LIGHT = "#E5E7EB"        # Gray-200
    BORDER_MEDIUM = "#D1D5DB"       # Gray-300


# ============================================================================
# Markdown Parser
# ============================================================================

def parse_gemini_response(gemini_text: str) -> dict:
    """Parse Gemini's response to extract prose and structured data."""
    result = {
        "prose": "",
        "status": None,
        "agreement": None,
        "confidence": None,
        "key_points": [],
        "action_items": []
    }

    # Split prose from COUNCIL_RESPONSE block
    council_block_match = re.search(
        r"---COUNCIL_RESPONSE---(.*?)---END_COUNCIL_RESPONSE---",
        gemini_text,
        re.DOTALL
    )

    if council_block_match:
        # Everything before the block is prose
        block_start = gemini_text.find("---COUNCIL_RESPONSE---")
        result["prose"] = gemini_text[:block_start].strip()

        block_content = council_block_match.group(1)

        # Parse structured fields
        status_match = re.search(r"STATUS:\s*(\w+)", block_content)
        if status_match:
            result["status"] = status_match.group(1)

        agreement_match = re.search(r"AGREEMENT:\s*(\w+)", block_content)
        if agreement_match:
            result["agreement"] = agreement_match.group(1)

        confidence_match = re.search(r"CONFIDENCE:\s*([\d.]+)", block_content)
        if confidence_match:
            result["confidence"] = float(confidence_match.group(1))

        # Parse KEY_POINTS
        key_points_match = re.search(
            r"KEY_POINTS:\s*(.*?)(?=ACTION_ITEMS:|QUESTIONS_FOR|MISSING_CONTEXT:|$)",
            block_content,
            re.DOTALL
        )
        if key_points_match:
            points_text = key_points_match.group(1)
            points = re.findall(r"^-\s*(.+)$", points_text, re.MULTILINE)
            result["key_points"] = [p.strip() for p in points if p.strip()]

        # Parse ACTION_ITEMS
        action_items_match = re.search(
            r"ACTION_ITEMS:\s*(.*?)(?=QUESTIONS_FOR|$)",
            block_content,
            re.DOTALL
        )
        if action_items_match:
            items_text = action_items_match.group(1)
            items = re.findall(r"^-\s*\[.\]\s*(.+)$", items_text, re.MULTILINE)
            result["action_items"] = [i.strip() for i in items if i.strip()]
    else:
        # No structured block, entire text is prose
        result["prose"] = gemini_text.strip()

        # Still try to extract status if present in raw text
        status_match = re.search(r"STATUS:\s*(\w+)", gemini_text)
        if status_match:
            result["status"] = status_match.group(1)

    return result


def parse_session_file(filepath: Path) -> CouncilSession:
    """Parse a council session markdown file into structured data."""
    content = filepath.read_text(encoding="utf-8")

    session = CouncilSession(
        timestamp="",
        topic="",
        stance="",
        participants=[],
        mode="",
        raw_content=content
    )

    # Parse header metadata
    timestamp_match = re.search(r"# Council.*Session:\s*(\d{4}-\d{2}-\d{2}-\d{6})", content)
    if timestamp_match:
        session.timestamp = timestamp_match.group(1)

    topic_match = re.search(r"## Topic:\s*(.+)", content)
    if topic_match:
        session.topic = topic_match.group(1).strip()

    stance_match = re.search(r"## Stance:\s*(\w+)", content)
    if stance_match:
        session.stance = stance_match.group(1).strip()

    participants_match = re.search(r"## Participants:\s*(.+)", content)
    if participants_match:
        session.participants = [p.strip() for p in participants_match.group(1).split(",")]

    mode_match = re.search(r"## Mode:\s*(.+)", content)
    if mode_match:
        session.mode = mode_match.group(1).strip()

    # Parse rounds
    round_pattern = re.compile(
        r"### Round (\d+)\s*\n\s*\*\*CLAUDE:\*\*\s*(.*?)\*\*GEMINI:\*\*\s*(.*?)(?=### Round|\n---\n|## CONSENSUS|$)",
        re.DOTALL
    )

    for match in round_pattern.finditer(content):
        round_num = int(match.group(1))
        claude_text = match.group(2).strip()
        gemini_text = match.group(3).strip()

        # Parse Gemini's structured response
        gemini_data = parse_gemini_response(gemini_text)

        entry = RoundEntry(
            round_number=round_num,
            claude_response=claude_text,
            gemini_response=gemini_text,
            gemini_prose=gemini_data["prose"],
            gemini_status=gemini_data["status"],
            gemini_agreement=gemini_data["agreement"],
            gemini_confidence=gemini_data["confidence"],
            gemini_key_points=gemini_data["key_points"],
            gemini_action_items=gemini_data["action_items"]
        )
        session.rounds.append(entry)

    # Parse consensus result
    consensus_match = re.search(r"\*\*Consensus Reached:\*\*\s*(Yes|No)", content)
    if consensus_match:
        session.consensus_reached = consensus_match.group(1) == "Yes"

    position_match = re.search(r"### Agreed Position\s*\n(.*?)(?=###|$)", content, re.DOTALL)
    if position_match:
        session.agreed_position = position_match.group(1).strip()

    # Parse action items
    action_section = re.search(r"### Action Items\s*\n(.*?)(?=###|$)", content, re.DOTALL)
    if action_section:
        items = re.findall(r"^\d+\.\s*(.+)$", action_section.group(1), re.MULTILINE)
        session.action_items = items

    return session


def get_session_hash(session: CouncilSession) -> str:
    """Generate deterministic hash from session content."""
    content = f"{session.timestamp}{session.topic}{session.stance}"
    return hashlib.sha256(content.encode()).hexdigest()


# ============================================================================
# HTML Template (Professional Design)
# ============================================================================

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: {{ colors.PAGE_BG }};
            color: {{ colors.TEXT_PRIMARY }};
            line-height: 1.6;
            padding: 40px;
            font-size: 14px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
        }

        /* Header - Dark, Professional */
        .header {
            background: {{ colors.HEADER_BG }};
            color: {{ colors.HEADER_TEXT }};
            padding: 24px 28px;
            border-radius: 8px;
            margin-bottom: 32px;
        }

        .header h1 {
            font-size: 18px;
            margin-bottom: 8px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }

        .header .topic {
            font-size: 14px;
            opacity: 0.85;
            margin-bottom: 16px;
            line-height: 1.5;
        }

        .meta-row {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            font-size: 12px;
            opacity: 0.7;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .meta-label {
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: 500;
        }

        /* Round Section */
        .round {
            margin-bottom: 28px;
        }

        .round-header {
            font-size: 11px;
            font-weight: 600;
            color: {{ colors.TEXT_MUTED }};
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }

        /* Response Cards */
        .response-card {
            background: {{ colors.CARD_BG }};
            border: 1px solid {{ colors.BORDER_LIGHT }};
            border-radius: 6px;
            padding: 16px 20px;
            margin-bottom: 12px;
            border-left: 3px solid;
        }

        .response-card.claude {
            border-left-color: {{ colors.CLAUDE_ACCENT }};
        }

        .response-card.gemini {
            border-left-color: {{ colors.GEMINI_ACCENT }};
        }

        .speaker {
            font-weight: 600;
            font-size: 13px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: {{ colors.TEXT_PRIMARY }};
        }

        .speaker-icon {
            width: 22px;
            height: 22px;
            border-radius: 4px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
            color: white;
        }

        .speaker-icon.claude { background: {{ colors.CLAUDE_ACCENT }}; }
        .speaker-icon.gemini { background: {{ colors.GEMINI_ACCENT }}; }

        .response-content {
            font-size: 13px;
            color: {{ colors.TEXT_PRIMARY }};
            line-height: 1.7;
        }

        .response-content p {
            margin-bottom: 12px;
        }

        /* Gemini Structured Data */
        .gemini-structured {
            margin-top: 16px;
            padding-top: 16px;
            border-top: 1px solid {{ colors.BORDER_LIGHT }};
        }

        .structured-section {
            margin-bottom: 12px;
        }

        .structured-section h4 {
            font-size: 11px;
            font-weight: 600;
            color: {{ colors.TEXT_MUTED }};
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 6px;
        }

        .key-points-list {
            list-style: none;
            padding: 0;
        }

        .key-points-list li {
            padding: 4px 0 4px 16px;
            position: relative;
            font-size: 12px;
            color: {{ colors.TEXT_SECONDARY }};
        }

        .key-points-list li::before {
            content: "\\2022";
            position: absolute;
            left: 0;
            color: {{ colors.TEXT_MUTED }};
        }

        .action-items-list {
            list-style: none;
            padding: 0;
        }

        .action-items-list li {
            padding: 4px 0 4px 20px;
            position: relative;
            font-size: 12px;
            color: {{ colors.TEXT_SECONDARY }};
        }

        .action-items-list li::before {
            content: "\\2610";
            position: absolute;
            left: 0;
            color: {{ colors.GEMINI_ACCENT }};
        }

        /* Status Badge */
        .status-row {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 12px;
        }

        .status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        .status-badge.resolved {
            background: {{ colors.STATUS_RESOLVED_BG }};
            color: {{ colors.STATUS_RESOLVED_TEXT }};
        }
        .status-badge.continue {
            background: {{ colors.STATUS_CONTINUE_BG }};
            color: {{ colors.STATUS_CONTINUE_TEXT }};
        }
        .status-badge.deadlock {
            background: {{ colors.STATUS_DEADLOCK_BG }};
            color: {{ colors.STATUS_DEADLOCK_TEXT }};
        }

        .confidence {
            font-size: 11px;
            color: {{ colors.TEXT_MUTED }};
        }

        /* Consensus Box */
        .consensus-box {
            background: {{ colors.CONSENSUS_BG }};
            border: 1px solid {{ colors.CONSENSUS_BORDER }};
            border-radius: 6px;
            padding: 20px 24px;
            margin-top: 32px;
        }

        .consensus-box h2 {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            color: {{ colors.TEXT_PRIMARY }};
        }

        .consensus-box .agreed-position {
            font-size: 13px;
            color: {{ colors.TEXT_SECONDARY }};
            line-height: 1.7;
        }

        /* Final Action Items */
        .final-action-items {
            margin-top: 16px;
            padding-top: 16px;
            border-top: 1px solid {{ colors.BORDER_LIGHT }};
        }

        .final-action-items h3 {
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 8px;
            color: {{ colors.TEXT_PRIMARY }};
        }

        .final-action-items ul {
            list-style: none;
            padding: 0;
        }

        .final-action-items li {
            padding: 6px 0 6px 20px;
            position: relative;
            font-size: 12px;
            color: {{ colors.TEXT_SECONDARY }};
        }

        .final-action-items li::before {
            content: "\\2713";
            position: absolute;
            left: 0;
            color: {{ colors.GEMINI_ACCENT }};
            font-weight: bold;
        }

        /* Footer */
        .footer {
            margin-top: 32px;
            text-align: center;
            font-size: 11px;
            color: {{ colors.TEXT_MUTED }};
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>AI Council Session</h1>
            <div class="topic">{{ session.topic }}</div>
            <div class="meta-row">
                <div class="meta-item">
                    <span class="meta-label">Date:</span>
                    <span>{{ session.timestamp }}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Stance:</span>
                    <span>{{ session.stance }}</span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Rounds:</span>
                    <span>{{ session.rounds|length }}</span>
                </div>
                {% if session.consensus_reached %}
                <div class="meta-item">
                    <span class="meta-label">Result:</span>
                    <span>Consensus</span>
                </div>
                {% endif %}
            </div>
        </div>

        {% for round in session.rounds %}
        <div class="round">
            <div class="round-header">Round {{ round.round_number }}</div>

            <div class="response-card claude">
                <div class="speaker">
                    <span class="speaker-icon claude">C</span>
                    Claude (Chair)
                </div>
                <div class="response-content">{{ round.claude_response | format_response }}</div>
            </div>

            <div class="response-card gemini">
                <div class="speaker">
                    <span class="speaker-icon gemini">G</span>
                    Gemini
                </div>
                <div class="response-content">{{ round.gemini_prose | format_response if round.gemini_prose else "(No prose response)" }}</div>

                {% if round.gemini_key_points or round.gemini_action_items %}
                <div class="gemini-structured">
                    {% if round.gemini_key_points %}
                    <div class="structured-section">
                        <h4>Key Points</h4>
                        <ul class="key-points-list">
                            {% for point in round.gemini_key_points %}
                            <li>{{ point }}</li>
                            {% endfor %}
                        </ul>
                    </div>
                    {% endif %}

                    {% if round.gemini_action_items %}
                    <div class="structured-section">
                        <h4>Action Items</h4>
                        <ul class="action-items-list">
                            {% for item in round.gemini_action_items %}
                            <li>{{ item }}</li>
                            {% endfor %}
                        </ul>
                    </div>
                    {% endif %}
                </div>
                {% endif %}

                {% if round.gemini_status %}
                <div class="status-row">
                    <span class="status-badge {{ round.gemini_status | lower }}">{{ round.gemini_status }}</span>
                    {% if round.gemini_confidence %}
                    <span class="confidence">Confidence: {{ "%.0f" | format(round.gemini_confidence * 100) }}%</span>
                    {% endif %}
                </div>
                {% endif %}
            </div>
        </div>
        {% endfor %}

        {% if session.consensus_reached is not none %}
        <div class="consensus-box">
            <h2>
                {% if session.consensus_reached %}
                Consensus Reached
                {% else %}
                No Consensus
                {% endif %}
            </h2>

            {% if session.agreed_position %}
            <div class="agreed-position">{{ session.agreed_position | format_response }}</div>
            {% endif %}

            {% if session.action_items %}
            <div class="final-action-items">
                <h3>Action Items</h3>
                <ul>
                    {% for item in session.action_items %}
                    <li>{{ item }}</li>
                    {% endfor %}
                </ul>
            </div>
            {% endif %}
        </div>
        {% endif %}

        <div class="footer">
            Council Visualizer
        </div>
    </div>
</body>
</html>
"""


def format_response(text: str, max_length: int = 1500) -> str:
    """Format response text for display."""
    if not text:
        return ""

    # Truncate if too long
    if len(text) > max_length:
        truncated = text[:max_length]
        last_newline = truncated.rfind("\n\n")
        if last_newline > max_length * 0.6:
            truncated = truncated[:last_newline]
        text = truncated + "\n\n[...]"

    return text


# ============================================================================
# Renderers
# ============================================================================

def render_html(session: CouncilSession) -> str:
    """Render session to HTML string."""
    if Template is None:
        raise ImportError("Jinja2 is required. Install with: pip install jinja2")

    from jinja2 import Environment

    env = Environment()
    env.filters["format_response"] = format_response
    template = env.from_string(HTML_TEMPLATE)

    return template.render(
        session=session,
        colors=ColorPalette,
        session_hash=get_session_hash(session)
    )


def render_pdf(session: CouncilSession, output_path: Path) -> None:
    """Render session to PDF file."""
    if HTML is None:
        raise ImportError("WeasyPrint is required. Install with: pip install weasyprint")

    html_content = render_html(session)
    html_doc = HTML(string=html_content)
    html_doc.write_pdf(output_path)


def render_png(session: CouncilSession, output_path: Path) -> None:
    """Render session to PNG image via SVG conversion."""
    try:
        import cairosvg
    except ImportError:
        raise ImportError(
            "PNG rendering requires cairosvg. Install with: pip install cairosvg\n"
            "Alternative: Use --format svg and convert manually, or use --format pdf"
        )

    import tempfile
    with tempfile.NamedTemporaryFile(suffix=".svg", delete=False) as tmp:
        tmp_svg = Path(tmp.name)

    render_svg(session, tmp_svg)
    cairosvg.svg2png(url=str(tmp_svg), write_to=str(output_path), scale=2.0)
    tmp_svg.unlink()


def render_svg(session: CouncilSession, output_path: Path) -> None:
    """Render session to SVG file using svgwrite."""
    if svgwrite is None:
        raise ImportError("svgwrite is required. Install with: pip install svgwrite")

    # SVG dimensions
    width = 800
    padding = 40
    content_width = width - (padding * 2)

    # Calculate dynamic height
    header_height = 100
    round_height = 280
    consensus_height = 150
    total_height = header_height + (len(session.rounds) * round_height) + consensus_height + (padding * 2)

    dwg = svgwrite.Drawing(str(output_path), size=(width, total_height))

    # Background
    dwg.add(dwg.rect(insert=(0, 0), size=(width, total_height), fill=ColorPalette.PAGE_BG))

    y_offset = padding

    # Header (dark)
    dwg.add(dwg.rect(
        insert=(padding, y_offset),
        size=(content_width, 80),
        rx=8, ry=8,
        fill=ColorPalette.HEADER_BG
    ))

    dwg.add(dwg.text(
        "AI Council Session",
        insert=(padding + 20, y_offset + 28),
        fill=ColorPalette.HEADER_TEXT,
        font_size="16px",
        font_weight="600",
        font_family="sans-serif"
    ))

    topic_text = session.topic[:65] + "..." if len(session.topic) > 65 else session.topic
    dwg.add(dwg.text(
        topic_text,
        insert=(padding + 20, y_offset + 48),
        fill=ColorPalette.HEADER_TEXT,
        font_size="11px",
        font_family="sans-serif",
        opacity=0.85
    ))

    # Meta info
    meta_text = f"{session.timestamp}  |  Stance: {session.stance}  |  {len(session.rounds)} Rounds"
    dwg.add(dwg.text(
        meta_text,
        insert=(padding + 20, y_offset + 68),
        fill=ColorPalette.HEADER_TEXT,
        font_size="10px",
        font_family="sans-serif",
        opacity=0.6
    ))

    y_offset += 100

    # Rounds
    for round_entry in session.rounds:
        # Round header
        dwg.add(dwg.text(
            f"ROUND {round_entry.round_number}",
            insert=(padding, y_offset + 12),
            fill=ColorPalette.TEXT_MUTED,
            font_size="10px",
            font_weight="600",
            font_family="sans-serif"
        ))
        y_offset += 24

        # Claude card
        dwg.add(dwg.rect(
            insert=(padding, y_offset),
            size=(content_width, 90),
            rx=6, ry=6,
            fill=ColorPalette.CARD_BG,
            stroke=ColorPalette.BORDER_LIGHT,
            stroke_width=1
        ))
        dwg.add(dwg.rect(
            insert=(padding, y_offset),
            size=(3, 90),
            fill=ColorPalette.CLAUDE_ACCENT
        ))

        # Claude icon
        dwg.add(dwg.rect(
            insert=(padding + 14, y_offset + 12),
            size=(20, 20),
            rx=3, ry=3,
            fill=ColorPalette.CLAUDE_ACCENT
        ))
        dwg.add(dwg.text(
            "C",
            insert=(padding + 20, y_offset + 26),
            fill="white",
            font_size="11px",
            font_weight="700",
            font_family="sans-serif"
        ))

        dwg.add(dwg.text(
            "Claude (Chair)",
            insert=(padding + 42, y_offset + 26),
            fill=ColorPalette.TEXT_PRIMARY,
            font_size="12px",
            font_weight="600",
            font_family="sans-serif"
        ))

        # Claude response preview
        preview = format_response(round_entry.claude_response, 120).split("\n")[0]
        preview = preview[:85] + "..." if len(preview) > 85 else preview
        dwg.add(dwg.text(
            preview,
            insert=(padding + 14, y_offset + 52),
            fill=ColorPalette.TEXT_SECONDARY,
            font_size="10px",
            font_family="sans-serif"
        ))

        y_offset += 100

        # Gemini card
        dwg.add(dwg.rect(
            insert=(padding, y_offset),
            size=(content_width, 90),
            rx=6, ry=6,
            fill=ColorPalette.CARD_BG,
            stroke=ColorPalette.BORDER_LIGHT,
            stroke_width=1
        ))
        dwg.add(dwg.rect(
            insert=(padding, y_offset),
            size=(3, 90),
            fill=ColorPalette.GEMINI_ACCENT
        ))

        # Gemini icon
        dwg.add(dwg.rect(
            insert=(padding + 14, y_offset + 12),
            size=(20, 20),
            rx=3, ry=3,
            fill=ColorPalette.GEMINI_ACCENT
        ))
        dwg.add(dwg.text(
            "G",
            insert=(padding + 20, y_offset + 26),
            fill="white",
            font_size="11px",
            font_weight="700",
            font_family="sans-serif"
        ))

        dwg.add(dwg.text(
            "Gemini",
            insert=(padding + 42, y_offset + 26),
            fill=ColorPalette.TEXT_PRIMARY,
            font_size="12px",
            font_weight="600",
            font_family="sans-serif"
        ))

        # Gemini prose preview
        prose = round_entry.gemini_prose if round_entry.gemini_prose else "(Structured response)"
        prose_preview = prose[:85] + "..." if len(prose) > 85 else prose
        dwg.add(dwg.text(
            prose_preview,
            insert=(padding + 14, y_offset + 52),
            fill=ColorPalette.TEXT_SECONDARY,
            font_size="10px",
            font_family="sans-serif"
        ))

        # Status badge
        if round_entry.gemini_status:
            status_colors = {
                "RESOLVED": (ColorPalette.STATUS_RESOLVED_BG, ColorPalette.STATUS_RESOLVED_TEXT),
                "CONTINUE": (ColorPalette.STATUS_CONTINUE_BG, ColorPalette.STATUS_CONTINUE_TEXT),
                "DEADLOCK": (ColorPalette.STATUS_DEADLOCK_BG, ColorPalette.STATUS_DEADLOCK_TEXT)
            }
            bg, fg = status_colors.get(round_entry.gemini_status, (ColorPalette.SECTION_BG, ColorPalette.TEXT_SECONDARY))

            dwg.add(dwg.rect(
                insert=(padding + 14, y_offset + 64),
                size=(70, 18),
                rx=3, ry=3,
                fill=bg
            ))
            dwg.add(dwg.text(
                round_entry.gemini_status,
                insert=(padding + 22, y_offset + 76),
                fill=fg,
                font_size="9px",
                font_weight="600",
                font_family="sans-serif"
            ))

        y_offset += 100

    # Consensus box
    if session.consensus_reached is not None:
        dwg.add(dwg.rect(
            insert=(padding, y_offset),
            size=(content_width, 80),
            rx=6, ry=6,
            fill=ColorPalette.CONSENSUS_BG,
            stroke=ColorPalette.CONSENSUS_BORDER,
            stroke_width=1
        ))

        title = "Consensus Reached" if session.consensus_reached else "No Consensus"
        dwg.add(dwg.text(
            title,
            insert=(padding + 20, y_offset + 28),
            fill=ColorPalette.TEXT_PRIMARY,
            font_size="13px",
            font_weight="600",
            font_family="sans-serif"
        ))

        if session.agreed_position:
            preview = session.agreed_position[:100] + "..." if len(session.agreed_position) > 100 else session.agreed_position
            dwg.add(dwg.text(
                preview,
                insert=(padding + 20, y_offset + 52),
                fill=ColorPalette.TEXT_SECONDARY,
                font_size="10px",
                font_family="sans-serif"
            ))

    dwg.save()


# ============================================================================
# Main Entry Point
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Generate professional visualizations of AI Council session files."
    )
    parser.add_argument("session_file", type=Path, help="Path to the council session markdown file")
    parser.add_argument(
        "--format", "-f",
        choices=["pdf", "png", "svg", "html"],
        default="pdf",
        help="Output format (default: pdf)"
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        help="Output file path (default: same as input with new extension)"
    )

    args = parser.parse_args()

    if not args.session_file.exists():
        print(f"Error: Session file not found: {args.session_file}", file=sys.stderr)
        sys.exit(1)

    # Parse session
    print(f"Parsing session file: {args.session_file}")
    session = parse_session_file(args.session_file)

    print(f"  Topic: {session.topic[:50]}...")
    print(f"  Rounds: {len(session.rounds)}")
    print(f"  Consensus: {session.consensus_reached}")

    # Determine output path
    if args.output:
        output_path = args.output
    else:
        output_path = args.session_file.with_suffix(f".{args.format}")

    # Render
    print(f"Rendering to {args.format.upper()}...")

    if args.format == "pdf":
        render_pdf(session, output_path)
    elif args.format == "png":
        render_png(session, output_path)
    elif args.format == "svg":
        render_svg(session, output_path)
    elif args.format == "html":
        html_content = render_html(session)
        output_path.write_text(html_content, encoding="utf-8")

    print(f"Output saved to: {output_path}")


if __name__ == "__main__":
    main()
