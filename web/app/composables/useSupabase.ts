import { createClient, type SupabaseClient } from '@supabase/supabase-js'

let _client: SupabaseClient | null = null

/**
 * Returns a Supabase client for client-side operations.
 * Uses the anon key and respects RLS policies.
 */
export function useSupabase(): SupabaseClient {
  if (!_client) {
    const config = useRuntimeConfig()
    const { supabaseUrl, supabaseAnonKey } = config.public

    if (!supabaseUrl || !supabaseAnonKey) {
      throw new Error('Missing NUXT_PUBLIC_SUPABASE_URL or NUXT_PUBLIC_SUPABASE_ANON_KEY env vars')
    }

    _client = createClient(supabaseUrl, supabaseAnonKey)
  }

  return _client
}
