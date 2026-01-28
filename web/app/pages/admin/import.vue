<script setup lang="ts">
definePageMeta({
  middleware: 'dev-only'
})

const config = useRuntimeConfig()
const { copy, copied } = useClipboard()

// Auth state
const email = ref(config.public.devEmail || '')
const password = ref(config.public.devPassword || '')
const token = useLocalStorage('token', '')
const userId = useLocalStorage('userId', '')
const authLoading = ref(false)
const authError = ref('')

async function signIn() {
  authLoading.value = true
  authError.value = ''
  try {
    const data = await $fetch('/api/admin/auth', {
      method: 'POST',
      body: { email: email.value, password: password.value }
    })
    token.value = data.access_token
    userId.value = data.user_id
  } catch (e: unknown) {
    const err = e as { data?: { message?: string }; message?: string }
    authError.value = err.data?.message || err.message || 'Auth failed'
  } finally {
    authLoading.value = false
  }
}

// Import state
const url = ref('')
const sourceType = ref('auto')
const importLoading = ref(false)
const importError = ref('')
const importResult = ref<Record<string, unknown> | null>(null)

// SSE state
const sseUrl = ref<string | undefined>()
const sseEvents = ref<Array<{ type: string; data: unknown; time: string }>>([])
const extractedRecipe = ref<Record<string, unknown> | null>(null)

const {
  status: sseStatus,
  data: sseData,
  event: sseEvent,
  close: sseClose,
  open: sseOpen,
  eventSource
} = useEventSource(sseUrl, ['test', 'progress', 'complete', 'error'], {
  autoReconnect: false,
  immediate: false
})

watch(sseData, () => {
  if (!sseEvent.value || !sseData.value) return
  const time = new Date().toLocaleTimeString('en-US', {
    hour12: false,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
  let parsed: unknown
  try {
    parsed = JSON.parse(sseData.value)
  } catch {
    parsed = sseData.value
  }

  sseEvents.value.push({ type: sseEvent.value, data: parsed, time })

  if (sseEvent.value === 'complete') {
    extractedRecipe.value = parsed as Record<string, unknown>
    sseClose()
  }
  if (sseEvent.value === 'error') {
    sseClose()
  }
})

const sourceTypes = ['auto', 'video', 'url']

async function importRecipe() {
  if (!url.value || !token.value) return

  importLoading.value = true
  importError.value = ''
  importResult.value = null
  sseClose()
  sseUrl.value = undefined
  sseEvents.value = []
  extractedRecipe.value = null

  try {
    const body: Record<string, unknown> = { url: url.value }
    if (sourceType.value !== 'auto') {
      body.source_type = sourceType.value
    }

    const data = await $fetch<Record<string, unknown>>('/api/recipes/import', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token.value}` },
      body
    })
    importResult.value = data
    importLoading.value = false

    // Auto-connect to SSE stream via useEventSource
    if (data.recipe_id) {
      sseUrl.value = `/api/recipes/${data.recipe_id}/stream?token=${token.value}`
      sseOpen()
    }
  } catch (e: unknown) {
    const err = e as { data?: { message?: string }; message?: string }
    importError.value = err.data?.message || err.message || 'Import failed'
    importLoading.value = false
  }
}

function eventColor(type: string) {
  if (type === 'complete') return 'success'
  if (type === 'error') return 'error'
  if (type === 'test') return 'neutral'
  return 'info'
}

function signOut() {
  token.value = ''
  userId.value = ''
}
</script>

<template>
  <div class="mx-auto max-w-4xl space-y-6 p-6">
    <h1 class="text-2xl font-bold">Recipe Import Tester</h1>

    <!-- Auth Section -->
    <div class="space-y-3 rounded-lg border p-4">
      <h2 class="font-semibold">Authentication</h2>
      <div v-if="!token" class="space-y-3">
        <div class="grid grid-cols-2 gap-4">
          <UFormField label="Email">
            <UInput v-model="email" type="email" placeholder="dev@example.com" />
          </UFormField>
          <UFormField label="Password">
            <UInput v-model="password" type="password" placeholder="password" />
          </UFormField>
        </div>
        <UButton :loading="authLoading" :disabled="!email || !password" @click="signIn">
          Sign In
        </UButton>
        <UAlert v-if="authError" color="error" :title="authError" />
      </div>
      <div v-else class="items flex items-center justify-between gap-4">
        <UBadge color="success" variant="subtle"> Authenticated </UBadge>
        <span class="font-mono text-xs text-neutral-500">user ID: {{ userId }}</span>
        <div class="flex items-center">
          <span class="font-mono text-xs text-neutral-400">token: {{ token.slice(0, 20) }}...</span>
          <UTooltip text="Copy to clipboard" :content="{ side: 'right' }">
            <UButton
              :color="copied ? 'success' : 'neutral'"
              variant="link"
              size="sm"
              :icon="copied ? 'i-lucide-copy-check' : 'i-lucide-copy'"
              aria-label="Copy to clipboard"
              @click="copy(token)"
            />
          </UTooltip>
        </div>

        <UButton variant="ghost" size="xs" color="error" @click="signOut"> Sign Out </UButton>
      </div>
    </div>

    <!-- Import Section -->
    <ClientOnly>
      <div class="space-y-3 rounded-lg border p-4">
        <h2 class="font-semibold">Import Recipe</h2>
        <div class="flex items-end gap-4">
          <UFormField label="URL" class="flex-1">
            <UInput
              v-model="url"
              placeholder="https://www.youtube.com/watch?v=... or any recipe URL"
              :disabled="!token"
            />
          </UFormField>
          <UFormField label="Source type">
            <USelect v-model="sourceType" :items="sourceTypes" :disabled="!token" />
          </UFormField>
          <UButton :loading="importLoading" :disabled="!url || !token" @click="importRecipe">
            Import
          </UButton>
        </div>
      </div>
    </ClientOnly>

    <!-- Import Response -->
    <div v-if="importResult" class="space-y-2 rounded-lg border p-4">
      <h2 class="font-semibold">Import Response</h2>
      <div class="grid grid-cols-2 gap-x-6 gap-y-1 text-sm">
        <div>
          <span class="text-neutral-500">recipe_id:</span>
          <span class="font-mono">{{ importResult.recipe_id }}</span>
        </div>
        <div>
          <span class="text-neutral-500">platform:</span>
          <UBadge variant="subtle" size="sm">{{ importResult.platform }}</UBadge>
        </div>
        <div><span class="text-neutral-500">title:</span> {{ importResult.title }}</div>
        <div><span class="text-neutral-500">source:</span> {{ importResult.source_name }}</div>
      </div>
      <img
        v-if="importResult.image_url"
        :src="importResult.image_url as string"
        class="mt-2 h-32 rounded-lg object-cover"
      />
    </div>

    <!-- Import Error -->
    <UAlert v-if="importError" color="error" :title="importError" />

    <!-- SSE Stream Log -->
    <div v-if="sseEvents.length || sseStatus !== 'CLOSED'" class="space-y-2 rounded-lg border p-4">
      <div class="flex items-center gap-2">
        <h2 class="font-semibold">SSE Stream</h2>
        <UBadge v-if="sseStatus === 'OPEN'" color="info" variant="subtle" size="sm">
          Connected
        </UBadge>
        <UBadge v-else-if="sseStatus === 'CONNECTING'" color="warning" variant="subtle" size="sm">
          Connecting
        </UBadge>
        <UBadge v-else-if="sseEvents.length" color="neutral" variant="subtle" size="sm">
          Closed
        </UBadge>
      </div>
      <div class="space-y-1">
        <div
          v-for="(evt, i) in sseEvents"
          :key="i"
          class="flex items-start gap-2 font-mono text-sm"
        >
          <span class="text-neutral-400">{{ evt.time }}</span>
          <UBadge :color="eventColor(evt.type)" variant="subtle" size="sm">{{ evt.type }}</UBadge>
          <span class="break-all text-neutral-300">
            {{ typeof evt.data === 'object' ? JSON.stringify(evt.data) : evt.data }}
          </span>
        </div>
      </div>
    </div>

    <!-- Extracted Recipe -->
    <div v-if="extractedRecipe" class="space-y-4 rounded-lg border p-4">
      <h2 class="font-semibold">Extracted Recipe</h2>

      <div v-if="(extractedRecipe.ingredients as unknown[])?.length">
        <h3 class="mb-1 text-sm font-medium text-neutral-400">Ingredients</h3>
        <ul class="list-inside list-disc space-y-0.5 text-sm">
          <li v-for="(ing, i) in extractedRecipe.ingredients as Array<{ name?: string }>" :key="i">
            {{ typeof ing === 'string' ? ing : ing.name || JSON.stringify(ing) }}
          </li>
        </ul>
      </div>

      <div v-if="(extractedRecipe.steps as unknown[])?.length">
        <h3 class="mb-1 text-sm font-medium text-neutral-400">Steps</h3>
        <ol class="list-inside list-decimal space-y-0.5 text-sm">
          <li v-for="(step, i) in extractedRecipe.steps as string[]" :key="i">{{ step }}</li>
        </ol>
      </div>

      <div v-if="(extractedRecipe.tags as unknown[])?.length">
        <h3 class="mb-1 text-sm font-medium text-neutral-400">Tags</h3>
        <div class="flex flex-wrap gap-1">
          <UBadge
            v-for="tag in extractedRecipe.tags as string[]"
            :key="tag"
            variant="subtle"
            size="sm"
          >
            {{ tag }}
          </UBadge>
        </div>
      </div>

      <details>
        <summary class="cursor-pointer text-sm text-neutral-400">Raw JSON</summary>
        <pre class="mt-2 max-h-96 overflow-auto rounded-lg bg-gray-900 p-4 text-xs text-gray-100">{{
          JSON.stringify(extractedRecipe, null, 2)
        }}</pre>
      </details>
    </div>
  </div>
</template>
