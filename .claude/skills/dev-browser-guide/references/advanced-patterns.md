# Advanced Dev Browser Patterns

## Testing Workflows

### Complete User Journey Test

```javascript
const page = await browser.getPage("journey");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });

// Step 1: Verify landing page
let snapshot = await page.snapshotForAI();
console.log("Landing page loaded:", snapshot.full.includes("WAV Transcriber"));

// Step 2: Simulate drag and drop
const fileInput = page.locator("input[type='file']");
await fileInput.setInputFiles("./test-audio.wav");

// Wait for file preview
await page.waitForSelector(".file-info");
console.log("File selected successfully");

// Step 3: Click transcribe button
await page.getByRole("button", { name: "Transcribe" }).click();

// Step 4: Wait for progress indicator
await page.waitForSelector(".progress-bar", { timeout: 5000 });
console.log("Transcription started");

// Step 5: Wait for results
await page.waitForSelector(".results", { timeout: 30000 });
const transcriptionText = await page.textContent(".transcription-result");
console.log("Transcription complete:", transcriptionText.substring(0, 100) + "...");

// Step 6: Verify copy button works
await page.getByRole("button", { name: "Copy" }).click();
await page.waitForSelector(".copied-notification", { timeout: 2000 });
console.log("Copy to clipboard verified");

// Final screenshot
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "journey-complete.png");
console.log(JSON.stringify({ success: true, screenshot: path }));
```

### Responsive Design Testing

```javascript
const devices = [
  { name: "mobile", width: 375, height: 667 },
  { name: "tablet", width: 768, height: 1024 },
  { name: "desktop", width: 1920, height: 1080 }
];

const page = await browser.getPage("responsive");

for (const device of devices) {
  // Resize viewport
  await page.setViewportSize({ width: device.width, height: device.height });
  
  // Navigate
  await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
  
  // Take screenshot
  const buf = await page.screenshot();
  const path = await saveScreenshot(buf, `layout-${device.name}.png`);
  
  console.log(`${device.name}: ${path}`);
}
```

### Network Condition Testing

```javascript
const page = await browser.getPage("perf");

// Test on slow network
await page.context().setNetworkCondition({
  download: 50 * 1024,      // 50 kbps
  upload: 20 * 1024,        // 20 kbps
  latency: 400              // 400ms latency
});

const startTime = Date.now();
await page.goto("http://localhost:5173");
const loadTime = Date.now() - startTime;

console.log(`Load time on slow 3G: ${loadTime}ms`);
```

## Data Extraction

### Extract Table Data

```javascript
const page = await browser.getPage("table");
await page.goto("http://localhost:5173/results");

const tableData = await page.$$eval("table tbody tr", rows => {
  return rows.map(row => {
    const cells = row.querySelectorAll("td");
    return {
      id: cells[0]?.textContent,
      name: cells[1]?.textContent,
      status: cells[2]?.textContent,
      timestamp: cells[3]?.textContent
    };
  });
});

const jsonPath = await writeFile("table-data.json", JSON.stringify(tableData, null, 2));
console.log(`Extracted ${tableData.length} rows: ${jsonPath}`);
```

### Extract Page Metadata

```javascript
const page = await browser.getPage("metadata");
await page.goto("http://localhost:5173");

const metadata = await page.evaluate(() => {
  return {
    title: document.title,
    description: document.querySelector("meta[name='description']")?.content,
    og_title: document.querySelector("meta[property='og:title']")?.content,
    og_image: document.querySelector("meta[property='og:image']")?.content,
    canonical: document.querySelector("link[rel='canonical']")?.href,
    headings: Array.from(document.querySelectorAll("h1, h2, h3")).map(h => ({
      level: h.tagName,
      text: h.textContent
    }))
  };
});

console.log(JSON.stringify(metadata, null, 2));
```

## State Management & Persistence

### Maintain Session State Across Scripts

```javascript
// Script 1: Login and save cookies
const page = await browser.getPage("app");
await page.goto("http://localhost:5173/login");
await page.fill("input[name='email']", "user@example.com");
await page.fill("input[name='password']", "password123");
await page.click("button[type='submit']");
await page.waitForURL("**/dashboard");
console.log("Logged in successfully");

// Script 2: Later, reconnect to same page (state preserved)
const page2 = await browser.getPage("app");
console.log("Still on:", page2.url());  // Shows /dashboard
// Can continue without re-login
await page2.goto("http://localhost:5173/settings");
```

### Save and Restore Snapshots

```javascript
// Save current state
const page = await browser.getPage("workflow");
await page.goto("http://localhost:5173/complex-form");

// Fill form partially
await page.fill("input[name='step1']", "value1");
const snapshot = await page.snapshotForAI({ track: "form" });
await writeFile("form-state.md", snapshot.full);
console.log("State snapshot saved");

// Later: Verify state changed
const page2 = await browser.getPage("workflow");
const newSnapshot = await page2.snapshotForAI({ track: "form" });
const oldSnapshot = await readFile("form-state.md");
console.log("Form state changed:", snapshot.full !== oldSnapshot);
```

## Error Handling & Validation

### Comprehensive Error Handling

```javascript
async function testFeature(featureName, testFn) {
  const page = await browser.getPage(featureName);
  
  try {
    await testFn(page);
    console.log(`✅ ${featureName}: PASSED`);
    return true;
  } catch (error) {
    // Take screenshot
    const buf = await page.screenshot();
    const screenshot = await saveScreenshot(buf, `error-${featureName}.png`);
    
    // Log detailed error
    const errorReport = {
      feature: featureName,
      error: error.message,
      stack: error.stack,
      url: page.url(),
      screenshot: screenshot
    };
    
    await writeFile(`error-${featureName}.json`, JSON.stringify(errorReport, null, 2));
    console.error(`❌ ${featureName}: FAILED`, JSON.stringify(errorReport));
    return false;
  }
}

// Usage
await testFeature("upload-feature", async (page) => {
  await page.goto("http://localhost:5173");
  await page.locator("input[type='file']").setInputFiles("./test.wav");
  await page.waitForSelector(".success-message", { timeout: 5000 });
});
```

### Validation Assertions

```javascript
const page = await browser.getPage("validation");
await page.goto("http://localhost:5173");

const assertions = {
  titleCorrect: await page.title() === "WAV Transcriber",
  headerVisible: await page.locator("h1").isVisible(),
  uploadZonePresent: (await page.locator(".drag-drop").count()) === 1,
  debugMessageShown: (await page.locator(".debug-message").count()) > 0,
  attributesSet: await page.evaluate(() => {
    const btn = document.querySelector("button");
    return btn && btn.hasAttribute("aria-label");
  })
};

const passed = Object.values(assertions).filter(v => v).length;
const total = Object.keys(assertions).length;
console.log(`Assertions: ${passed}/${total} passed`);

if (passed < total) {
  const buf = await page.screenshot();
  const path = await saveScreenshot(buf, "validation-failure.png");
  console.error(`Validation failed. See: ${path}`);
}
```

## Performance Monitoring

### Measure Load Performance

```javascript
const page = await browser.getPage("perf");

const metrics = await page.evaluate(() => {
  const perfEntries = performance.getEntriesByType("navigation");
  if (perfEntries.length === 0) return null;
  
  const nav = perfEntries[0];
  return {
    domContentLoaded: nav.domContentLoadedEventEnd - nav.domContentLoadedEventStart,
    loadTime: nav.loadEventEnd - nav.loadEventStart,
    timeToFirstByte: nav.responseStart - nav.requestStart,
    timeToFirstPaint: performance.getEntriesByType("paint")[0]?.startTime || 0
  };
});

console.log("Performance metrics:", JSON.stringify(metrics));
```

### Monitor Network Requests

```javascript
const page = await browser.getPage("network");

// Track all network requests
const requests = [];
page.on("response", response => {
  requests.push({
    url: response.url(),
    status: response.status(),
    contentType: response.headers()["content-type"],
    timestamp: new Date().toISOString()
  });
});

await page.goto("http://localhost:5173");

// Analyze network
const failed = requests.filter(r => r.status >= 400);
const byType = {};
for (const req of requests) {
  const type = req.contentType?.split("/")[0] || "unknown";
  byType[type] = (byType[type] || 0) + 1;
}

console.log(JSON.stringify({
  totalRequests: requests.length,
  failedRequests: failed.length,
  byContentType: byType,
  failures: failed
}));
```
