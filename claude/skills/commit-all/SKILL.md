---
name: commit-all
description: Use when the user wants to batch commit pending changes across multiple repos, or asks to commit all work without specifying a single repo.
---

# commit-all

## Overview

Scan all known project directories for uncommitted changes and commit each repo with descriptive messages.

## When to Use

- User says "commit all", "提交所有", or wants to batch-commit across repos
- After a multi-repo implementation session with pending changes in several projects

## Steps

1. **Scan for uncommitted changes**

   Check these known project directories (adjust based on actual workspace):
   ```bash
   for dir in ~/develop/company/*/; do
     if [ -d "$dir/.git" ]; then
       status=$(git -C "$dir" status --porcelain 2>/dev/null)
       if [ -n "$status" ]; then
         echo "DIRTY: $dir"
       fi
     fi
   done
   ```

   If using pnpm workspaces, also check for nested repos:
   ```bash
   for dir in ~/develop/company/*/ ~/develop/personal/*/; do
     if [ -d "$dir/.git" ]; then
       status=$(git -C "$dir" status --porcelain 2>/dev/null)
       if [ -n "$status" ]; then
         echo "DIRTY: $dir"
       fi
     fi
   done
   ```

2. **For each dirty repo, review changes**

   a. Run `git status` and `git diff` (staged + unstaged) to understand the changes
   b. Run `git log --oneline -5` for recent commit style reference
   c. Generate a concise commit message following the repo's existing style
   d. **Show the user**: repo name, summary of changes, and proposed commit message

3. **Stage and commit**

   a. Stage relevant files (prefer specific file names over `git add -A`)
   b. Commit with the generated message
   c. Report result: "Committed <repo>: <message>"

4. **Summary**

   After all repos are processed, list:
   - Committed repos with their messages
   - Skipped repos (clean or user-rejected)
   - Any repos with issues

**Guardrails**

- Never commit `.env`, credentials, or secrets — warn the user if these appear staged
- Never push — this skill only creates local commits
- If a repo has merge conflicts, skip it and warn the user
- If the user rejects a commit message, ask for their preferred message
- Always prefer specific `git add <files>` over `git add -A` or `git add .`
