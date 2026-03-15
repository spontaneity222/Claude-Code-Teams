# Claude Code Agent Teams — Project Context

This repository demonstrates how to orchestrate multiple Claude Code sessions working as a coordinated team.

## Project Overview

Claude Code Agent Teams is an **experimental feature** that allows multiple Claude Code instances to work together on complex tasks. One session acts as the **team lead**, coordinating work and assigning tasks. **Teammates** work independently, each in their own context window, and communicate directly with each other.

## Key Concepts

- **Team Lead**: The main Claude Code session that creates the team, spawns teammates, and synthesizes results.
- **Teammates**: Separate Claude Code instances each working on assigned tasks.
- **Task List**: A shared list of work items stored at `~/.claude/tasks/{team-name}/`.
- **Mailbox**: A messaging system enabling direct inter-agent communication.

## When to Use Agent Teams

Best use cases:
1. **Research & Review** — Multiple teammates investigate different aspects simultaneously
2. **New Modules/Features** — Each teammate owns a separate piece without conflicts
3. **Debugging with Competing Hypotheses** — Teammates test different theories in parallel
4. **Cross-layer Coordination** — Frontend, backend, and tests owned by different teammates

## Agent Team vs. Subagents

| | Subagents | Agent Teams |
|---|---|---|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring collaboration |
| **Token cost** | Lower | Higher (scales with team size) |

## Enabling Agent Teams

Agent teams require `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. This is already configured in `.claude/settings.json`.

## Guidelines for All Teammates

- Read task descriptions carefully before starting
- Update task status promptly (pending → in_progress → completed)
- Message the lead when you finish your work or encounter blockers
- Avoid editing files that other teammates own — coordinate via the task list
- Keep each task self-contained with a clear deliverable
- When in doubt, message the lead rather than proceeding with assumptions

## Repository Structure

```
.
├── .claude/
│   └── settings.json        # Agent teams enabled, in-process mode
├── CLAUDE.md                # This file — project context for all teammates
├── README.md                # Project overview and usage guide
├── examples/
│   ├── parallel-review/     # Example: parallel PR code review
│   ├── competing-hypotheses/ # Example: debugging with rival theories
│   └── feature-parallel/    # Example: building a feature with parallel workstreams
└── scripts/
    └── team-prompts.md      # Ready-to-use team prompt templates
```
