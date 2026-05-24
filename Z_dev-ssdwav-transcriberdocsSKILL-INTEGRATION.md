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
