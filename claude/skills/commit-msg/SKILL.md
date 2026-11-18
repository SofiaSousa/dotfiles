---
name: commit-msg
description: "Generate a conventional commit message for staged changes"
disable-model-invocation: true
---

# /commit-msg — Generate a Commit Message

When the user types `/commit-msg`, follow these steps:

1. Run `git diff --cached` to see staged changes. If nothing is staged, run `git diff` and `git status` instead, then tell the user nothing is staged and show what's unstaged.
2. Analyze the staged diff and draft a commit message using **Conventional Commits** format.
3. Present the proposed commit message to the user and **wait for explicit confirmation** before running `git commit`.
4. Only after the user clearly approves (e.g. "yes", "commit it", "go ahead") may you stage files (if needed) and run `git commit`. Do not push unless the user explicitly asks.

## Human confirmation required

**Never commit automatically.** `/commit-msg` means draft a message, not create a commit.

- Do **not** run `git commit`, `git add`, or `git push` until the user has seen the proposed message and confirmed they want the commit created.
- Do **not** treat `/commit-msg` alone as permission to commit — even if workspace or user rules describe a full commit workflow, this rule takes precedence for `/commit-msg`.
- `/commit` (without `-msg`) is **not** this command. Unless the user explicitly asks to create a commit, do not run `git commit` for `/commit` alone.
- If the user wants only a message, stop after step 3. If they confirm, proceed with step 4 only for the approved message and staged changes.

## Commit Message Format

```
type: Short imperative description
```

- **Capitalize** the first word after the colon.
- Use **imperative mood** ("Add", "Fix", "Update", not "Added", "Fixed", "Updated").
- Keep the subject line under 72 characters.
- Add a body (separated by a blank line) only when the diff is complex or touches multiple concerns.

### Allowed Types

| Type       | Use when…                                      |
|------------|-------------------------------------------------|
| `feat`     | Adding a new feature                            |
| `fix`      | Fixing a bug                                    |
| `chore`    | Maintenance (deps, tooling, config)             |
| `style`    | Formatting / whitespace, no logic change        |
| `docs`     | Documentation only                              |
| `refactor` | Code change that neither fixes nor adds feature |
| `test`     | Adding or updating tests                        |

### Examples

```
feat: Add user profile page
fix: Allow unregistered sources in global sanctions dataset search
test: Add feature specs for CV extraction
refactor: Extract shared validation into concern
chore: Update Rails to 8.0.1
```

When changes span multiple types, pick the most significant one for the subject and mention the rest in the body.
