# Claude Code Agent Teams

> Coordinate multiple Claude Code instances working together as a team, with shared tasks, inter-agent messaging, and centralized management.

> [!WARNING]
> Agent teams are **experimental** and disabled by default. Enable them by adding `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to your `settings.json` or environment. Agent teams have [known limitations](https://code.claude.com/docs/en/agent-teams.md#limitations) around session resumption, task coordination, and shutdown behavior.

## Overview

Claude Code Agent Teams lets you coordinate multiple Claude Code instances on complex tasks. One session acts as the **team lead**, coordinating work and synthesizing results. Teammates work independently — each in their own context window — and communicate directly with each other.

Unlike subagents (which run within a single session and report only to the main agent), you can interact with individual teammates directly without going through the lead.

> [!NOTE]
> Agent teams require Claude Code v2.1.32 or later. Check your version with `claude --version`.

## Quick Start

### 1. Enable Agent Teams

Agent teams are already enabled in this repository via `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set it in your shell:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude
```

### 2. Start Your First Team

Open Claude Code in this directory and describe what you want. Claude creates the team, spawns teammates, and coordinates work:

```text
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.
```

### 3. Interact with Teammates

- **Shift+Down** — cycle through teammates (in-process mode)
- **Type a message** — send it to the current teammate
- **Ctrl+T** — toggle the shared task list
- **Escape** — interrupt the teammate's current turn

## Display Modes

| Mode | Description | Requirement |
|------|-------------|-------------|
| `in-process` | All teammates run in your main terminal | Any terminal |
| `tmux` | Each teammate gets its own split pane | tmux or iTerm2 |
| `auto` (default) | Split panes if in tmux, otherwise in-process | — |

To force in-process mode for a single session:

```bash
claude --teammate-mode in-process
```

## Architecture

```
Team Lead (main session)
    │
    ├── Shared Task List (~/.claude/tasks/{team-name}/)
    │       ├── task-001.json  [pending]
    │       ├── task-002.json  [in_progress → teammate-A]
    │       └── task-003.json  [completed]
    │
    ├── Mailbox (inter-agent messaging)
    │
    ├── Teammate A (own context window)
    ├── Teammate B (own context window)
    └── Teammate C (own context window)
```

Team config is stored at `~/.claude/teams/{team-name}/config.json` with each teammate's name, agent ID, and agent type.

## Example Prompts

See [`scripts/team-prompts.md`](scripts/team-prompts.md) for ready-to-use templates. Quick examples:

### Parallel Code Review

```text
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

### Competing Hypothesis Debugging

```text
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

### Parallel Feature Implementation

```text
Create a team with 3 teammates to implement the user notification system:
- One teammate handles the backend API endpoints in src/api/
- One teammate builds the frontend notification UI in src/components/
- One teammate writes integration tests in tests/
Use Sonnet for each teammate and require plan approval before making changes.
```

## Best Practices

### Team Size
Start with **3–5 teammates** for most workflows. Having 5–6 tasks per teammate keeps everyone productive without excessive context switching.

### Task Design
| Size | Problem |
|------|---------|
| Too small | Coordination overhead exceeds the benefit |
| Too large | Risk of wasted effort without check-ins |
| Just right | Self-contained unit with a clear deliverable |

### Avoid File Conflicts
Two teammates editing the same file leads to overwrites. Break work so each teammate owns a different set of files.

### Give Enough Context
Teammates load project context (CLAUDE.md, MCP servers, skills) automatically, but they **don't inherit the lead's conversation history**. Include task-specific details in the spawn prompt.

### Monitor and Steer
Check in on teammates' progress periodically. Letting a team run unattended too long increases the risk of wasted effort.

## Quality Gates with Hooks

Use hooks to enforce rules when teammates finish or tasks complete:

- **`TeammateIdle`** — runs when a teammate is about to go idle; exit with code `2` to keep them working
- **`TaskCompleted`** — runs when a task is marked complete; exit with code `2` to prevent completion

Example hook in `settings.json`:

```json
{
  "hooks": {
    "TeammateIdle": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "scripts/check-teammate-quality.sh"
          }
        ]
      }
    ]
  }
}
```

## Agent Teams vs. Subagents

| | Subagents | Agent Teams |
|---|---|---|
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion |
| **Token cost** | Lower | Higher (scales with team size) |

Use subagents when you need quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate independently.

## Limitations

- **No session resumption** with in-process teammates (`/resume` and `/rewind` don't restore teammates)
- **Task status can lag** — teammates may fail to mark tasks complete
- **Shutdown can be slow** — teammates finish their current request before exiting
- **One team per session** — clean up before starting a new team
- **No nested teams** — teammates can't spawn their own teams
- **Lead is fixed** — the session that creates the team is lead for its lifetime
- **Split panes require tmux or iTerm2** — not supported in VS Code's integrated terminal, Windows Terminal, or Ghostty

## Troubleshooting

**Teammates not appearing**
- In in-process mode, press Shift+Down to cycle through active teammates
- Ensure your task is complex enough to warrant a team
- If using split panes, verify `tmux` is in your PATH: `which tmux`

**Too many permission prompts**
- Pre-approve common operations in your permission settings before spawning teammates

**Lead shuts down early**
- Tell it: `Wait for your teammates to complete their tasks before proceeding`

**Orphaned tmux sessions**
```bash
tmux ls
tmux kill-session -t <session-name>
```

## Documentation

Full documentation: [code.claude.com/docs/en/agent-teams](https://code.claude.com/docs/en/agent-teams.md)
