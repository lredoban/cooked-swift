<script setup lang="ts">
useSeoMeta({
  title: 'Privacy Policy - Cooked',
  description: 'Privacy Policy for the Cooked iOS app. Learn how we collect, use, and protect your data.'
})
</script>

<template>
  <UContainer class="py-16">
    <UPageHeader
      title="Privacy Policy"
      description="Last Updated: January 2026"
    />

    <div class="prose prose-neutral dark:prose-invert max-w-none mt-8">
      <p>
        This Privacy Policy describes how Cooked ("we", "us", or "our") collects, uses, and shares information when you use our mobile application (the "App").
      </p>

      <h2>Information We Collect</h2>

      <h3>Information You Provide</h3>
      <ul>
        <li><strong>Account Information:</strong> When you create an account, we collect your email address and create a unique user identifier.</li>
        <li><strong>Recipe Data:</strong> Recipes you import or create, including titles, ingredients, steps, tags, and images.</li>
        <li><strong>Menu Data:</strong> Your menu plans, cooking history, and preferences.</li>
        <li><strong>Grocery Lists:</strong> Shopping lists generated from your menus.</li>
      </ul>

      <h3>Information Collected Automatically</h3>
      <ul>
        <li><strong>Usage Data:</strong> How you interact with the App, including features used, recipes imported, and menus created.</li>
        <li><strong>Device Information:</strong> Device type, operating system version, and app version.</li>
        <li><strong>Analytics Data:</strong> Aggregated usage statistics to improve the App (via PostHog, if enabled).</li>
      </ul>

      <h3>Information from Third Parties</h3>
      <ul>
        <li><strong>Recipe URLs:</strong> When you import a recipe, we process the URL you provide to extract recipe information.</li>
        <li><strong>Payment Information:</strong> If you subscribe to Pro, payment is processed by Apple through the App Store. We receive subscription status but not payment details.</li>
      </ul>

      <h2>How We Use Your Information</h2>
      <p>We use your information to:</p>
      <ul>
        <li>Provide and maintain the App</li>
        <li>Process and save your recipes, menus, and grocery lists</li>
        <li>Sync your data across devices</li>
        <li>Process subscription purchases</li>
        <li>Send important service notifications</li>
        <li>Improve the App based on usage patterns</li>
        <li>Respond to your support requests</li>
      </ul>

      <h2>Data Storage and Security</h2>

      <h3>Where We Store Data</h3>
      <p>
        Your data is stored on Supabase, a cloud database service. Supabase servers are located in the United States and comply with industry-standard security practices.
      </p>

      <h3>How We Protect Data</h3>
      <ul>
        <li>All data is transmitted using HTTPS encryption</li>
        <li>Passwords are hashed using industry-standard algorithms</li>
        <li>Database access is restricted and monitored</li>
        <li>We use Row Level Security (RLS) to ensure users can only access their own data</li>
      </ul>

      <h2>Data Sharing</h2>
      <p>We do not sell your personal information. We may share information in the following circumstances:</p>

      <h3>Service Providers</h3>
      <p>We use third-party services to operate the App:</p>
      <ul>
        <li><strong>Supabase:</strong> Database and authentication</li>
        <li><strong>RevenueCat:</strong> Subscription management</li>
        <li><strong>PostHog:</strong> Analytics (if enabled)</li>
      </ul>
      <p>These providers only access data necessary to perform their services and are bound by confidentiality obligations.</p>

      <h3>Legal Requirements</h3>
      <p>We may disclose information if required by law or if we believe disclosure is necessary to:</p>
      <ul>
        <li>Comply with legal obligations</li>
        <li>Protect our rights or safety</li>
        <li>Investigate potential violations</li>
      </ul>

      <h2>Your Rights and Choices</h2>

      <h3>Access and Export</h3>
      <p>You can view all your data within the App. Contact us to request a full export of your data.</p>

      <h3>Deletion</h3>
      <p>You can delete individual recipes, menus, and grocery lists within the App. To delete your entire account and all associated data, contact us at privacy@cookedapp.com.</p>

      <h3>Communication Preferences</h3>
      <p>We only send essential service communications. We do not send marketing emails unless you opt in.</p>

      <h2>Children's Privacy</h2>
      <p>The App is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us.</p>

      <h2>Third-Party Links</h2>
      <p>The App may contain links to third-party websites (recipe sources). We are not responsible for the privacy practices of these external sites.</p>

      <h2>Changes to This Policy</h2>
      <p>We may update this Privacy Policy from time to time. We will notify you of significant changes through the App or by email. Your continued use of the App after changes constitutes acceptance of the updated policy.</p>

      <h2>International Users</h2>
      <p>If you are located outside the United States, please note that your information will be transferred to and processed in the United States where our servers are located.</p>

      <h2>Contact Us</h2>
      <p>If you have questions about this Privacy Policy or our data practices, please contact us:</p>
      <ul>
        <li><strong>Email:</strong> privacy@cookedapp.com</li>
      </ul>

      <h2>California Privacy Rights</h2>
      <p>If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):</p>
      <ul>
        <li>Right to know what personal information is collected</li>
        <li>Right to delete personal information</li>
        <li>Right to opt-out of the sale of personal information (we do not sell personal information)</li>
        <li>Right to non-discrimination for exercising your rights</li>
      </ul>
      <p>To exercise these rights, contact us using the information above.</p>

      <h2>GDPR Rights (European Users)</h2>
      <p>If you are located in the European Economic Area, you have additional rights under GDPR:</p>
      <ul>
        <li>Right to access your personal data</li>
        <li>Right to rectification of inaccurate data</li>
        <li>Right to erasure ("right to be forgotten")</li>
        <li>Right to restrict processing</li>
        <li>Right to data portability</li>
        <li>Right to object to processing</li>
        <li>Rights related to automated decision-making</li>
      </ul>
      <p>To exercise these rights, contact us using the information above.</p>
    </div>
  </UContainer>
</template>
