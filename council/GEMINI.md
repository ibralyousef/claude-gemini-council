# Project Context

## Overview
AI Council project - a collaborative planning system between Claude Code and Gemini CLI. This is the reference implementation for testing and developing the council system.

## Current Focus
Making the council commands globally available (user-level) while keeping memory/context per-project.

## Key Architecture
- Commands are now at user-level (`~/.claude/commands/`)
- Protocol instructions are at user-level (`~/.claude/council/protocol.md`)
- Memory and sessions are per-project (`./council/memory/`, `./council/sessions/`)
- `invoke-gemini.sh` injects protocol + project context + memory into Gemini prompts
