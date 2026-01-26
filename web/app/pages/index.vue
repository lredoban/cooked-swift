<script setup lang="ts">
const features = [
  {
    icon: 'i-lucide-link',
    title: 'Import recipes in seconds',
    description:
      'Paste a link from TikTok, Instagram, YouTube, or any recipe blog. Cooked extracts the ingredients and steps automatically.'
  },
  {
    icon: 'i-lucide-utensils-crossed',
    title: 'Plan your week, not your lifetime',
    description:
      "Add 3-5 recipes to your weekly menu. Focus on what you're actually cooking, not a digital recipe hoard."
  },
  {
    icon: 'i-lucide-list-checks',
    title: 'Never forget an ingredient',
    description:
      'Generate a shopping list organized by store section. Check items off as you shop, share with family.'
  },
  {
    icon: 'i-lucide-trending-up',
    title: 'Feel good about cooking',
    description:
      'Mark recipes as cooked and watch your progress. Reuse past menus when you want to cook favorites again.'
  }
]
const howItWorks = [
  {
    title: 'Find a recipe you want to cook',
    description:
      'Scrolling TikTok? See a recipe on Instagram? Found something on a food blog? Copy the link.'
  },
  {
    title: 'Import it to Cooked',
    description:
      'Paste the URL and Cooked extracts the recipe automatically. Edit if needed, then save to your library.'
  },
  {
    title: 'Add it to your menu',
    description: "Select recipes from your library to build this week's menu. Aim for 3-5 meals."
  },
  {
    title: 'Generate your grocery list',
    description:
      'Cooked combines all ingredients and organizes them by category. Shop, cook, enjoy.'
  }
]

const plans = [
  {
    title: 'Free',
    description: 'Get started with the basics',
    price: '$0',
    features: [
      '15 recipes in your library',
      '5 video imports per month',
      '3 menu history entries',
      'Full menu and grocery list features'
    ],
    button: {
      label: 'Download Free',
      color: 'neutral' as const,
      variant: 'outline' as const
    }
  },
  {
    title: 'Pro',
    description: 'For serious home cooks',
    price: '$4.99',
    tagline: 'per month',
    features: [
      'Unlimited recipes',
      'Unlimited video imports',
      'Unlimited menu history',
      'Priority support'
    ],
    badge: {
      label: 'Popular',
      color: 'primary' as const
    },
    button: {
      label: 'Go Pro',
      color: 'primary' as const
    },
    variant: 'subtle' as const
  }
]

const faqs = [
  {
    label: 'What platforms can I import recipes from?',
    content:
      'Cooked supports TikTok, Instagram Reels, YouTube videos, and most recipe websites. If it has a URL, we can probably import it.'
  },
  {
    label: 'Does Cooked work offline?',
    content:
      "Once recipes are imported, they're available offline. You can view your menu and grocery list without an internet connection."
  },
  {
    label: 'Can I share my grocery list?',
    content:
      'Yes! Share your list as text with family members. They can help shop even without the app.'
  },
  {
    label: "What if the recipe import isn't perfect?",
    content:
      'You can edit any imported recipe before saving. Adjust ingredients, fix steps, or add notes.'
  },
  {
    label: 'Is there a web version?',
    content:
      'Cooked is currently iOS-only. A web companion for shared grocery lists is coming soon.'
  }
]

const testimonials = [
  {
    quote: 'I finally stopped doom-scrolling recipes and actually cooked dinner.',
    author: 'Happy Cook'
  },
  {
    quote: 'The grocery list feature alone is worth it. No more forgetting ingredients.',
    author: 'Organized Shopper'
  },
  {
    quote: "I love being able to reuse past menus when I'm too tired to plan.",
    author: 'Busy Parent'
  }
]
</script>

<template>
  <div>
    <!-- Hero Section -->
    <UPageHero
      title="Turn food inspiration into dinner on the table"
      description="Cooked helps you build a weekly menu from recipes you actually want to cook, then generates your grocery list automatically."
      :links="[
        {
          label: 'Download on the App Store',
          to: '#',
          trailingIcon: 'i-lucide-arrow-right',
          size: 'xl'
        },
        {
          label: 'Learn More',
          to: '#features',
          size: 'xl',
          color: 'neutral',
          variant: 'outline'
        }
      ]"
    />

    <!-- Problem Section -->
    <UPageSection
      headline="The Problem"
      title="Saving recipes isn't cooking"
      description="You've got hundreds of saved recipes scattered across Instagram, TikTok, Pinterest, and recipe blogs. But when it's time to plan dinner, you're still staring at the fridge asking 'What should we eat?'"
    >
      <template #bottom>
        <p class="mx-auto max-w-2xl text-center text-lg text-muted">
          The problem isn't finding recipes. It's committing to cooking them.
        </p>
      </template>
    </UPageSection>

    <!-- Solution Section -->
    <UPageSection
      headline="The Solution"
      title="Menu-first meal planning"
      description="Cooked flips the script. Instead of collecting recipes you might cook someday, you build a menu of meals you're actually going to make this week."
    >
      <UTimeline
        :items="
          howItWorks.map((step, index) => ({
            title: `${index + 1}. ${step.title}`,
            description: step.description,
            icon: [
              'i-lucide-search',
              'i-lucide-download',
              'i-lucide-calendar',
              'i-lucide-shopping-cart'
            ][index]
          }))
        "
        class="mx-auto max-w-xl"
      />
    </UPageSection>

    <!-- Features Section -->
    <UPageSection
      id="features"
      headline="Features"
      title="Everything you need to cook this week"
      :features="features"
    />

    <!-- Testimonials Section -->
    <UPageSection headline="What people say" title="From saved to served">
      <div class="grid gap-6 md:grid-cols-3">
        <UCard v-for="(testimonial, index) in testimonials" :key="index">
          <div class="flex flex-col gap-4">
            <UIcon name="i-lucide-quote" class="size-8 text-primary" />
            <p class="text-lg italic">"{{ testimonial.quote }}"</p>
            <p class="text-sm text-muted">- {{ testimonial.author }}</p>
          </div>
        </UCard>
      </div>
    </UPageSection>

    <!-- Pricing Section -->
    <UPageSection
      id="pricing"
      headline="Pricing"
      title="Start cooking for free"
      description="Get started with the free plan, upgrade when you need more."
    >
      <UPricingPlans :plans="plans" />
    </UPageSection>

    <!-- FAQ Section -->
    <UPageSection id="faq" headline="FAQ" title="Frequently asked questions">
      <UAccordion :items="faqs" class="mx-auto max-w-2xl" />
    </UPageSection>

    <!-- Final CTA -->
    <UPageSection>
      <UPageCTA
        title="Start cooking this week"
        description="Download Cooked and turn your saved recipes into actual meals."
        variant="subtle"
        :links="[
          {
            label: 'Download on the App Store',
            to: '#',
            trailingIcon: 'i-lucide-arrow-right',
            color: 'primary'
          }
        ]"
      />
    </UPageSection>
  </div>
</template>
