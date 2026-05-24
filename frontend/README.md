# WAV Transcriber Frontend

A futuristic, liquid glass UI for audio transcription with drag-and-drop support.

## Tech Stack

- **Vue 3** - Progressive JavaScript framework
- **Vite** - Next generation frontend tooling
- **Tailwind CSS** - Utility-first CSS framework
- **JavaScript** - Modern ES6+

## Features

- 🎨 **Liquid Glass Design** - Glassmorphism effect with backdrop blur
- 🎯 **Drag & Drop** - Intuitive file selection with haptic feedback animations
- ⚡ **Responsive** - Works seamlessly on desktop and tablet
- 📋 **Export Options** - Copy to clipboard or download as `.txt`
- 🎬 **Smooth Animations** - Animated blobs and state transitions
- 🔄 **Real-time Feedback** - Live transcription status updates

## Development

### Install Dependencies
```bash
npm install
```

### Run Development Server
```bash
npm run dev
```
Server runs on: `http://localhost:5173`

### Build for Production
```bash
npm run build
```
Output: `dist/` directory

### Preview Production Build
```bash
npm run preview
```

## API Integration

The frontend communicates with the backend API at `http://localhost:8000`:

- **POST /transcribe** - Upload and transcribe a WAV file
- **POST /transcribe-local** - Transcribe a local file path
- **GET /health** - Health check

## File Structure

```
frontend/
├── src/
│   ├── App.vue          # Main application component
│   ├── main.js          # Entry point
│   └── styles/
│       └── index.css    # Global styles with Tailwind
├── index.html           # HTML entry point
├── vite.config.js       # Vite configuration
├── tailwind.config.js   # Tailwind CSS configuration
├── postcss.config.js    # PostCSS configuration
└── package.json         # Dependencies
```

## Customization

### Colors
Edit `tailwind.config.js` to customize the color palette. The app uses:
- `slate-950` - Dark background
- `cyan-400` - Primary accent
- `purple-400` - Secondary accent
- `pink-400` - Tertiary accent

### Animations
CSS animations are defined in `src/styles/index.css`. Key animations:
- `animate-blob` - Floating background elements
- `animate-ping` - Pulsing drag zone indicator
- `animate-pulse` - Subtle pulsing effects

### API Endpoint
To change the backend URL, edit `API_BASE_URL` in `src/App.vue`
