<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950 overflow-hidden relative">
    <!-- Animated background elements -->
    <div class="fixed inset-0 pointer-events-none">
      <div class="absolute top-20 left-20 w-72 h-72 bg-purple-500/20 rounded-full mix-blend-multiply filter blur-3xl animate-blob"></div>
      <div class="absolute top-40 right-20 w-72 h-72 bg-blue-500/20 rounded-full mix-blend-multiply filter blur-3xl animate-blob animation-delay-2000"></div>
      <div class="absolute -bottom-8 left-1/2 w-72 h-72 bg-pink-500/20 rounded-full mix-blend-multiply filter blur-3xl animate-blob animation-delay-4000"></div>
    </div>

    <!-- Main container -->
    <div class="relative z-10 min-h-screen flex items-center justify-center p-6">
      <div class="w-full max-w-2xl">
        <!-- Debug Hint -->
        <div v-if="debugMessage" class="mb-6 text-center text-xs text-cyan-400 font-mono bg-cyan-400/10 border border-cyan-400/30 rounded-lg px-4 py-2 inline-block mx-auto">
          DEBUG: {{ debugMessage }}
        </div>

        <!-- Header -->
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold mb-2 bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
            WAV Transcriber
          </h1>
          <p class="text-lg text-slate-300">Transform audio to text with AI-powered transcription</p>
        </div>

        <!-- Main card with liquid glass effect -->
        <div class="backdrop-blur-xl bg-white/10 rounded-3xl border border-white/20 shadow-2xl p-8 space-y-8">

          <!-- Drag and drop zone -->
          <div
            v-if="!selectedFile"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleDrop"
            :class="[
              'relative border-2 border-dashed rounded-2xl p-12 transition-all duration-300 cursor-pointer',
              isDragging
                ? 'border-cyan-400 bg-cyan-400/10 scale-105'
                : 'border-white/30 bg-white/5 hover:bg-white/10'
            ]"
          >
            <input
              type="file"
              accept=".wav"
              @change="handleFileInput"
              class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />

            <div class="flex flex-col items-center justify-center space-y-4">
              <div class="relative">
                <svg class="w-16 h-16 text-cyan-400 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 19V5m0 0l-7 7m7-7l7 7" />
                </svg>
                <div v-if="isDragging" class="absolute inset-0 animate-ping opacity-75">
                  <div class="w-16 h-16 bg-cyan-400 rounded-full"></div>
                </div>
              </div>
              <div class="text-center">
                <p class="text-xl font-semibold text-white mb-2">Drag & drop your WAV file</p>
                <p class="text-sm text-slate-400">or click to browse your computer</p>
              </div>
              <div class="flex gap-2 mt-4">
                <span class="px-3 py-1 rounded-full bg-purple-500/30 text-purple-200 text-xs font-medium">.wav</span>
                <span class="px-3 py-1 rounded-full bg-cyan-500/30 text-cyan-200 text-xs font-medium">AI Powered</span>
              </div>
            </div>
          </div>

          <!-- File selected state -->
          <div v-else class="space-y-6">
            <!-- File info card -->
            <div class="backdrop-blur-lg bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-2xl border border-white/20 p-6">
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                  <div class="p-3 rounded-xl bg-cyan-400/20 border border-cyan-400/50">
                    <svg class="w-6 h-6 text-cyan-400" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M9 19V5h1v14H9zm5-4v-4h1v4h-1z"/>
                    </svg>
                  </div>
                  <div>
                    <p class="font-semibold text-white">{{ selectedFile.name }}</p>
                    <p class="text-sm text-slate-400">{{ (selectedFile.size / 1024).toFixed(2) }} KB</p>
                  </div>
                </div>
                <button
                  @click="resetForm"
                  class="px-4 py-2 rounded-lg text-slate-300 hover:text-white hover:bg-white/10 transition-colors"
                >
                  Change
                </button>
              </div>
            </div>

            <!-- Transcription status and result -->
            <div v-if="!transcriptionDone" class="space-y-4">
              <!-- Transcribe button -->
              <button
                @click="transcribeFile"
                :disabled="isTranscribing"
                :class="[
                  'w-full py-4 px-6 rounded-xl font-semibold text-white transition-all duration-300 flex items-center justify-center gap-3',
                  isTranscribing
                    ? 'bg-gradient-to-r from-slate-600 to-slate-700 cursor-not-allowed opacity-70'
                    : 'bg-gradient-to-r from-cyan-500 to-purple-500 hover:shadow-lg hover:shadow-cyan-500/50 active:scale-95'
                ]"
              >
                <svg v-if="!isTranscribing" class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z"/>
                </svg>
                <svg v-else class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ isTranscribing ? 'Transcribing...' : 'Transcribe' }}
              </button>

              <!-- Progress indicator -->
              <div v-if="isTranscribing" class="space-y-3">
                <div class="h-1 bg-white/10 rounded-full overflow-hidden">
                  <div class="h-full bg-gradient-to-r from-cyan-500 to-purple-500 animate-pulse"></div>
                </div>
                <p class="text-center text-sm text-slate-400">{{ transriptionMessage }}</p>
              </div>

              <!-- Error message -->
              <div v-if="error" class="p-4 rounded-xl bg-red-500/20 border border-red-500/50 text-red-200 text-sm">
                {{ error }}
              </div>
            </div>

            <!-- Transcription result -->
            <div v-else class="space-y-4">
              <div class="backdrop-blur-lg bg-gradient-to-br from-slate-800/50 to-slate-700/50 rounded-2xl border border-white/10 p-6 max-h-80 overflow-y-auto">
                <p class="text-white leading-relaxed whitespace-pre-wrap">{{ transcriptionText }}</p>
              </div>

              <!-- Action buttons -->
              <div class="grid grid-cols-2 gap-3">
                <button
                  @click="copyToClipboard"
                  :class="[
                    'py-3 px-4 rounded-xl font-semibold transition-all duration-300 flex items-center justify-center gap-2',
                    copiedToClipboard
                      ? 'bg-green-500/30 text-green-300 border border-green-500/50'
                      : 'bg-white/10 text-white hover:bg-white/20 border border-white/20'
                  ]"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                  {{ copiedToClipboard ? 'Copied!' : 'Copy' }}
                </button>
                <button
                  @click="downloadAsText"
                  class="py-3 px-4 rounded-xl font-semibold bg-gradient-to-r from-cyan-500 to-purple-500 text-white hover:shadow-lg hover:shadow-cyan-500/50 transition-all duration-300 flex items-center justify-center gap-2 active:scale-95"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                  Save
                </button>
              </div>

              <!-- Start over button -->
              <button
                @click="resetForm"
                class="w-full py-2 px-4 rounded-xl text-slate-300 hover:text-white hover:bg-white/10 transition-colors text-sm"
              >
                Transcribe Another File
              </button>
            </div>
          </div>

          <!-- Footer -->
          <div class="pt-6 border-t border-white/10 text-center text-sm text-slate-400">
            <p>Powered by OpenAI Whisper • Supports WAV format</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const selectedFile = ref(null)
const isDragging = ref(false)
const isTranscribing = ref(false)
const transcriptionDone = ref(false)
const transcriptionText = ref('')
const error = ref('')
const copiedToClipboard = ref(false)
const transriptionMessage = ref('Processing your audio...')
const debugMessage = ref('')

const API_BASE_URL = 'http://localhost:8000'

// Fetch debug message on mount
onMounted(async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/debug`)
    if (response.ok) {
      const data = await response.json()
      if (data.debug_enabled && data.debug_message) {
        debugMessage.value = data.debug_message
      }
    }
  } catch (err) {
    // Debug fetch failed, silently continue
  }
})

const handleDrop = (e) => {
  isDragging.value = false
  const files = e.dataTransfer.files
  if (files.length > 0) {
    const file = files[0]
    if (file.type === 'audio/wav' || file.name.endsWith('.wav')) {
      selectedFile.value = file
      error.value = ''
    } else {
      error.value = 'Please select a WAV file'
    }
  }
}

const handleFileInput = (e) => {
  const files = e.target.files
  if (files.length > 0) {
    selectedFile.value = files[0]
    error.value = ''
  }
}

const transcribeFile = async () => {
  if (!selectedFile.value) return

  isTranscribing.value = true
  error.value = ''
  transriptionMessage.value = 'Processing your audio...'

  const formData = new FormData()
  formData.append('file', selectedFile.value)

  try {
    const response = await fetch(`${API_BASE_URL}/transcribe`, {
      method: 'POST',
      body: formData,
    })

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.detail || 'Transcription failed')
    }

    const data = await response.json()
    transcriptionText.value = data.text
    transcriptionDone.value = true
  } catch (err) {
    error.value = err.message || 'Failed to transcribe. Make sure the backend is running.'
    console.error('Transcription error:', err)
  } finally {
    isTranscribing.value = false
  }
}

const copyToClipboard = async () => {
  try {
    await navigator.clipboard.writeText(transcriptionText.value)
    copiedToClipboard.value = true
    setTimeout(() => {
      copiedToClipboard.value = false
    }, 2000)
  } catch (err) {
    error.value = 'Failed to copy to clipboard'
    console.error('Copy error:', err)
  }
}

const downloadAsText = () => {
  const element = document.createElement('a')
  const file = new Blob([transcriptionText.value], { type: 'text/plain' })
  element.href = URL.createObjectURL(file)
  element.download = `${selectedFile.value.name.replace('.wav', '')}_transcription.txt`
  document.body.appendChild(element)
  element.click()
  document.body.removeChild(element)
}

const resetForm = () => {
  selectedFile.value = null
  transcriptionDone.value = false
  transcriptionText.value = ''
  error.value = ''
  copiedToClipboard.value = false
  isTranscribing.value = false
}
</script>
