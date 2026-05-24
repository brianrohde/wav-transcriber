# Dev Browser Guide Skill

A comprehensive skill for mastering dev-browser - the CLI tool for automated browser testing and scripting.

## What This Skill Covers

- **Basic syntax** - How to write and run dev-browser scripts
- **Core API** - Navigation, screenshots, element selection, interactions
- **Common patterns** - Screenshot, form filling, waiting, validation
- **Advanced patterns** - Multi-step workflows, data extraction, error handling
- **Critical tips** - Do's and don'ts for proper usage
- **Troubleshooting** - Solutions to common problems

## Quick Start

```bash
npm install -g dev-browser
dev-browser install

# Take a screenshot
dev-browser <<'EOF'
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "app.png");
console.log(path);
EOF
```

## Files

- **SKILL.md** - Main skill guide with reference documentation
- **references/quick-reference.md** - One-page quick reference for common tasks
- **references/advanced-patterns.md** - Advanced patterns for complex workflows

## When to Use This Skill

✅ **Use dev-browser when you need to:**
- Take screenshots of a web application
- Automate browser interactions (click, fill forms, navigate)
- Test UI workflows end-to-end
- Verify page content and structure
- Debug web applications
- Extract data from web pages
- Test responsive design across devices
- Monitor network performance

❌ **Don't use dev-browser for:**
- Testing Node.js APIs (not a Node environment)
- File system operations beyond temp files
- Network requests outside browser (use fetch in page context)
- Testing non-Chrome browsers (Chrome/Chromium only)

## Key Concepts

### Sandboxed Runtime
Scripts run in QuickJS sandbox, not Node.js. This means:
- ✅ Playwright Page API available
- ✅ console.log() works
- ❌ No require() / import()
- ❌ No fs / path modules
- ❌ No direct fetch/WebSocket

### Named Pages
Use named pages to persist state between script runs:
```javascript
const page = await browser.getPage("my-app");  // Same instance across scripts
```

### Dev Server Handling
Always use `domcontentloaded` for local dev servers (Vite, Next.js):
```javascript
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
```

### AI Snapshots
Use `page.snapshotForAI()` to discover page elements:
```javascript
const result = await page.snapshotForAI();
console.log(result.full);  // Read to find elements
```

## Common Patterns

### Pattern 1: Screenshot
```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "screenshot.png");
console.log(path);
```

### Pattern 2: Discover and Click Element
```javascript
const page = await browser.getPage("main");
await page.goto("http://localhost:5173");
const result = await page.snapshotForAI();  // See page structure
console.log(result.full);
// Then click based on what you find
await page.getByRole("button", { name: "Upload" }).click();
```

### Pattern 3: Form Fill and Submit
```javascript
await page.fill("input[name='email']", "user@example.com");
await page.fill("input[name='password']", "password");
await page.click("button[type='submit']");
await page.waitForURL("**/success");
```

### Pattern 4: Error Recovery
```javascript
try {
  // test code
} catch (error) {
  const buf = await page.screenshot();
  const path = await saveScreenshot(buf, "error.png");
  console.error(JSON.stringify({ error: error.message, screenshot: path }));
}
```

## Tips for Success

1. **Use role-based selectors** - More reliable than CSS
2. **Add timeouts** - Prevent scripts hanging
3. **Use snapshotForAI()** - Discover elements easily
4. **Name your pages** - Persist state across scripts
5. **Wait before interacting** - Ensure elements are ready
6. **Test error cases** - Include try/catch with screenshots
7. **Use domcontentloaded** - For local dev servers
8. **Log JSON** - Use `console.log(JSON.stringify(...))` for structured output

## References

- [Playwright API Documentation](https://playwright.dev/docs/api/class-page)
- [Dev Browser GitHub](https://github.com/browserbase/dev-browser)
- [Dev Browser npm Package](https://www.npmjs.com/package/dev-browser)

## Example Use Cases

### Testing Web Application
```javascript
// Test upload feature end-to-end
const page = await browser.getPage("upload-test");
await page.goto("http://localhost:5173");
await page.locator("input[type='file']").setInputFiles("./test.wav");
await page.getByRole("button", { name: "Transcribe" }).click();
await page.waitForSelector(".results", { timeout: 30000 });
const result = await page.textContent(".transcription-result");
console.log("Transcription:", result.substring(0, 50) + "...");
```

### Monitoring Performance
```javascript
const startTime = Date.now();
await page.goto("http://localhost:5173");
const loadTime = Date.now() - startTime;
console.log(`Load time: ${loadTime}ms`);
```

### Data Extraction
```javascript
const data = await page.$$eval(".item", elements => {
  return elements.map(el => ({
    title: el.querySelector(".title")?.textContent,
    description: el.querySelector(".description")?.textContent
  }));
});
console.log(JSON.stringify(data, null, 2));
```

### Responsive Testing
```javascript
for (const width of [375, 768, 1920]) {
  await page.setViewportSize({ width, height: 1024 });
  await page.goto("http://localhost:5173");
  const buf = await page.screenshot();
  await saveScreenshot(buf, `layout-${width}.png`);
}
```

## Support

For issues or questions:
1. Check **SKILL.md** for comprehensive documentation
2. See **references/quick-reference.md** for one-liners
3. Review **references/advanced-patterns.md** for complex scenarios
4. Check troubleshooting section in SKILL.md
