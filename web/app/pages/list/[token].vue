<script setup lang="ts">
import type { RealtimeChannel } from '@supabase/supabase-js'

interface GroceryItem {
  id: string
  text: string
  quantity?: string
  category: 'produce' | 'meat' | 'dairy' | 'pantry' | 'other'
  is_checked: boolean
}

interface GroceryList {
  id: string
  menu_id: string
  items: GroceryItem[]
  staples_confirmed: string[]
  share_token: string | null
  created_at: string
  updated_at: string
}

const route = useRoute()
const token = computed(() => route.params.token as string)
const supabase = useSupabase()
const toast = useToast()

// State
const groceryList = ref<GroceryList | null>(null)
const isLoading = ref(true)
const error = ref<string | null>(null)
const updatingItems = ref<Set<string>>(new Set())

// Category display config
const categoryConfig: Record<
  GroceryItem['category'],
  { icon: string; label: string; order: number }
> = {
  produce: { icon: 'i-lucide-leaf', label: 'Produce', order: 1 },
  meat: { icon: 'i-lucide-drumstick', label: 'Meat & Seafood', order: 2 },
  dairy: { icon: 'i-lucide-milk', label: 'Dairy', order: 3 },
  pantry: { icon: 'i-lucide-package', label: 'Pantry', order: 4 },
  other: { icon: 'i-lucide-shopping-bag', label: 'Other', order: 5 }
}

// Computed
const progress = computed(() => {
  if (!groceryList.value?.items.length) return { checked: 0, total: 0, percent: 0 }
  const total = groceryList.value.items.length
  const checked = groceryList.value.items.filter((i) => i.is_checked).length
  return { checked, total, percent: Math.round((checked / total) * 100) }
})

const itemsByCategory = computed(() => {
  if (!groceryList.value?.items) return []

  const grouped = groceryList.value.items.reduce(
    (acc, item) => {
      const category = item.category || 'other'
      if (!acc[category]) acc[category] = []
      acc[category].push(item)
      return acc
    },
    {} as Record<string, GroceryItem[]>
  )

  // Return sorted by category order
  return Object.entries(grouped)
    .map(([category, items]) => ({
      category: category as GroceryItem['category'],
      config: categoryConfig[category as GroceryItem['category']] || categoryConfig.other,
      items
    }))
    .sort((a, b) => a.config.order - b.config.order)
})

// Fetch grocery list
async function fetchGroceryList() {
  isLoading.value = true
  error.value = null

  const { data, error: fetchError } = await supabase
    .from('grocery_lists')
    .select('*')
    .eq('share_token', token.value)
    .single()

  if (fetchError || !data) {
    error.value = 'not_found'
    isLoading.value = false
    return
  }

  groceryList.value = data as GroceryList
  isLoading.value = false
}

// Toggle item checked state
async function toggleItem(itemId: string) {
  if (!groceryList.value || updatingItems.value.has(itemId)) return

  const itemIndex = groceryList.value.items.findIndex((i) => i.id === itemId)
  if (itemIndex === -1) return

  updatingItems.value.add(itemId)

  // Optimistic update
  const previousState = groceryList.value.items[itemIndex].is_checked
  groceryList.value.items[itemIndex].is_checked = !previousState

  const { error: updateError } = await supabase
    .from('grocery_lists')
    .update({ items: groceryList.value.items, updated_at: new Date().toISOString() })
    .eq('share_token', token.value)

  updatingItems.value.delete(itemId)

  if (updateError) {
    // Revert on error
    groceryList.value.items[itemIndex].is_checked = previousState
    toast.add({
      title: 'Failed to update',
      description: "Couldn't save your change. Please try again.",
      color: 'error'
    })
  }
}

// Realtime subscription
let channel: RealtimeChannel | null = null

function setupRealtimeSubscription() {
  channel = supabase
    .channel(`grocery-list-${token.value}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'grocery_lists',
        filter: `share_token=eq.${token.value}`
      },
      (payload) => {
        // Only update if the change came from elsewhere (different updated_at)
        const newData = payload.new as GroceryList
        if (groceryList.value && newData.updated_at !== groceryList.value.updated_at) {
          groceryList.value = newData
        }
      }
    )
    .subscribe()
}

// Lifecycle
onMounted(async () => {
  await fetchGroceryList()
  if (!error.value) {
    setupRealtimeSubscription()
  }
})

onUnmounted(() => {
  channel?.unsubscribe()
})

// SEO
useSeoMeta({
  title: 'Shared Grocery List - Cooked',
  description: 'View and check off items from your shared grocery list'
})
</script>

<template>
  <div class="min-h-screen bg-default">
    <!-- Loading State -->
    <div v-if="isLoading" class="flex min-h-[60vh] items-center justify-center">
      <div class="text-center">
        <UIcon name="i-lucide-loader-2" class="size-8 animate-spin text-primary" />
        <p class="mt-2 text-muted">Loading grocery list...</p>
      </div>
    </div>

    <!-- Error State: Not Found -->
    <div
      v-else-if="error === 'not_found'"
      class="flex min-h-[60vh] items-center justify-center px-4"
    >
      <div class="max-w-md text-center">
        <UIcon name="i-lucide-link-2-off" class="mx-auto size-16 text-muted" />
        <h1 class="mt-4 text-2xl font-bold">List not found</h1>
        <p class="mt-2 text-muted">This grocery list doesn't exist or the link has expired.</p>
        <p class="mt-4 text-sm text-muted">
          Ask the person who shared this link to send you a new one.
        </p>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else-if="groceryList" class="mx-auto max-w-lg px-4 py-6">
      <!-- Header -->
      <div class="mb-6 text-center">
        <div class="mb-2 flex items-center justify-center gap-2">
          <UIcon name="i-lucide-shopping-cart" class="size-6 text-primary" />
          <h1 class="text-xl font-bold">Grocery List</h1>
        </div>

        <!-- Progress -->
        <p class="mb-2 text-sm text-muted">{{ progress.checked }}/{{ progress.total }} items</p>
        <UProgress
          :model-value="progress.percent"
          :max="100"
          color="primary"
          size="sm"
          class="mx-auto max-w-xs"
        />
      </div>

      <!-- Empty State -->
      <div v-if="!groceryList.items.length" class="py-12 text-center">
        <UIcon name="i-lucide-list" class="mx-auto size-12 text-muted" />
        <p class="mt-2 text-muted">This list is empty</p>
      </div>

      <!-- Items by Category -->
      <div v-else class="space-y-6">
        <div v-for="group in itemsByCategory" :key="group.category">
          <!-- Category Header -->
          <div class="mb-2 flex items-center gap-2">
            <UIcon :name="group.config.icon" class="size-5 text-muted" />
            <h2 class="font-semibold">{{ group.config.label }}</h2>
            <UBadge
              :label="`${group.items.filter((i) => i.is_checked).length}/${group.items.length}`"
              color="neutral"
              variant="subtle"
              size="xs"
            />
          </div>

          <!-- Items -->
          <UCard variant="subtle">
            <div class="divide-y divide-default">
              <div
                v-for="item in group.items"
                :key="item.id"
                class="flex min-h-[44px] cursor-pointer items-center gap-3 px-1 py-2 transition-colors hover:bg-elevated"
                role="button"
                tabindex="0"
                @click="toggleItem(item.id)"
                @keydown.enter="toggleItem(item.id)"
                @keydown.space.prevent="toggleItem(item.id)"
              >
                <UCheckbox
                  :model-value="item.is_checked"
                  :disabled="updatingItems.has(item.id)"
                  color="primary"
                  @click.stop
                  @update:model-value="toggleItem(item.id)"
                />
                <div class="flex-1">
                  <span
                    :class="['transition-all', item.is_checked ? 'text-muted line-through' : '']"
                  >
                    {{ item.text }}
                  </span>
                </div>
                <span v-if="item.quantity" class="text-sm text-muted">
                  {{ item.quantity }}
                </span>
                <UIcon
                  v-if="updatingItems.has(item.id)"
                  name="i-lucide-loader-2"
                  class="size-4 animate-spin text-muted"
                />
              </div>
            </div>
          </UCard>
        </div>
      </div>

      <!-- Footer hint -->
      <p class="mt-8 text-center text-xs text-muted">Changes sync automatically between devices</p>
    </div>
  </div>
</template>
