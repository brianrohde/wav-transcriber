---
name: dev-browser-guide
description: Master dev-browser for automated browser testing and scripting. Use when you need to automate browser interactions, take screenshots, inspect page content, test UI workflows, or verify web application behavior. This skill covers correct syntax, common patterns, AI snapshots for element discovery, error recovery, and performance optimization. Trigger whenever the user mentions "dev-browser", wants to automate testing, needs to inspect a page, or requires visual verification of a web app.
---

# Dev Browser Guide

A comprehensive skill for using dev-browser correctly for browser automation, testing, and verification.

## What is Dev Browser?

Dev Browser is a CLI tool for controlling browsers with JavaScript scripts running in a sandboxed QuickJS runtime (not Node.js). It's perfect for:
- Taking screenshots of web applications
- Automating user interactions (clicks, form fills)
- Testing UI workflows
- Verifying page content and structure
- Debugging web applications

**Key constraint:** Scripts run in a sandbox with NO access to `require()`, `import()`, `fs`, `fetch`, or other Node.js APIs. Only Playwright Page API is available.

## Installation

```bash
npm install -g dev-browser
dev-browser install  # Downloads Chromium for Testing
```

## Basic Script Syntax

### Standard invocation with heredoc (Bash/PowerShell):

```bash
# Bash
dev-browser <<'EOF'
const page = await browser.getPage("main");
await page.goto("https://example.com");
console.log(await page.title());
EOF

# PowerShell
@"
const page = await browser.getPage("main");
await page.goto("https://example.com");
console.log(await page.title());
"@ | dev-browser
```

### Run a script file:

```bash
dev-browser run script.js
```

### Connect to existing Chrome:

```bash
# Auto-discover Chrome with debugging enabled
dev-browser --connect <<'EOF'
const page = await browser.getPage("main");
console.log(await page.title());
EOF

# Connect to specific CDP endpoint
dev-browser --connect http://localhost:9222 <<'EOF'
const page = await browser.getPage("main");
EOF
```

## Core API Reference

### Navigation

```javascript
// Navigate to a URL - use domcontentloaded for dev servers
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });

// Navigate back/forward
await page.goBack();
await page.goForward();

// Reload page
await page.reload();

// Get current URL or title
page.url();
await page.title();
```

### Taking Screenshots & Snapshots

```javascript
// Full page screenshot
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "screenshot.png");
console.log(path);

// AI-optimized snapshot for element discovery (BEST for finding elements)
const result = await page.snapshotForAI();
console.log(result.full);  // Returns markdown representation of page

// Snapshot with options
const result = await page.snapshotForAI({ 
  track: "main",        // Track changes for next snapshot
  depth: 2,             // Tree depth
  timeout: 5000 
});
```

### Element Selection & Interaction

```javascript
// Use Playwright role-based selection (preferred after snapshotForAI)
await page.getByRole("button", { name: "Submit" }).click();
await page.getByRole("textbox", { name: "Email" }).fill("test@example.com");

// CSS selector
await page.click(".submit-btn");
await page.fill("input[type='email']", "test@example.com");

// Wait for element
await page.waitForSelector(".results");

// Get text content
const text = await page.textContent(".title");

// Type text character by character
await page.type("input", "text");

// Press key
await page.press("input", "Enter");

// Hover
await page.hover(".menu-item");

// Drag and drop
await page.drag(".draggable", ".drop-zone");

// File upload
await page.locator("input[type='file']").setInputFiles("./file.txt");
```

### Waiting & Validation

```javascript
// Wait for selector
await page.waitForSelector(".loaded");

// Wait for URL change
await page.waitForURL("**/success");
await page.waitForURL(/success/);

// Wait for function condition
await page.waitForFunction(() => window.ready === true);

// Wait with timeout
try {
  await page.waitForSelector(".results", { timeout: 5000 });
} catch (e) {
  console.error("Element never appeared");
}
```

### Page Evaluation (Run JS in browser context)

```javascript
// Run JavaScript in the page context (plain JS only - no TypeScript syntax)
const result = await page.evaluate(() => {
  return document.querySelectorAll(".item").length;
});
console.log(result);

// Get computed styles
const color = await page.evaluate(() => {
  return window.getComputedStyle(document.body).backgroundColor;
});

// Check if element is visible
const isVisible = await page.evaluate(() => {
  const el = document.querySelector(".popup");
  return el && el.offsetHeight > 0;
});
```

### Page Management

```javascript
// Get all open tabs/pages
const pages = await browser.listPages();
console.log(JSON.stringify(pages, null, 2));
// Returns: [{id, url, title, name}, ...]

// Connect to existing page by ID
const page = await browser.getPage("TARGET_ID_HERE");

// Create new page
const newPage = await browser.newPage();
await newPage.goto("https://example.com");

// Close named page
await browser.closePage("main");
```

### File I/O (restricted to ~/.dev-browser/tmp/)

```javascript
// Save screenshot
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "debug.png");

// Write file
const jsonPath = await writeFile("results.json", JSON.stringify(data));

// Read file
const content = await readFile("results.json");
const data = JSON.parse(content);
```

## Common Patterns

### Pattern 1: Navigate and Take Screenshot

```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "app.png");
console.log(path);
```

### Pattern 2: Discover Elements with AI Snapshot

```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173");

// Get AI snapshot to see page structure
const result = await page.snapshotForAI();
console.log(result.full);  // Read output to identify elements

// Then interact based on what you find
await page.getByRole("button", { name: "Upload" }).click();
```

### Pattern 3: Form Fill and Submit

```javascript
const page = await browser.getPage("form");
await page.goto("http://localhost:5173");

// Fill form fields
await page.fill("input[name='email']", "user@example.com");
await page.fill("input[name='password']", "password123");

// Submit
await page.click("button[type='submit']");

// Wait for result
await page.waitForURL("**/success");
console.log("Form submitted successfully");
```

### Pattern 4: Error Recovery with Screenshot Debug

```javascript
try {
  const page = await browser.getPage("checkout");
  await page.goto("http://localhost:5173/checkout");
  await page.getByRole("button", { name: "Pay" }).click();
  await page.waitForURL("**/confirmation", { timeout: 5000 });
} catch (error) {
  // Take screenshot on failure
  const buf = await page.screenshot();
  const path = await saveScreenshot(buf, "error-debug.png");
  console.error(JSON.stringify({
    error: error.message,
    screenshot: path,
    url: page.url(),
    title: await page.title()
  }, null, 2));
}
```

### Pattern 5: Multi-Step Workflow with Named Pages

```javascript
// Use named pages to persist state between script runs
const homePage = await browser.getPage("home");
await homePage.goto("http://localhost:5173");

// Do something
await homePage.click(".login-btn");

// Now in another script, reconnect to same page
const homePage2 = await browser.getPage("home");
console.log(homePage2.url());  // Still logged in state
```

### Pattern 6: Validate Multiple Elements

```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173");

// Get all items matching selector
const items = await page.$$(".item");
console.log(`Found ${items.length} items`);

// Run function on each
const texts = await page.$$eval(".item", elements => {
  return elements.map(el => el.textContent);
});
console.log(JSON.stringify(texts));
```

## Critical Tips

### ✅ DO's

1. **Use `domcontentloaded` for dev servers** - Vite, Next.js, etc. use long-lived connections:
   ```javascript
   await page.goto(url, { waitUntil: "domcontentloaded" });
   ```

2. **Use `page.snapshotForAI()` for element discovery** - Gets a readable page structure:
   ```javascript
   const result = await page.snapshotForAI();
   console.log(result.full);
   ```

3. **Use role-based selectors** - More reliable than CSS:
   ```javascript
   await page.getByRole("button", { name: "Submit" }).click();
   ```

4. **Name your pages for persistence** - Reconnect to same state:
   ```javascript
   const page = await browser.getPage("checkout");  // Named page persists
   ```

5. **Add timeouts for waiting** - Fail fast instead of hanging:
   ```javascript
   await page.waitForSelector(".results", { timeout: 5000 });
   ```

6. **Use try/catch and log failures** - Include screenshot on error:
   ```javascript
   try {
     // test code
   } catch (error) {
     const buf = await page.screenshot();
     const path = await saveScreenshot(buf, "error.png");
     console.error(JSON.stringify({ error: error.message, screenshot: path }));
   }
   ```

### ❌ DON'Ts

1. **Don't use `require()` or `import()`** - Not available in sandbox
2. **Don't use `fs` or `path` modules** - No direct filesystem access
3. **Don't use `fetch` or `WebSocket`** - Not available
4. **Don't use `process` or `__dirname`** - No process access
5. **Don't use TypeScript syntax in `page.evaluate()`** - Only plain JS:
   ```javascript
   // WRONG
   await page.evaluate(() => {
     const value: string = "test";  // ❌ TypeScript syntax
   });

   // CORRECT
   await page.evaluate(() => {
     const value = "test";  // ✅ Plain JavaScript
   });
   ```

6. **Don't chain async operations without await**:
   ```javascript
   // WRONG
   await page.goto(url);
   const buf = page.screenshot();  // ❌ Missing await
   
   // CORRECT
   await page.goto(url);
   const buf = await page.screenshot();  // ✅ Properly awaited
   ```

## Options & Flags

```bash
# Set script timeout (default 30 seconds)
dev-browser --timeout 60 <<'EOF'
  // script
EOF

# Use headless mode
dev-browser --headless <<'EOF'
  // script
EOF

# Ignore HTTPS certificate errors (dev/staging only)
dev-browser --ignore-https-errors <<'EOF'
  // script
EOF

# Connect to named browser instance
dev-browser --browser my-project <<'EOF'
  // script
EOF

# Run script file instead of inline
dev-browser run my-script.js
```

## Troubleshooting

### Script hangs or timeout

**Problem:** Script exceeds 30 second timeout
**Solution:** 
- Reduce complexity
- Use `{ timeout: 5000 }` on `waitFor*` calls
- Use `--timeout 60` flag for longer scripts

### Element not found

**Problem:** `page.click()` fails because element doesn't exist
**Solution:**
1. Take a screenshot to verify page loaded
2. Use `page.snapshotForAI()` to inspect page structure
3. Check that wait conditions are met before interacting

### Page won't navigate to localhost

**Problem:** Navigation to dev server fails
**Solution:**
- Verify server is running on correct port
- Use `domcontentloaded` instead of `load`:
  ```javascript
  await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
  ```

### Can't access file system

**Problem:** Trying to read/write files outside sandbox
**Solution:**
- Use `writeFile()` and `readFile()` for temporary files
- Files automatically saved to `~/.dev-browser/tmp/`
- No path traversal escape possible

### Reconnecting to a page lost state

**Problem:** Created a named page, then script errored
**Solution:**
- Named pages persist between script runs
- Reconnect with same name to resume:
  ```javascript
  const page = await browser.getPage("checkout");  // Reconnects to existing
  console.log(page.url());  // Shows previous state
  ```

## See Also

- **Playwright API Reference**: https://playwright.dev/docs/api/class-page
- **Dev Browser GitHub**: https://github.com/browserbase/dev-browser
- **Installation**: `npm install -g dev-browser && dev-browser install`
