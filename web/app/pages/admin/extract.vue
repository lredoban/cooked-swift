<script setup lang="ts">
const url = ref('')
const mode = ref<'info' | 'audio' | 'video'>('info')
const loading = ref(false)
const result = ref<unknown>(null)
const error = ref('')

// Audio options
const audioFormat = ref('mp3')
const audioQuality = ref('5')

// Video options
const videoQuality = ref('best')
const videoFormat = ref('mp4')

const flatPlaylist = ref(true)

const audioFormats = ['mp3', 'wav', 'flac', 'm4a', 'opus', 'vorbis', 'aac', 'alac']
const videoQualities = ['best', '2160p', '1440p', '1080p', '720p', '480p', '360p', '240p', '144p']
const videoFormats = ['mp4', 'webm']

async function extract() {
  if (!url.value) return

  loading.value = true
  result.value = null
  error.value = ''

  try {
    const body: Record<string, unknown> = {
      url: url.value,
      mode: mode.value,
      flatPlaylist: flatPlaylist.value,
    }

    if (mode.value === 'audio') {
      body.audioFormat = audioFormat.value
      body.audioQuality = audioQuality.value
    }

    if (mode.value === 'video') {
      body.videoQuality = videoQuality.value
      body.videoFormat = videoFormat.value
    }

    const data = await $fetch('/api/extract', {
      method: 'POST',
      body,
    })
    result.value = data
  }
  catch (e: unknown) {
    const err = e as { data?: { message?: string }, message?: string }
    error.value = err.data?.message || err.message || 'Unknown error'
  }
  finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="max-w-4xl mx-auto p-6 space-y-6">
    <h1 class="text-2xl font-bold">
      yt-dlp Extract Tester
    </h1>

    <!-- URL Input -->
    <UFormField label="URL">
      <UInput
        v-model="url"
        placeholder="https://www.youtube.com/watch?v=..."
        class="w-full"
      />
    </UFormField>

    <!-- Mode Selection -->
    <UFormField label="Mode">
      <URadioGroup
        v-model="mode"
        :items="[
          { label: 'Info only', value: 'info' },
          { label: 'Audio', value: 'audio' },
          { label: 'Video', value: 'video' },
        ]"
        orientation="horizontal"
      />
    </UFormField>

    <!-- Audio Options -->
    <div v-if="mode === 'audio'" class="space-y-4 p-4 border rounded-lg">
      <h2 class="font-semibold">
        Audio Options
      </h2>
      <div class="grid grid-cols-2 gap-4">
        <UFormField label="Format">
          <USelect v-model="audioFormat" :items="audioFormats" />
        </UFormField>
        <UFormField label="Quality (0=best, 10=worst)">
          <UInput v-model="audioQuality" type="number" min="0" max="10" />
        </UFormField>
      </div>
    </div>

    <!-- Video Options -->
    <div v-if="mode === 'video'" class="space-y-4 p-4 border rounded-lg">
      <h2 class="font-semibold">
        Video Options
      </h2>
      <div class="grid grid-cols-2 gap-4">
        <UFormField label="Quality">
          <USelect v-model="videoQuality" :items="videoQualities" />
        </UFormField>
        <UFormField label="Format">
          <USelect v-model="videoFormat" :items="videoFormats" />
        </UFormField>
      </div>
    </div>

    <!-- Playlist Option -->
    <UCheckbox v-model="flatPlaylist" label="Flat playlist (skip individual video details)" />

    <!-- Submit -->
    <UButton :loading="loading" :disabled="!url" size="lg" @click="extract">
      Extract
    </UButton>

    <!-- Error -->
    <UAlert v-if="error" color="error" :title="error" />

    <!-- Result -->
    <div v-if="result" class="space-y-2">
      <h2 class="font-semibold">
        Result
      </h2>
      <pre class="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-auto max-h-[600px] text-sm">{{ JSON.stringify(result, null, 2) }}</pre>
    </div>
  </div>
</template>
