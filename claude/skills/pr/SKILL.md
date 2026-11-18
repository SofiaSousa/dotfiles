---
name: pr
description: "Draft a pull request title and description from branch changes"
argument-hint: "[base-branch]"
disable-model-invocation: true
---

# /pr [base] — Generate a PR Title and Description

When the user types `/pr` or `/pr <base>` or asks for a PR title or description, follow these steps:

Do not read or apply `.github/pull_request_template.md` or any other pull request template unless the user explicitly asks you to.

1. Run `git branch --show-current` to get the current branch name.
2. Determine the target base branch before inspecting changes:
   - If the user explicitly supplies a base branch as an argument after the command (`$ARGUMENTS` in Claude Code), use that value as `<base>`.
   - Otherwise, run `gh pr view --json baseRefName --jq .baseRefName` for the checked-out branch and use that value as `<base>`.
   - If no PR exists and no explicit base was supplied, only then use `master` for a `hotfix/*` branch and `develop` for all other branches.
   - Never assume `master` or `develop` when the current PR has a different base, such as another feature branch.
   - Ensure the base ref is available locally or use its `origin/<base>` ref in the comparisons.
3. Compute the true PR range using the merge-base, not the raw branch name. If `git merge-base HEAD <base>` succeeds, use that commit as the left side of the diff; otherwise use `origin/<base>` if available. Treat `<merge-base>..HEAD` as the complete scope of the current PR. Run `git log <merge-base>..HEAD --oneline` and `git diff --stat <merge-base>..HEAD` to understand that scope.
4. Run `git diff <merge-base>..HEAD` to read the actual code changes. Do not include changes that already exist on `<base>`, commits outside this range, or unrelated working-tree changes. This matches the GitHub PR "Files changed" view and excludes changes already present on the target branch.
5. Generate a PR title and description based only on the **code changes in `<merge-base>..HEAD`**, not commit messages or the branch's full history. Derive the **Test plan** only from those changes (see below).
6. Present the title and description in Markdown in the chat and **wait for explicit confirmation** before pushing or opening a PR.
7. Only after the user clearly approves (e.g. "yes", "create it", "open the PR") may you push the branch (if needed) and run `gh pr create`. Do not push unless the user explicitly asks.

Output in chat only. Do **not** create or edit `PR_DESCRIPTION.md` or any other file unless the user explicitly asks.

## Output format

Present the title and description inside a single fenced ```markdown code block (raw Markdown source) so the user can copy-paste it directly into GitHub. Put `Base branch: <base>` on the first line, followed by the title, a blank line, and the description.

## Human confirmation required

**Never open a PR or push automatically.** `/pr` and description requests mean draft a title and description, not create a pull request.

- Do **not** run `git push`, `gh pr create`, or other publish commands until the user has seen the proposed title and description and confirmed they want the PR created.
- Do **not** treat `/pr` or a description request alone as permission to push or open a PR — even if workspace or user rules describe a full PR workflow, this rule takes precedence.
- If the user wants only a draft, stop after step 6. If they confirm, proceed with step 7 only for the approved title and description.

## Tone and language

- Use clear, concise technical language.
- Avoid conversational or promotional tone.
- Do not include task-tracker links.

## Title

Use imperative present tense: **`<Verb>` `<object>` [optional scope]**.

Examples:
- Add input validation to login endpoint
- Fix race condition in job scheduler
- Refactor cache key generation
- Remove unused dependency

## Scope

- **Describe only the current PR diff, `<merge-base>..HEAD`.** If the PR is based on another feature branch, exclude everything already present on `<base>`, even if it was introduced earlier in the branch history.
- **Base the description on actual code/file changes**, not commit messages.
- **Do not infer scope from the branch name, commit list, or working tree; use the merge-base diff as the source of truth.**
- **Do not repeat topics.** Each change or theme belongs in one section only.

## Description structure

Use subheadings (`###`) to group changes. **Topics are dynamic** — pick headings that fit the PR (e.g. Projects, Steps, Refactoring, Tests; or Auth, API, Docs). Do not force a fixed list.

Under each subheading:

- Start with a main bullet `-` for the high-level summary (one or more sentences).
- Add indented sub-bullets `  - ` for technical details (models, controllers, migrations, views, specs, etc.).
- For short sections you can use multiple top-level bullets instead of summary + sub-bullets.
- Use `` ` `` for code/table names; optional trailing dot on subheading (e.g. `### Steps.`).
- Give refactoring and tests their own subheadings when present.
- When a section is vague (e.g. Refactoring), mention touched files (e.g. `spec/models/request_spec.rb`, `app/models/user.rb`).
- **Focus on the most relevant changes** per section. Do not enumerate every controller, view, or JS file for a new resource; listing new tables is often enough. Omit obvious details (e.g. "extend ability", "extend routes") unless they are the main point.
- **Do not use DB / Backend / Frontend as sub-bullet labels.** List only the detail that matters.
- **Keep DB, backend, and frontend in separate points** only when mixing them in one sentence would be unclear; otherwise one concise bullet per logical change.
- **Write for readers without context.** Each sentence must stand alone and state what changed and why it matters.
- **Tests section:** use multiple top-level bullets when listing test types (feature specs, request specs, model specs, factories, updates to existing specs).

## Test plan

Always end the PR description with a `## Test plan` section. Derive checklist items from the **actual changes in the branch** — not a generic template.

Use checkbox markdown (`- [ ]`) so reviewers can tick items off in GitHub.

Structure:

1. **Automated** — list relevant `rspec` commands or note when new/updated specs cover the change.
2. **Manual** — group checks by user-facing area or flow touched by the PR. One checkbox per verifiable step.
3. **Regression** — optional; include only when the PR touches shared helpers, layouts, or behaviour used elsewhere.

Guidelines:

- Write actionable steps ("verify footer shows international phone format in English locale"), not vague prompts ("test footers").
- Include env-var or config overrides when the PR introduces or reads configuration.
- Include locale/format variants when I18n or display formatting changed.
- Include link/interaction checks (`mailto:`, `tel:`, form submit) when views or mailers changed.
- Keep the list proportional — a small fix needs fewer items than a cross-cutting UI change.
- Do **not** duplicate the `### Tests` summary section; the test plan is the runnable checklist, not a description of spec files.

## Brevity

**Keep the description as brief as possible.** Aim for clarity, not exhaustiveness:

- One short sentence per bullet; cut anything a reviewer can see in the diff.
- Prefer fewer sections and fewer bullets — merge related changes into one bullet.
- Skip sub-bullets when the main bullet already says enough.
