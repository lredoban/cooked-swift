<script setup>
useHead({
  meta: [
    { name: 'viewport', content: 'width=device-width, initial-scale=1' }
  ],
  link: [
    { rel: 'icon', href: '/favicon.ico' }
  ],
  htmlAttrs: {
    lang: 'en'
  }
})

const title = 'Cooked - Turn Recipe Inspiration Into Real Meals | Menu Planning App'
const description = 'Stop hoarding recipes you\'ll never cook. Cooked helps you build a weekly menu from TikTok, Instagram, and recipe blogs, then generates your grocery list automatically.'

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
  twitterCard: 'summary_large_image'
})

const footerLinks = [
  {
    label: 'Privacy Policy',
    to: '/privacy'
  },
  {
    label: 'Terms of Service',
    to: '/terms'
  }
]
</script>

<template>
  <UApp>
    <UHeader>
      <template #left>
        <NuxtLink
          to="/"
          class="flex items-center gap-2"
        >
          <UIcon
            name="i-lucide-cooking-pot"
            class="size-6 text-primary"
          />
          <span class="font-semibold text-lg">Cooked</span>
        </NuxtLink>
      </template>

      <template #right>
        <UColorModeButton />
      </template>
    </UHeader>

    <UMain>
      <NuxtPage />
    </UMain>

    <UFooter>
      <template #left>
        <p class="text-sm text-muted">
          &copy; {{ new Date().getFullYear() }} Cooked. All rights reserved.
        </p>
      </template>

      <template #center>
        <div class="flex items-center gap-4">
          <UButton
            v-for="link in footerLinks"
            :key="link.to"
            :to="link.to"
            :label="link.label"
            color="neutral"
            variant="link"
            size="sm"
          />
        </div>
      </template>
    </UFooter>
  </UApp>
</template>
