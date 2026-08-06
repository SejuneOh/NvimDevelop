---
name: obsidian
description: Manage notes in the Obsidian vault — create, update, and query by type and title.
tools: Read, Write, Edit, Bash, Glob, Grep
---

# Obsidian Note Manager

Manages notes in the Obsidian vault at `$CLAUDE_OBSIDIAN_VAULT` (set per machine, e.g. `~/Document/note/Obsidian_claude`).

## Argument Parsing

First argument → `TYPE`, remaining → `TITLE`. Arguments use `--` prefix.

- `/obsidian --help` → TYPE=help
- `/obsidian --inbox title` → TYPE=inbox, TITLE=title
- `/obsidian --project` → TYPE=project (title derived from branch)
- `/obsidian --decision title` → TYPE=decision, TITLE=title
- `/obsidian --knowledge title` → TYPE=knowledge, TITLE=title
- `/obsidian --reference title` → TYPE=reference, TITLE=title
- `/obsidian --status` → TYPE=status
- `/obsidian --archive` → TYPE=archive (current branch)
- `/obsidian --archive slug` → TYPE=archive, TARGET=slug
- `/obsidian --archive --list` → TYPE=archive-list
- `/obsidian --pull` → TYPE=pull (sync vault from remote `main`)
- `/obsidian --push` → TYPE=push (sync local vault changes to remote `main`)

No arguments defaults to `help`. Arguments without `--` are treated the same (backward compat).

## Constants

```
VAULT="${CLAUDE_OBSIDIAN_VAULT:?CLAUDE_OBSIDIAN_VAULT not set}"
TODAY=$(date +%Y-%m-%d)
```

## Actions by TYPE

### help

Print the following and exit:

```
Obsidian Note Manager

Usage: /obsidian --<type> [title]

Types:
  --help                 Show this help
  --inbox <title>        Create a quick note in inbox/
  --project              Create/update project note from current branch
  --decision <title>     Create a decision record in decisions/
  --knowledge <title>    Create a knowledge note in knowledge/
  --reference <title>    Create a reference note in references/
  --status               Show current branch project note and recent inbox
  --archive [slug]       Archive a project note (current branch if no slug)
  --archive --list       List archivable project notes
  --pull                 Pull vault main branch from remote (stash/pop local changes)
  --push                 Commit and push local vault changes to remote main

Examples:
  /obsidian --inbox meeting notes
  /obsidian --project
  /obsidian --decision API versioning strategy
  /obsidian --knowledge EF Core migration patterns
  /obsidian --reference Azure Search official docs
  /obsidian --status
  /obsidian --archive
  /obsidian --archive myrepo-main
  /obsidian --archive --list
  /obsidian --pull
  /obsidian --push
```

### inbox

1. Filename: `{VAULT}/inbox/{TODAY}-{title-slug}.md` (kebab-case, keep Korean chars as-is)
2. If file exists, append. Otherwise create.
3. New file frontmatter:

```markdown
---
tags:
  - type/inbox
created: {TODAY}
---

# {TITLE}

{Content from conversation context or current context summary}
```

4. Print file path after create/update.

### project

1. Extract repo name, branch and issue number:

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
BRANCH=$(git branch --show-current)
ISSUE=$(echo "$BRANCH" | grep -oE '[0-9]{4,}' | head -1)
SLUG="${REPO}-$(echo "$BRANCH" | tr '/' '-')"
```

2. Filename: `{VAULT}/projects/{SLUG}.md` (e.g. `myrepo-main.md`, `myrepo-feature-123-foo.md`)
3. If file exists:
   - Update `## Current State` with current status
   - Update `## Key Files` with recently changed files
   - Set `updated` frontmatter to today
4. If file does not exist, create with template:

```markdown
---
tags:
  - status/active
  - project/{SLUG}
branch: {BRANCH}
issue: {ISSUE}
created: {TODAY}
updated: {TODAY}
description: 
---

# {BRANCH}

## Context
<!-- Derived from GitHub issue #{ISSUE} -->

## Current State
<!-- Current progress based on git diff/log -->

## Key Files
<!-- Recently changed key files -->

## Open Questions

## Related
```

5. If issue number exists, fetch issue title from GitHub and populate Context.
6. Print file path and summary after create/update.

### decision

1. Filename: `{VAULT}/decisions/{TODAY}-{title-slug}.md`
2. If file exists, update. Otherwise create.
3. Template:

```markdown
---
tags:
  - type/decision
  - project/
  - topic/
created: {TODAY}
status: proposed
description: {TITLE}
---

# {TITLE}

## Problem

## Options Considered

### Option A
- **Pros**: 
- **Cons**: 

### Option B
- **Pros**: 
- **Cons**: 

## Decision

## Consequences

## Related
```

4. Fill sections from conversation context if available.
5. Print file path after create.

### knowledge

1. Filename: `{VAULT}/knowledge/{title-slug}.md`
2. If file exists, update. Otherwise create.
3. Template:

```markdown
---
tags:
  - type/knowledge
  - topic/
created: {TODAY}
updated: {TODAY}
description: {TITLE}
---

# {TITLE}

## Summary

## Details

## Examples

## Gotchas

## Related
```

4. Fill sections from conversation context if available.
5. Print file path after create/update.

### reference

1. Filename: `{VAULT}/references/{title-slug}.md`
2. If file exists, update. Otherwise create.
3. Template:

```markdown
---
tags:
  - type/reference
  - topic/
created: {TODAY}
url: 
description: {TITLE}
---

# {TITLE}

## Source

## Key Points

## Related
```

4. Print file path after create/update.

### archive

Archives a project note when its branch is merged or deprecated.

#### Argument handling

- No argument → derive slug from current repo+branch (same as `--project`)
- `--list` → jump to **archive-list** flow
- Otherwise → treat argument as target slug

#### archive flow

1. Resolve target file:

```bash
# If no argument:
REPO=$(basename "$(git rev-parse --show-toplevel)")
SLUG="${REPO}-$(git branch --show-current | tr '/' '-')"
# If argument provided:
SLUG="{argument}"
```

2. Check file exists:

```bash
test -f "{VAULT}/projects/${SLUG}.md" && echo "exists" || echo "not found"
```

3. If not found → print error and list available project notes, then exit.

4. Read the file. Update frontmatter:
   - Change `status/active` → `status/archived`
   - Add `archived: {TODAY}`
   - Add `resolution: merged` (or `deprecated`/`abandoned` — infer from context, default `merged`)

5. Append archive summary section at the end:

```markdown
## Archive Summary

- **Archived:** {TODAY}
- **Resolution:** {resolution}
- **Final state:** {brief summary of Current State section}
```

6. Ensure archive directory exists, then move file:

```bash
mkdir -p "{VAULT}/projects/archive"
mv "{VAULT}/projects/${SLUG}.md" "{VAULT}/projects/archive/${SLUG}.md"
```

7. Print result: file path and summary in Korean.

#### archive-list flow

1. List all project notes:

```bash
ls "{VAULT}/projects/"*.md 2>/dev/null
```

2. For each note, extract the slug and check if the branch still exists:

```bash
git branch -a --list "*{branch-from-frontmatter}*"
```

3. Print table:

```
Project Notes:
  [active]  myrepo-main              — branch exists (remote/local)
  [stale]   myrepo-fix-...           — branch not found
  [stale]   myrepo-old-feature       — branch not found
```

4. Notes marked `[stale]` are candidates for archiving. Suggest: `"/obsidian --archive {slug}"` for each.

### status

Shows vault overview at a glance.

#### 1. Project Note

1. Extract slug from current repo and git branch.
2. **Use `Bash` `test -f` to check file existence**, then `Read` to read.
   ```bash
   REPO=$(basename "$(git rev-parse --show-toplevel)")
   SLUG="${REPO}-$(git branch --show-current | tr '/' '-')"
   test -f "${VAULT}/projects/${SLUG}.md" && echo "exists" || echo "not found"
   ```
3. If not found: "No project note for current branch. Create one with `/obsidian --project`."
4. If found, summarize: branch, issue, status, Current State, Open Questions.

#### 2. Recent Inbox

1. List recent inbox notes (max 5) using `ls -t`.
   ```bash
   ls -t "${VAULT}/inbox/" 2>/dev/null | head -5
   ```
2. If empty: "Inbox is empty."
3. If notes exist, list filename and first `#` heading.

#### 3. Output Format

```
Project: {BRANCH}
  - Status: {status tag}
  - Issue: #{ISSUE}
  - Current State summary
  - Open Questions

Inbox (recent 5):
  - {filename} - {title}
  - ...
```

### pull

Sync the Obsidian vault from remote — pull the latest `main` branch.

**Purpose:** keep the local Obsidian vault up-to-date with the remote.

**Conflict policy:**
- Pull/merge conflict (committed local vs remote): take **remote** (`git checkout --theirs`).
- Stash-pop conflict (just-pulled remote vs stashed local work): take **stash** (`git checkout --theirs` — in stash-pop, `theirs` is the stash).
- For every conflict, capture and report the **discarded** side's full content so nothing is silently lost.

#### Steps

1. Change to vault directory and verify it is a git repository:

```bash
cd "{VAULT}" || { echo "Vault not found: {VAULT}"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Vault is not a git repository: {VAULT}"; exit 1; }
```

2. Ensure we are on `main` (record the original branch so we can restore it on failure):

```bash
ORIG_BRANCH=$(git branch --show-current)
git checkout main
```

3. Detect uncommitted changes (tracked + untracked):

```bash
DIRTY=0
if [ -n "$(git status --porcelain)" ]; then DIRTY=1; fi
```

4. If dirty, stash with a labeled entry (include untracked files):

```bash
TIME=$(date +%H%M%S)
STASH_LABEL="obsidian-pull-{TODAY}-${TIME}"
git stash push -u -m "$STASH_LABEL"
STASHED=1
```

5. Fetch and pull `main` from remote (merge, not rebase — so conflicts surface as merge conflicts):

```bash
git fetch origin main
git pull --no-rebase origin main
```

6. If pull produced merge conflicts (`git ls-files -u` non-empty):
   - For each conflicted file: read the local ("ours") version and store its full content for the report, then resolve to remote.

   ```bash
   PULL_CONFLICTS=$(git diff --name-only --diff-filter=U)
   for f in $PULL_CONFLICTS; do
     # Capture discarded ("ours" = local committed) content via the index stage 2:
     git show ":2:$f" > "/tmp/obsidian-pull-conflict-${f//\//_}.local" 2>/dev/null || true
     git checkout --theirs -- "$f"
     git add -- "$f"
   done
   git commit --no-edit
   ```

7. If a stash was created in step 4, pop it:

```bash
git stash pop
```

8. If `git stash pop` produced conflicts:
   - For each conflicted file: read the just-pulled ("ours") version and store its full content for the report, then resolve to the stash side.

   ```bash
   POP_CONFLICTS=$(git diff --name-only --diff-filter=U)
   for f in $POP_CONFLICTS; do
     # Capture discarded ("ours" = remote post-pull) content via the index stage 2:
     git show ":2:$f" > "/tmp/obsidian-pop-conflict-${f//\//_}.remote" 2>/dev/null || true
     git checkout --theirs -- "$f"
     git add -- "$f"
   done
   ```

   `git stash pop` consumes the stash entry even on conflict — verify with `git stash list` and only call `git stash drop` if the entry still appears.

9. If a stash was created AND pop succeeded with no conflicts, the entry was already dropped by `pop`. If pop left the stash on the stack (rare — only with `--keep-index`), drop it explicitly:

```bash
if git stash list | grep -q "$STASH_LABEL"; then
  git stash drop "stash@{0}"
fi
```

10. Restore the original branch if it differed from `main`:

```bash
if [ "$ORIG_BRANCH" != "main" ] && [ -n "$ORIG_BRANCH" ]; then
  git checkout "$ORIG_BRANCH"
fi
```

11. Report in Korean. Always include:
    - Pulled commit summary: `git log --oneline ORIG_HEAD..HEAD` (commits brought in).
    - Whether a stash was created and whether it was popped cleanly.
    - For each conflict (pull or stash-pop): file path, which side was kept, and the **full content of the discarded side** so the user can manually merge if needed.

   Example output shape:

   ```
   ✅ Obsidian vault 최신화 완료
   - 받아온 커밋: 3개
     • abc1234 docs: ...
     • def5678 fix: ...
   - 스택: 1개 stash → pop 적용 후 자동 drop

   ⚠️ 충돌 처리 (1건)
   - inbox/2026-05-29-meeting.md (pull merge)
     → 리모트 채택. 버려진 로컬 버전 전체:
     <discarded content>
   ```

### push

Sync local Obsidian vault changes to remote — auto-commit any pending work, integrate remote, then push `main`.

**Purpose:** publish local Obsidian vault changes to the remote.

**Conflict policy:** identical to `--pull`.
- Pull/merge conflict (during the pre-push integrate): take **remote** (`git checkout --theirs`).
- Stash-pop conflict (rare — only used if uncommittable state remains): take **stash** (`git checkout --theirs`).
- Report the full content of the discarded side for every conflict.

#### Steps

1. Change to vault directory and verify it is a git repository (same as `--pull` step 1).

2. Ensure we are on `main` (record original branch for restoration):

```bash
ORIG_BRANCH=$(git branch --show-current)
git checkout main
```

3. Detect uncommitted changes:

```bash
DIRTY=0
if [ -n "$(git status --porcelain)" ]; then DIRTY=1; fi
```

4. If dirty, stage everything and create an auto-commit:

```bash
git add -A
git commit -m "obsidian: sync {TODAY}"
```

5. Fetch remote and check divergence:

```bash
git fetch origin main
LOCAL=$(git rev-parse main)
REMOTE=$(git rev-parse origin/main)
BASE=$(git merge-base main origin/main)
```

6. Decide based on divergence:
   - `$LOCAL` == `$REMOTE` → nothing to push, skip to step 9 with "already up-to-date".
   - `$BASE` == `$REMOTE` and `$LOCAL` != `$REMOTE` → local is ahead, fast-forward push possible. Skip to step 8.
   - `$BASE` == `$LOCAL` and `$LOCAL` != `$REMOTE` → remote is ahead, must integrate before push (step 7).
   - Otherwise (diverged) → must integrate before push (step 7).

7. Integrate remote via merge (so conflicts surface as merge conflicts, not rebase):

```bash
git pull --no-rebase origin main
```

   If merge produced conflicts (`git ls-files -u` non-empty):
   - For each conflicted file: capture local ("ours") content for the report, then resolve to remote.

   ```bash
   MERGE_CONFLICTS=$(git diff --name-only --diff-filter=U)
   for f in $MERGE_CONFLICTS; do
     git show ":2:$f" > "/tmp/obsidian-push-conflict-${f//\//_}.local" 2>/dev/null || true
     git checkout --theirs -- "$f"
     git add -- "$f"
   done
   git commit --no-edit
   ```

8. Push `main` to remote:

```bash
git push origin main
```

9. Restore the original branch if it differed from `main`:

```bash
if [ "$ORIG_BRANCH" != "main" ] && [ -n "$ORIG_BRANCH" ]; then
  git checkout "$ORIG_BRANCH"
fi
```

10. Report in Korean. Always include:
    - Pushed commit summary: `git log --oneline origin/main@{1}..origin/main` (commits sent to remote).
    - Whether an auto-commit was created (and its message).
    - Whether a merge with remote was needed.
    - For each conflict during the integrate step: file path, which side was kept, and the **full content of the discarded side**.

   Example output shape:

   ```
   ✅ Obsidian vault remote 동기화 완료
   - 자동 커밋: "obsidian: sync 2026-05-29" (변경 12 파일)
   - 리모트 통합: 머지 1건 (3 commits)
   - 푸시 완료: 4 commits → origin/main

   ⚠️ 충돌 처리 (0건)
   ```

## Common Rules

- **File existence check**: On WSL, `Glob` may fail to find files on `/mnt/c/...` paths. **Always use `Bash` `test -f`** for existence checks. Use `Read` to read files.
  ```bash
  test -f "{VAULT}/projects/{SLUG}.md" && echo "exists" || echo "not found"
  ```
- **Directory listing**: Use `Bash` `ls` instead of `Glob`.
- **Filename slug**: Spaces → `-`, remove special chars, lowercase. Keep Korean chars as-is.
- **Wikilinks**: Link related notes as `[[note-name]]`.
- **Tags**: Use `status/`, `project/`, `type/`, `topic/` prefixes.
- **Output**: Print file path and brief summary in Korean after every action.
- **Protect existing content**: Never overwrite. On update, preserve existing content and modify only changed sections.
