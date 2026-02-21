---
trigger: always_on
---

# Single Task Workflow

Follow this workflow when implementing a new feature, bug fix, or any task.

## 1. Gather Requirements

- Read the task description/ticket/card carefully
- Identify requirements, acceptance criteria, and constraints
- If ambiguous, ask the user for clarification
- If Figma designs are referenced, review them (use Figma MCP if available)

## 2. Create Branch

```bash
# Format: type/AERO-TICKET-description
git checkout -b feature/AERO-123-add-search-feature
# or if no ticket: git checkout -b feature/add-search-feature
```

**Never work in `main` or `dev` branch.**

## 3. Analyze & Plan

- Explore the codebase to understand relevant architecture
- Identify files that need to be modified/created
- Consider Flutter/GetX patterns, testing requirements
- Create a step-by-step plan in `./docs/task-AERO-123-plan.md`

**Ask for user review and approval before implementing.**

## 4. Get Approval

- Present the plan to the user
- Incorporate feedback if suggested
- **Wait for explicit permission to start implementation**

## 5. Implement

- After approval, create task tracking in your context
- Implement step-by-step following the plan
- Follow Flutter/GetX development rules
- Write tests as you go (unit, widget, integration)
- Run `flutter analyze` and `dart format .` regularly

## 6. Test & Verify

```bash
flutter test
flutter test integration_test/
flutter analyze
```

Ensure all tests pass and code is clean.

## 7. Commit & Push

```bash
git add .
git commit -m "AERO-123: Add search functionality"
git push origin feature/AERO-123-add-search-feature
```

Follow git guidelines for commit messages.

## 8. Complete Task

- Move ticket/card to "In Review" status/column
- Summarize changes to the user
- Include: what was done, files changed, tests added, any notes

## Workflow Summary

```
Gather → Branch → Plan → Approve → Implement → Test → Commit → Complete
```

**Do not skip the planning and approval steps.**
