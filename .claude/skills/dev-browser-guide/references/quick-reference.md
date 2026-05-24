# Dev Browser Quick Reference

## Installation
```bash
npm install -g dev-browser
dev-browser install
```

## Minimal Examples

### Screenshot
```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "app.png");
console.log(path);
```

### Find and Click Element
```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173");

// Option 1: Use AI snapshot to find element
const result = await page.snapshotForAI();
console.log(result.full);  // Read the output to find element

// Option 2: Use role-based selector
await page.getByRole("button", { name: "Upload" }).click();
```

### Fill Form
```javascript
const page = await browser.getPage("form");
await page.goto("http://localhost:5173/form");
await page.fill("input[name='email']", "test@example.com");
await page.fill("input[name='message']", "Hello");
await page.click("button[type='submit']");
```

### Wait and Verify
```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173");

// Wait for element
await page.waitForSelector(".results", { timeout: 5000 });

// Get text
const text = await page.textContent(".results");
console.log(text);
```

## Common Selectors

```javascript
// By role (PREFERRED - most reliable)
page.getByRole("button", { name: "Submit" })
page.getByRole("textbox", { name: "Email" })
page.getByRole("heading", { level: 1 })

// By CSS
page.locator(".button")
page.locator("input[type='file']")
page.locator("#submit-btn")

// By text
page.getByText("Click me")
page.getByLabel("Email")

// By placeholder
page.getByPlaceholder("Enter email")
```

## One-Liners

```javascript
// Get page title
await page.title()

// Get current URL
page.url()

// Check if element exists
(await page.locator(".element").count()) > 0

// Get element count
await page.locator(".item").count()

// Get all text content
await page.textContent("body")

// Check if element visible
await page.locator(".popup").isVisible()

// Get computed style
await page.evaluate(() => window.getComputedStyle(document.body).backgroundColor)
```

## Wait Conditions

```javascript
// Wait for selector
await page.waitForSelector(".loaded")

// Wait for specific text
await page.waitForFunction(() => document.body.textContent.includes("Success"))

// Wait for URL change
await page.waitForURL("**/success")

// Wait with custom timeout
await page.waitForSelector(".results", { timeout: 10000 })
```

## Debug Techniques

```javascript
// Take screenshot on error
try {
  // test code
} catch (e) {
  const buf = await page.screenshot();
  const path = await saveScreenshot(buf, "error.png");
  console.error(path);
}

// Log current state
console.log(JSON.stringify({
  url: page.url(),
  title: await page.title(),
  screenshot: await saveScreenshot(await page.screenshot(), "debug.png")
}));

// Inspect page with AI snapshot
const result = await page.snapshotForAI();
console.log(result.full);

// Run JS to debug
const value = await page.evaluate(() => {
  return window.myVariable;
});
console.log(value);
```

## File Operations

```javascript
// Save screenshot
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "name.png");

// Save data
const path = await writeFile("data.json", JSON.stringify(obj));

// Read data
const content = await readFile("data.json");
const obj = JSON.parse(content);

// Path format
// Files go to: ~/.dev-browser/tmp/
```

## Page Management

```javascript
// Get all pages
const pages = await browser.listPages();

// Connect to page by ID
const page = await browser.getPage("id-or-name");

// Create new page
const page = await browser.newPage();

// Close page
await browser.closePage("name");
```

## Important Flags

```bash
# Custom timeout (seconds)
dev-browser --timeout 60

# Headless mode
dev-browser --headless

# Connect to Chrome
dev-browser --connect http://localhost:9222

# Named browser instance
dev-browser --browser my-project

# Run script file
dev-browser run script.js
```

## Dev Server Navigation

**Always use `domcontentloaded` for local servers:**

```javascript
// ✅ CORRECT for Vite, Next.js, etc
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });

// ❌ WRONG - hangs on HMR
await page.goto("http://localhost:5173", { waitUntil: "load" });
```

## Common Pitfalls

| Issue | Solution |
|-------|----------|
| Element not found | Use `snapshotForAI()` to inspect page |
| Script hangs | Use `domcontentloaded` + timeouts |
| Can't use `require()` | Use Playwright API only (sandbox) |
| TypeScript in evaluate() | Use plain JavaScript only |
| Missing `await` | Always `await` async functions |
| Port already in use | Check what's running on that port |
| Screenshot blank | Wait for page to load first |

## Inline vs File Scripts

```bash
# Inline (heredoc)
dev-browser <<'EOF'
const page = await browser.getPage("main");
await page.goto("http://localhost:5173");
EOF

# File
echo 'const page = await browser.getPage("main"); await page.goto("http://localhost:5173");' > script.js
dev-browser run script.js
```

## Connecting to Existing Chrome

```bash
# Start Chrome with debugging
chrome.exe --remote-debugging-port=9222

# Or use Chrome DevTools UI: chrome://inspect/#remote-debugging

# Connect dev-browser
dev-browser --connect http://localhost:9222 <<'EOF'
const page = await browser.getPage("main");
console.log(await page.title());
EOF
```
