# self-healing: Automatic Bug Prevention System

A skill that detects issues from session context or user feedback, then automatically updates dependent rules, hooks, commands, skills, and memories so the issue won't happen again.

## Quick Start

```bash
/self-healing                    # Analyze recent session for issues
/self-healing "issue description"  # Fix a specific issue
```

## What It Does

When you encounter a bug or anti-pattern, instead of just fixing the symptom, `/self-healing` fixes the **system** so it won't happen again.

### Example: The Root Hygiene Report Problem

**Problem:** The `/root-directory-hygiene` skill created hygiene audit reports at root (defeating the cleanup's purpose)

**Without /self-healing:** Manual fixes needed in multiple places
1. Update SKILL.md with new rule documentation
2. Add rule to rule-catalog.md
3. Update root-allowlist.md
4. Update SKILL.md with anti-pattern examples
5. Commit separately or remember to include in next commit

**With /self-healing:**
```bash
/self-healing "root-directory-hygiene creates reports at root"

# Skill analyzes and shows:
# [1] SKILL.md — Add ROOT-HYGIENE-SELF-REF rule documentation
# [2] rule-catalog.md — Add new rule ID (HIGH severity)
# [3] root-allowlist.md — Forbid *HYGIENE*.md at root
# [4] SKILL.md — Document anti-pattern and safe practices

# User approves, skill applies all fixes and commits
```

**Result:** The skill now prevents this issue automatically. Memories are created so future instances remember the pattern.

## What Gets Updated

The skill can update:

- **Skills** — Add rules, improve descriptions, document anti-patterns
- **Rules** — Add new rule IDs, update catalogs and allowlists
- **Memories** — Create feedback/project/reference memories for future sessions
- **Hooks** — Configure pre-commit, post-write, pre-run hooks in settings.json
- **Settings** — Update permission levels, environment defaults
- **CLAUDE.md** — Document patterns and preventive practices
- **Commits** — Explain the fix and prevention strategy

## Safety Principles

✅ **Non-destructive** — Never deletes without reason  
✅ **Backward compatible** — New rules don't break existing workflows  
✅ **Explicit approval** — Shows changes before applying  
✅ **Reversible** — All changes committed to git  
✅ **Well-documented** — Commit messages explain rationale  
✅ **Idempotent** — Running twice on same issue is safe  

## When to Use

✅ **Use when:**
- You discover a bug that could recur
- A skill doesn't behave as expected
- You find an anti-pattern being repeated
- A rule is violated repeatedly
- A memory contradicts current reality

❌ **Don't use when:**
- It's a one-off mistake (just fix manually)
- The issue is in application code (fix the code)
- The issue requires significant refactoring (use /plan)
- You're unsure what the real issue is (debug first)

## Common Scenarios

### Skill Doesn't Trigger

```bash
/self-healing "deployment skill doesn't trigger on VPS keywords"
# Updates: skill description, creates memory, updates CLAUDE.md
```

### Anti-Pattern Discovered

```bash
/self-healing "skill creates pollution at root"
# Updates: adds rule, updates allowlist, documents pattern
```

### Memory Contradicts Code

```bash
/self-healing "memory says use old API but code changed"
# Updates: deletes/updates stale memory, explains in commit
```

### Repeated User Mistake

```bash
/self-healing "I keep forgetting to run migrations after pull"
# Adds: post-pull hook, creates feedback memory, documents in CLAUDE.md
```

## How It Works

1. **Detect** — Analyze session for errors, user feedback, or explicit issue
2. **Find** — Locate all affected components (skills, rules, memories, hooks)
3. **Propose** — Show specific changes needed for each component
4. **Approve** — User reviews and approves proposed fixes
5. **Apply** — Update all components and commit changes
6. **Verify** — Confirm changes prevent the issue from recurring
7. **Remember** — Create memories so pattern is remembered in future sessions

## Memory Integration

The skill creates memories to prevent recurrence:

```yaml
---
title: Hygiene reports must never be at root
type: feedback
status: active
---

Never create audit/hygiene/report files at root. They're self-referential.
Always save to docs/notes/YYYY_MM_DD-*.md instead.
```

These memories carry forward to future sessions, so you don't forget the pattern.

## Example Output

```
╔══════════════════════════════════════════════════════════════════╗
║                  SELF-HEALING ANALYSIS & FIXES                   ║
╚══════════════════════════════════════════════════════════════════╝

Issue Detected: root-directory-hygiene creates audit reports at root

Root Cause: Skill lacked rule forbidding this anti-pattern

Components to Update:
  [1] Skill: SKILL.md
      → Add ROOT-HYGIENE-SELF-REF rule documentation (HIGH confidence)
  [2] Rule Catalog: references/rule-catalog.md
      → Add new rule ID with HIGH severity (HIGH confidence)
  [3] Allowlist: references/root-allowlist.md
      → Forbid *HYGIENE*.md at root (HIGH confidence)

Prevention: Future runs will flag and prevent this issue

Proceed with fixes? (yes/no/review)
```

## Integration with Project

The skill works with:
- **git** — Commits all changes with explanatory messages
- **settings.json** — Adds/configures hooks and settings
- **Skills** — Updates descriptions, rules, and documentation
- **Memory system** — Creates feedback/project/reference memories
- **CLAUDE.md** — Documents new patterns and preventive practices

## Success Criteria

You know it worked when:

✅ Issue is fixed  
✅ Prevention rule is in place  
✅ All changes committed with clear messages  
✅ CLAUDE.md documents the new pattern  
✅ Issue doesn't recur in future sessions  
✅ Similar issues are now prevented  

## Philosophy

**When something breaks, fix it so it never breaks the same way again.**

Don't just patch the symptom — heal the system. This skill automates that philosophy.
