# WAV Transcriber UI - Complete Feature Guide

## 🎨 Visual Design

### Liquid Glass Effect (Glassmorphism)
The UI uses a premium liquid glass design with:
- **Backdrop blur**: Frosted glass effect with `backdrop-filter: blur(16px)`
- **Semi-transparent backgrounds**: `bg-white/10` for depth
- **Gradient borders**: `border-white/20` for elegant outlines
- **Layered animations**: Floating background blobs create movement

### Color Scheme
- **Dark background**: `from-slate-950 via-purple-950 to-slate-950`
- **Primary accent**: `cyan-400` (bright cyan)
- **Secondary accent**: `purple-400` (soft purple)
- **Tertiary accent**: `pink-400` (warm pink)
- **Text**: White and slate-300 for contrast

### Animation Effects
1. **Floating Blobs**: Background elements animate continuously
   - Purple blob (top-left)
   - Blue blob (top-right)
   - Pink blob (bottom-center)
   - Duration: 7 seconds each
   - Offset staggering for visual interest

2. **Drag Zone Animations**:
   - Smooth scale-up when hovering: `scale-105`
   - Ping animation on drag: `animate-ping`
   - Border color change: `border-cyan-400`
   - Background glow: `bg-cyan-400/10`

3. **Button Interactions**:
   - Active state: `active:scale-95` (press effect)
   - Hover shadow: `hover:shadow-cyan-500/50`
   - Smooth transitions: `transition-all duration-300`

4. **Status Indicators**:
   - Pulse animation for loading
   - Progress bar fade
   - Spinning loader for processing

## 🎯 User Interface Sections

### 1. Header
- **Title**: "WAV Transcriber" with gradient text
- **Subtitle**: "Transform audio to text with AI-powered transcription"
- **Style**: Centered, large typography

### 2. Drag & Drop Zone (Initial State)
```
┌─────────────────────────────────────┐
│  📤                                 │
│  Drag & drop your WAV file          │
│  or click to browse your computer   │
│                                     │
│  .wav    AI Powered                │
└─────────────────────────────────────┘
```

**Features**:
- Upload icon with pulse animation
- Descriptive text
- Feature tags at bottom
- Click anywhere to open file browser
- Drag files onto the zone
- Visual feedback on drag

### 3. File Selected State
Shows:
- **File info card**: Name, file size, change button
- **Transcribe button**: Gradient button with play icon
- **Progress bar**: Animated during transcription
- **Status message**: "Processing your audio..."
- **Error display**: Red box with error message if needed

### 4. Transcription Result State
Shows:
- **Result text box**: Scrollable with transcribed text
- **Copy button**: Click to copy to clipboard (shows "Copied!" when successful)
- **Save button**: Download as `.txt` file
- **Start Over button**: Reset to upload another file

### 5. Footer
- **Credit line**: "Powered by OpenAI Whisper • Supports WAV format"
- **Separator**: Subtle border-top line

## ✨ Interactive Features

### Drag & Drop
```
User drags WAV file → Zone expands & glows cyan → Icon pings
User drops → File selected → "Change" button appears
```

**Haptic feedback simulation**:
- Scale animation on drag-over
- Color change (dashed border becomes cyan)
- Ping animation (expanding circle effect)
- All transitions are smooth (300ms duration)

### File Selection Flow
```
1. Drag file OR click to browse
2. File selected → Show file info
3. Click "Transcribe" → Show progress
4. Transcription completes → Show result text
5. Click "Copy" or "Save" → Download/clipboard
6. Click "Transcribe Another" → Reset
```

### Button States

#### Transcribe Button
- **Idle**: Gradient cyan-to-purple, cursor pointer
- **Hovering**: Adds cyan glow shadow
- **Pressing**: Scales down 95%
- **Transcribing**: Disabled, shows spinner
- **Complete**: Hidden, result shown instead

#### Copy Button
- **Idle**: Translucent white background
- **Hovering**: Slightly more opaque
- **Success**: Changes to green with "Copied!" text for 2 seconds
- **Tooltip**: Icon shows clipboard symbol

#### Save Button
- **Idle**: Gradient cyan-to-purple
- **Hovering**: Glowing shadow effect
- **Pressing**: Scales down 95%
- **Action**: Downloads file as `{filename}_transcription.txt`

## 📱 Responsive Design

The interface adapts to different screen sizes:

### Desktop (Full Width)
- Card at center
- Full animations visible
- Optimal button spacing

### Tablet
- Slightly narrower container
- Touch-friendly button sizes
- All features fully accessible

### Mobile
- Stack layout maintained
- Large touch targets
- Drag & drop still functional

## 🎬 Animation Timing

| Effect | Duration | Timing |
|--------|----------|--------|
| Background blobs | 7s | Infinite, staggered |
| Button scale-up | 300ms | Cubic bezier |
| Button scale-down | 100ms | Instant on click |
| Glow shadow | 300ms | Smooth transition |
| "Copied!" feedback | 2s | Auto-dismiss |
| Color changes | 300ms | All transitions smooth |
| Progress bar | Continuous | Pulsing opacity |

## 🔄 State Management

### States & Transitions
```
Initial
  ↓ (file selected)
File Selected
  ↓ (click transcribe)
Transcribing
  ↓ (transcription complete)
Result Shown
  ↓ (click "Transcribe Another")
Initial (reset)
  ↓ (on error)
Error Display (stays in File Selected)
```

## 🌐 API Integration

### Frontend ↔ Backend Communication

```javascript
// Upload file
POST /transcribe
├─ Input: File (WAV)
└─ Output: {
    status: "success",
    filename: "audio.wav",
    text: "Transcribed text..."
  }

// Error handling
├─ AudioError: Shows red error box
├─ TranscriptionError: Shows red error box
└─ Unknown error: Shows generic error message
```

**User sees**:
- Progress bar while uploading
- "Processing your audio..." message
- Real-time status updates
- Clear error messages with advice

## 🎨 Customization Points

### Colors
Edit `frontend/tailwind.config.js`:
```javascript
colors: {
  cyan: '#06b6d4',      // Primary
  purple: '#a855f7',    // Secondary
  pink: '#ec4899',      // Tertiary
  slate: { 950: '#030712' } // Background
}
```

### Animations
Edit `frontend/src/styles/index.css`:
```css
@keyframes blob {
  /* Modify animation keyframes */
}
```

### Text
Edit `frontend/src/App.vue`:
```vue
<h1>Custom Title</h1>
<p>Custom subtitle</p>
```

### Layout
Modify `padding`, `width`, `max-width` in App.vue template

## 📊 User Experience Flow

### First-Time User
1. Sees beautiful liquid glass UI
2. Understands "drag & drop" from visual cues
3. Drags a WAV file → Gets instant feedback
4. Clicks transcribe → Sees progress
5. Gets result → Copies or downloads
6. ✅ Success!

### Power User
1. Batch transcribe multiple files
2. CLI for automation: `python -m wav_transcriber transcribe *.wav`
3. Integrates with other tools
4. Uses exported `.txt` files in documents

## 🎯 Performance

- **Frontend**: Instant response, smooth 60fps animations
- **Backend**: Async processing, non-blocking file handling
- **No lag**: Even with large audio files (≤500MB)

## ✅ Accessibility

- **Clear labels**: All buttons have descriptive text/icons
- **Error messages**: Red, clear, actionable
- **Keyboard accessible**: Tab navigation works
- **Mobile friendly**: Touch-friendly button sizes
- **High contrast**: Cyan/purple on dark background

## 🎉 Polish Details

1. **Rounded corners**: `rounded-2xl` and `rounded-3xl` for modern look
2. **Subtle shadows**: `shadow-2xl` for depth
3. **Consistent spacing**: 8px grid system
4. **Smooth transitions**: All 300ms duration
5. **Icon coherence**: All SVG icons match style
6. **Typography**: Careful font sizing and weight
7. **Color harmony**: Gradient text and backgrounds
8. **Consistent states**: Hover/active states everywhere

---

This UI provides a professional, modern experience that makes transcription feel effortless and enjoyable!
