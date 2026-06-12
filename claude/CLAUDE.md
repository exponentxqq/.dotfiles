# General Rules

## Debugging Strategy

When debugging, limit to 2-3 attempts per approach. If unresolved, pause and summarize what was tried and what remains unknown before continuing. Avoid repeating failed approaches across multiple iterations.

## Validate Assumptions Before Implementing

Before writing implementation code, verify assumptions against the actual codebase — field names, API endpoints, package names, method signatures, etc. Read the relevant source first rather than guessing.

## No Unnecessary Defensive Code

Implement exactly what is requested. Do not add fallback behavior, keep legacy parameters, or introduce backward-compatible shims unless explicitly asked. Remove what should be removed, no extra additions.

## Monorepo Command Discipline

In pnpm monorepos, confirm the current workspace/package before running build, test, or git commands. Always use the correct `--filter` or `--project` flag for the target package.

## Git Commits

不要在任何 commit message 中添加 `Co-Authored-By:` 签名行。
