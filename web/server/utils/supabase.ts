import { createClient, type SupabaseClient } from '@supabase/supabase-js'

let _adminClient: SupabaseClient | null = null

/**
 * Returns a Supabase admin client using the service role key.
 * Used for server-side operations that bypass RLS.
 */
export function useSupabaseAdmin(): SupabaseClient {
  if (!_adminClient) {
    const config = useRuntimeConfig()
    if (!config.public.supabaseUrl || !config.supabaseServiceKey) {
      throw new Error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY env vars')
    }
    _adminClient = createClient(config.public.supabaseUrl, config.supabaseServiceKey)
  }
  return _adminClient
}

/**
 * Creates a Supabase client scoped to the user's auth token.
 * Respects RLS policies.
 */
export function useSupabaseUser(accessToken: string): SupabaseClient {
  const config = useRuntimeConfig()
  return createClient(config.public.supabaseUrl, config.public.supabaseAnonKey, {
    global: {
      headers: { Authorization: `Bearer ${accessToken}` }
    }
  })
}
