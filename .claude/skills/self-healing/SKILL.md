---
name: self-healing
description: |
  Detect issues from session context or user feedback, then automatically update 
  dependent rules, hooks, commands, skills, and memories so the issue won't happen again.
  Use /self-healing when you notice a bug, anti-pattern, or undesirable behavior that 
  should be prevented at the system level. The skill will: (1) analyze the root cause, 
  (2) identify all affected components (rules, hooks, skills, memories, settings), 
  (3) propose fixes, (4) apply fixes to prevent recurrence. Trigger: /self-healing 
  or /self-healing <issue-description>
compatibility: |
  Requires: Git repository, settings.json, .claude/skills/, memory system, project hooks
---

# self-healing: Automatic Bug Prevention System

When you encounter a bug, anti-pattern, or undesirable behavior in your Claude Code session, use this skill to automatically fix not just the symptom, but the root cause across all dependent systems.

## Problem

Bugs and anti-patterns often recur because they're rooted in:
- Missing rules in skills or hooks
- Misconfigured settings that enable bad behavior
- Incomplete skill descriptions that don't trigger properly
- Stale memories that contradict updated code
- Missing validation in project hooks
- Forgotten workarounds that should be automated

**Example:** The root-directory-hygiene skill created hygiene reports at root (defeating its purpose). This required:
1. Fixing the skill itself (add rule, update descriptions)
2. Updating the rule catalog (document the anti-pattern)
3. Updating the allowlist (forbid the pattern)
4. Updating SKILL.md (document safe practices)
5. Committing all changes

Without `/self-healing`, you'd have to manually find and update each component.

## How It Works

### Invocation

```bash
/self-healing                          # Analyze session context for recent issues
/self-healing "root-directory-hygiene creates reports at root"  # Explicit issue
/self-healing issue=V008 severity=high # With parameters
```

### Workflow

#### Step 1: Detect Root Cause
- Examine recent session history for errors, warnings, or user complaints
- If user provides an issue description, parse it to understand the problem
- Identify whether it's a: rule violation, skill misconfiguration, memory staleness, missing validation, setting issue, or hook gap

#### Step 2: Find Affected Components
- **Skills:** Check `.claude/skills/` for related skills whose descriptions, rules, or behavior might need updates
- **Rules:** Check rule catalogs, allowlists, denylists in skill references
- **Memories:** Check `~/.claude/projects/[project]/memory/` for stale or conflicting entries
- **Hooks:** Check `.claude/settings.json` for configured hooks that should validate this
- **Settings:** Check `.claude/settings.json` for permission/behavior settings
- **CLAUDE.md:** Check project instructions for patterns that enable the issue

#### Step 3: Propose Fixes
For each affected component:
- Specific, targeted changes (not broad rewrites)
- With rationale and expected outcome
- Organized by component type (skill, rule, memory, hook, setting, CLAUDE.md)
- Marked with confidence level (high/medium/low)

#### Step 4: Apply Fixes
If user approves:
1. **Update skills** — Add rules, update descriptions, document anti-patterns
2. **Update rules** — Add new rule IDs, update catalogs, set proper severity
3. **Update memories** — Create/update user, feedback, project, or reference memories
4. **Add hooks** — Configure pre-commit, post-write, or pre-run hooks in settings.json
5. **Update settings** — Modify permission levels, environment defaults, feature flags
6. **Update CLAUDE.md** — Document the fix and preventive practice
7. **Commit all changes** with a message explaining the fix and prevention

#### Step 5: Verify Prevention
- Re-run the original failing scenario (if possible) to confirm fix
- Show before/after comparison
- Document what will now prevent recurrence

## Common Scenarios

### Scenario 1: Skill Creates Root Pollution

**Issue:** `/root-directory-hygiene` created audit report at root

**Affected Components:**
- ✅ **Skill:** Add ROOT-HYGIENE-SELF-REF rule to prevent future reports at root
- ✅ **Rule Catalog:** Add new rule ID with HIGH severity
- ✅ **Allowlist:** Forbid `*-HYGIENE*.md` at root
- ✅ **SKILL.md:** Document anti-pattern and safe practices
- ✅ **Commit:** Message explaining the fix

**Result:** Future runs will flag and prevent this issue automatically.

---

### Scenario 2: Skill Doesn't Trigger When It Should

**Issue:** User says "I wanted the deployment skill to help but it didn't trigger"

**Affected Components:**
- ✅ **Skill:** Review description and add missing trigger keywords
- ✅ **Memory:** Create user memory about deployment skill usage
- ✅ **CLAUDE.md:** Document when to explicitly invoke skill
- ✅ **Hook:** Optional — add pre-task hook to suggest skill if keywords match
- ✅ **Commit:** Updated skill description with better triggers

**Result:** Skill now triggers automatically on relevant prompts.

---

### Scenario 3: Memory Contradicts Updated Code

**Issue:** Memory says "use old API" but code changed to new API

**Affected Components:**
- ✅ **Memory:** Update/delete stale memory entries
- ✅ **Skill:** Update code examples if skill references old API
- ✅ **CLAUDE.md:** Update if doc references old behavior
- ✅ **Commit:** Message explaining memory update

**Result:** Memories align with current code; no contradictions.

---

### Scenario 4: User Repeatedly Forgets a Step

**Issue:** User keeps forgetting to run migrations after pulling code

**Affected Components:**
- ✅ **Hook:** Add post-pull hook to check for unmigrated files
- ✅ **Memory:** Create feedback memory: "always check migrations after git pull"
- ✅ **CLAUDE.md:** Add to "common tasks" section
- ✅ **Settings:** Optional — enable auto-migration flag
- ✅ **Commit:** Configured hook and documented process

**Result:** Hook reminds user automatically; memory helps with explanation.

---

## Component Types & Update Strategies

### Skills
**When to update:**
- Add new rule to rule catalog
- Improve skill description for better triggering
- Document anti-patterns discovered during use
- Update examples or workflows
- Add new references/guides

**Safety:** Always add rules before deleting; never break backward compatibility.

### Rules
**When to update:**
- Add new rule ID for newly-discovered anti-pattern
- Update severity if real-world impact differs from assumed severity
- Change auto-fix confidence based on actual usage
- Add to catalog with examples

**Safety:** New rules are non-breaking; existing rules never changed without migration.

### Memories
**When to update:**
- Delete stale/contradictory entries
- Update user memories if preferences change
- Create feedback memories for patterns observed
- Create project memories for new constraints discovered

**Safety:** Always explain why memory is being changed/deleted in commit message.

### Hooks
**When to add:**
- `pre-commit`: Validate files before committing (e.g., no root pollution)
- `post-write`: Update related files after editing (e.g., update CLAUDE.md)
- `pre-run`: Remind user of common pitfalls before running commands
- `post-pull`: Check for missing migrations/setup steps

**Safety:** Hooks must be non-blocking; they warn and suggest, never force.

### Settings
**When to update:**
- Add permission whitelist for frequently-needed tools
- Set environment variables for development defaults
- Configure feature flags to enable/disable behaviors
- Update permission levels for safer operations

**Safety:** Conservative by default; always allow explicit override.

### CLAUDE.md
**When to update:**
- Add discovered patterns to architecture section
- Document anti-patterns and safe practices
- Add to troubleshooting section
- Update "common tasks" with new patterns

**Safety:** Document rationale; never remove information without replacing it.

## Safety Principles

1. **No Destructive Changes** — Never delete without reason; always migrate old patterns
2. **Backward Compatible** — New rules don't break existing workflows
3. **Explicit Approval** — Show proposed changes before applying; user approves each
4. **Reversible** — All changes committed to git; easy to revert if needed
5. **Well-Documented** — Commit messages explain the fix and prevention strategy
6. **Idempotent** — Running `/self-healing` twice on the same issue is safe

## What Gets Updated

### Always Updated
- ✅ Affected skills (rules, descriptions, docs)
- ✅ Related rule catalogs and allowlists
- ✅ Git commits with explanation

### Often Updated
- ✅ Memories (user, feedback, project, reference)
- ✅ CLAUDE.md documentation
- ✅ Project hooks in settings.json

### Conditional
- ⚠️ Settings (only if behavior change needed)
- ⚠️ Permissions (only if access issue)
- ⚠️ Environment variables (only if config issue)

## Example: Self-Healing in Action

### Before (Problem)
```
User runs: /root-directory-hygiene
Output: ROOT-HYGIENE-REPORT.md created at root
User: "Ugh, the cleanup skill polluted the root. That's ironic."
```

### After (With /self-healing)
```
User runs: /self-healing "root-directory-hygiene creates reports at root"

[Skill analyzes, proposes fixes]

Affected components:
1. ✓ SKILL.md — Add ROOT-HYGIENE-SELF-REF rule documentation
2. ✓ rule-catalog.md — Add new rule ID (HIGH severity)
3. ✓ root-allowlist.md — Forbid *HYGIENE*.md at root
4. ✓ SKILL.md — Document anti-pattern and safe practices

[User approves fixes]

Changes applied:
✓ Updated .claude/skills/root-directory-hygiene/SKILL.md
✓ Updated .claude/skills/root-directory-hygiene/references/rule-catalog.md
✓ Updated .claude/skills/root-directory-hygiene/references/root-allowlist.md
✓ Committed with message: "fix(root-directory-hygiene): prevent self-referential..."
✓ Pushed to origin/main

Future behavior: /root-directory-hygiene now flags and prevents audit reports at root
```

## Memory Integration

This skill creates and updates memories to prevent recurrence:

- **feedback** — "User discovered X prevents Y; remember this in future sessions"
- **project** — "Project X has rule against Y; always check for this"
- **reference** — "Tool Z is located at; whenever mentioning Z, use this link"
- **user** — "User prefers X over Y; apply this preference in decisions"

Example feedback memory created:
```
---
name: prevent-hygiene-reports-at-root
description: Hygiene audit reports must never be created at root; always move to docs/notes/
metadata:
  type: feedback
---

**Rule:** Never create audit/hygiene/report files at the repository root.

**Why:** It's self-referential and defeats the purpose of root cleanup. The cleanup 
tool becomes a polluter.

**How to apply:** When running hygiene audits or generating any *-REPORT.md, 
*-AUDIT.md, or *-HYGIENE.md files, always save to docs/notes/YYYY_MM_DD-*.md 
instead of root.
```

## When to Use /self-healing

✅ **Use when:**
- You discover a bug that could recur
- A skill doesn't behave as expected
- You find an anti-pattern being repeated
- A rule is violated repeatedly
- A memory contradicts current reality
- A hook should exist but doesn't
- A setting enables bad behavior

❌ **Don't use when:**
- It's a one-off mistake (just fix it manually)
- The issue is in application code (fix the code, not the tooling)
- The issue requires significant refactoring (use /plan instead)
- You're unsure what the real issue is (debug first)

## Technical Implementation

The skill performs these operations:

1. **Session Analysis** — Parse recent context for errors/warnings
2. **Component Discovery** — Find all files that might need updates
3. **Root Cause Analysis** — Determine what allowed/enabled the issue
4. **Fix Generation** — Propose specific changes to each component
5. **User Approval** — Show proposed changes; wait for go-ahead
6. **Execution** — Apply changes to skills, rules, memories, hooks, settings
7. **Validation** — Verify all changes committed and pushed
8. **Documentation** — Update CLAUDE.md with prevention strategy
9. **Memory Creation** — Create feedback/project memories for future sessions

## Output Format

When run, `/self-healing` produces:

```
╔══════════════════════════════════════════════════════════════════╗
║                  SELF-HEALING ANALYSIS & FIXES                   ║
╚══════════════════════════════════════════════════════════════════╝

Issue Detected:
  root-directory-hygiene creates audit reports at root

Root Cause:
  Skill lacked rule forbidding this anti-pattern

Components to Update:
  [1] Skill: .claude/skills/root-directory-hygiene/SKILL.md
      → Add ROOT-HYGIENE-SELF-REF rule documentation
      Confidence: HIGH
  
  [2] Rule Catalog: references/rule-catalog.md
      → Add new rule ID with HIGH severity
      Confidence: HIGH
  
  [3] Allowlist: references/root-allowlist.md
      → Forbid *HYGIENE*.md at root
      Confidence: HIGH

Prevention Strategy:
  Future behavior: /root-directory-hygiene will flag and prevent this issue

Proceed with fixes? (yes/no/review)
```

---

## Related Skills & Commands

- `/root-directory-hygiene` — Audit root cleanliness (now prevents self-referential reports)
- `/init` — Create CLAUDE.md (often needs updating with new patterns)
- `/update-config` — Configure hooks and settings
- Memory system — Stores patterns learned during sessions

---

## Success Criteria

You know `/self-healing` worked when:

✅ Issue is fixed (symptom goes away)  
✅ Prevention is in place (rule added, hook configured, memory created)  
✅ All changes committed with clear messages  
✅ CLAUDE.md documents the new pattern  
✅ Issue doesn't recur in future sessions  
✅ Similar issues are now prevented by the new rule  

---

## Example: Self-Healing a Missing Trigger

**Session Context:** User mentions deployment but skill doesn't activate

**Command:** `/self-healing`

**Output:**
```
Issue: g-s-deploy skill not triggering on deployment keywords

Affected Components:
1. SKILL.md — Update description to add missing trigger keywords
2. Memory — Create feedback memory: "deployment skill needs explicit mention of VPS, Docker, domain setup"
3. CLAUDE.md — Document skill in deployment section

Proposed changes:
✓ Add "VPS setup", "Docker deployment", "domain management" to skill description
✓ Create memory preventing this oversight
✓ Add skill reference to CLAUDE.md

Apply? (yes/no)
> yes

Fixed in:
✓ .claude/skills/g-s-deploy/SKILL.md (description updated)
✓ ~/.claude/projects/[project]/memory/feedback_deployment_triggers.md (new)
✓ CLAUDE.md (section added)
✓ Committed & pushed

Future behavior: Skill now triggers on more deployment-related prompts
```

---

## Final Note

This skill embodies the philosophy: **When something breaks, fix it so it never breaks the same way again.** Don't just patch the symptom — heal the system.
