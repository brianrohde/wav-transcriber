# Dev Browser Skill Integration

## Overview

A comprehensive skill for browser automation and testing using dev-browser has been added to the project at `.claude/skills/dev-browser-guide/`.

This skill guides you through:
- Taking screenshots of the WAV Transcriber UI
- Automating user workflows (upload, transcribe, export)
- Testing the application end-to-end
- Debugging UI issues
- Performance monitoring

## Quick Start

### 1. Install Dev Browser

```bash
npm install -g dev-browser
dev-browser install
```

### 2. Take a Screenshot of Your App

```bash
dev-browser <<'EOF'
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "wav-transcriber.png");
console.log(path);
EOF
```

### 3. Test the Upload Workflow

```bash
dev-browser <<'EOF'
const page = await browser.getPage("app");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });

// Find the upload zone
const result = await page.snapshotForAI();
console.log(result.full);  // Read the page structure

// Click upload or drag-drop
await page.locator("input[type='file']").setInputFiles("./test-audio.wav");

// Wait for UI response
await page.waitForSelector(".file-info", { timeout: 5000 });
console.log("File uploaded successfully");
EOF
```

## Accessing the Skill

The skill is located at:
- **Main documentation:** `.claude/skills/dev-browser-guide/SKILL.md`
- **Quick reference:** `.claude/skills/dev-browser-guide/references/quick-reference.md`
- **Advanced patterns:** `.claude/skills/dev-browser-guide/references/advanced-patterns.md`

## Typical Use Cases with WAV Transcriber

### Test Complete User Journey

```javascript
// 1. Load app
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });

// 2. Upload WAV file
await page.locator("input[type='file']").setInputFiles("./audio.wav");

// 3. Click transcribe
await page.getByRole("button", { name: "Transcribe" }).click();

// 4. Wait for results
await page.waitForSelector(".transcription-result", { timeout: 30000 });

// 5. Verify result
const text = await page.textContent(".transcription-result");
console.log("Transcription:", text.substring(0, 100));

// 6. Test copy button
await page.getByRole("button", { name: "Copy" }).click();
```

### Verify UI Elements

```javascript
// Take snapshot to inspect structure
const result = await page.snapshotForAI();
console.log(result.full);

// Verify key elements exist
const assertions = {
  headerPresent: (await page.locator("h1").count()) > 0,
  dragDropZone: (await page.locator(".drag-drop").count()) > 0,
  debugMessage: (await page.locator(".debug-message").count()) > 0,
  uploadButton: (await page.locator("input[type='file']").count()) > 0
};

console.log(JSON.stringify(assertions));
```

### Take App Screenshots

```javascript
// Take main screenshot
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "app-main.png");

// Test responsive (mobile)
await page.setViewportSize({ width: 375, height: 667 });
await page.reload();
const mobileBuf = await page.screenshot();
const mobilePath = await saveScreenshot(mobileBuf, "app-mobile.png");

console.log(JSON.stringify({ desktop: path, mobile: mobilePath }));
```

## Integration with CLAUDE.md

The skill follows the project's development patterns:
- Sandboxed execution (safe to automate tests)
- Named pages for state persistence
- Error handling with screenshots
- Integration with CI/CD workflows

## Common Workflows

### Regression Testing

Create a `test-app.js` file:

```javascript
const page = await browser.getPage("app");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });

// Test 1: Upload
await page.locator("input[type='file']").setInputFiles("./test.wav");
console.assert(await page.locator(".file-info").isVisible(), "File info not shown");

// Test 2: Transcribe
await page.getByRole("button", { name: "Transcribe" }).click();
await page.waitForSelector(".transcription-result", { timeout: 30000 });
console.log("✅ All tests passed");
```

Run with:
```bash
dev-browser run test-app.js
```

### Performance Monitoring

```javascript
const page = await browser.getPage("perf");
const startTime = Date.now();
await page.goto("http://localhost:5173");
const loadTime = Date.now() - startTime;
console.log(`Load time: ${loadTime}ms`);
```

### CI/CD Integration

Use dev-browser in your deployment pipeline to verify the UI loads correctly:

```bash
# In deploy.ps1 or deploy.sh
dev-browser --headless --timeout 10 <<'EOF'
const page = await browser.getPage("verify");
await page.goto("http://localhost:5173");
const title = await page.title();
console.assert(title.includes("WAV"), "Title check failed");
console.log("✅ UI verification passed");
EOF
```

## Key Features for This Project

✅ **Screenshot verification** - Confirm UI renders correctly
✅ **Workflow automation** - Test upload → transcribe → export
✅ **Element inspection** - Use AI snapshots to find elements
✅ **Error debugging** - Automatic screenshots on failure
✅ **State persistence** - Named pages preserve login/session state
✅ **Headless mode** - Run in CI/CD without display
✅ **Network simulation** - Test on slow connections
✅ **Responsive testing** - Test mobile/tablet/desktop layouts

## See Also

- Skill documentation: `.claude/skills/dev-browser-guide/SKILL.md`
- Quick reference: `.claude/skills/dev-browser-guide/references/quick-reference.md`
- Advanced patterns: `.claude/skills/dev-browser-guide/references/advanced-patterns.md`
- Playwright API: https://playwright.dev/docs/api/class-page
- Dev Browser GitHub: https://github.com/browserbase/dev-browser
