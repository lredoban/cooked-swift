import type { H3Event } from 'h3'

/**
 * Extracts and verifies the Supabase auth token from the request.
 * Returns the authenticated user's ID.
 * Throws 401 if token is missing or invalid.
 */
export async function requireAuth(event: H3Event): Promise<string> {
  const authHeader = getHeader(event, 'authorization')
  if (!authHeader?.startsWith('Bearer ')) {
    throw createError({ statusCode: 401, statusMessage: 'Missing authorization token' })
  }

  const token = authHeader.slice(7)
  const supabase = useSupabaseUser(token)

  const { data, error } = await supabase.auth.getUser(token)
  if (error || !data.user) {
    throw createError({ statusCode: 401, statusMessage: 'Invalid or expired token' })
  }

  return data.user.id
}
