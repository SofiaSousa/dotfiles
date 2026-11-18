# dotfiles

Personal Claude Code skills, installed into every devcontainer.

## Setup

Add to your local VS Code user settings:

```json
"dotfiles.repository": "<your-github-user>/dotfiles",
"dotfiles.installCommand": "install.sh"
```

New or rebuilt devcontainers clone this repo and run `install.sh`, which links each folder in `claude/skills/` into `~/.claude/skills/`.

## Skills

- `/commit-msg`: Draft a conventional commit message for staged changes
- `/pr [base]`: Draft a PR title and description from branch changes

To add a skill, create `claude/skills/<name>/SKILL.md`.
