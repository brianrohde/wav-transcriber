# Dev Browser Guide Skill - Summary

## Created Files

```
.claude/skills/dev-browser-guide/
├── SKILL.md                              # Main skill documentation (500+ lines)
├── README.md                             # Skill overview and quick start
├── SUMMARY.md                            # This file
└── references/
    ├── quick-reference.md                # One-page cheat sheet
    └── advanced-patterns.md              # Complex workflows and patterns
```

## What's Included

### Main Documentation (SKILL.md)
- **Installation** - How to install dev-browser
- **Basic Syntax** - How to write and run scripts (heredoc and file methods)
- **Core API Reference** - Complete API with examples:
  - Navigation (goto, reload, back/forward)
  - Screenshots and AI snapshots
  - Element selection (role-based, CSS, text)
  - Interaction (click, fill, type, hover, drag)
  - Waiting conditions (selector, URL, function)
  - Page evaluation (run JS in browser)
  - Page management (list, create, close)
  - File I/O (restricted to tmp/)
- **6 Common Patterns** - Ready-to-use code:
  1. Navigate and screenshot
  2. Discover elements with AI snapshot
  3. Form fill and submit
  4. Error recovery with debugging
  5. Multi-step workflow with named pages
  6. Validate multiple elements
- **Critical Tips** - 6 DO's and 6 DON'Ts
- **Options & Flags** - All command-line options
- **Troubleshooting** - Solutions to 5 common problems

### Quick Reference (quick-reference.md)
- Minimal examples for every task
- Common selectors reference table
- One-liners for frequent operations
- Wait conditions quick guide
- Debug techniques
- File operations
- Page management
- Important flags
- Dev server navigation tips
- Common pitfalls table

### Advanced Patterns (advanced-patterns.md)
- **Testing Workflows** - Complete user journey test, responsive design testing, network condition testing
- **Data Extraction** - Table data extraction, metadata extraction
- **State Management** - Session persistence, snapshot saving/restoration
- **Error Handling** - Comprehensive error handling, validation assertions
- **Performance Monitoring** - Load metrics, network request monitoring

## Key Features

✅ **Comprehensive** - 1000+ lines of documentation
✅ **Practical** - 20+ ready-to-use code examples
✅ **Progressive** - Starts simple, goes advanced
✅ **Well-organized** - Clear navigation with references
✅ **Problem-focused** - Troubleshooting section included
✅ **Real-world patterns** - Based on actual use cases

## Quick Start

```bash
# Install
npm install -g dev-browser
dev-browser install

# Take screenshot
dev-browser <<'EOF'
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "app.png");
console.log(path);
EOF
```

## Most Important Rules

1. **Use `domcontentloaded` for dev servers** - Prevents hanging on HMR
2. **Use `page.snapshotForAI()`** - Best way to discover page elements
3. **Use role-based selectors** - More reliable than CSS
4. **Name your pages** - Persist state between script runs
5. **Add timeouts** - Prevent scripts hanging indefinitely
6. **No TypeScript in evaluate()** - Use plain JavaScript only

## Triggering This Skill

The skill will trigger when Claude Code detects:
- User mentions "dev-browser"
- User wants to automate browser testing
- User needs to take screenshots of a web app
- User wants to verify UI behavior
- User is debugging a web application
- User mentions browser automation

## Next Steps

1. **Read SKILL.md** for comprehensive documentation
2. **Check quick-reference.md** when you need a quick answer
3. **Browse advanced-patterns.md** for complex scenarios
4. **Try a pattern** from the examples
5. **Refer to Playwright API docs** for deeper details

## File Locations

All files are in: `.claude/skills/dev-browser-guide/`

- Main skill: `.claude/skills/dev-browser-guide/SKILL.md`
- Quick reference: `.claude/skills/dev-browser-guide/references/quick-reference.md`
- Advanced patterns: `.claude/skills/dev-browser-guide/references/advanced-patterns.md`
- Overview: `.claude/skills/dev-browser-guide/README.md`

## Git Information

- **Commit:** Added dev-browser-guide skill with comprehensive documentation
- **Files:** 4 new markdown files
- **Lines:** 1200+ lines of documentation
- **Branch:** main
