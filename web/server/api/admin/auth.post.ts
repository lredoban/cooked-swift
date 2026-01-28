export default defineEventHandler(async (event) => {
  if (!import.meta.dev) {
    throw createError({ statusCode: 403, statusMessage: 'Dev only' })
  }

  const { email, password } = await readBody<{ email: string; password: string }>(event)
  if (!email || !password) {
    throw createError({ statusCode: 400, statusMessage: 'email and password are required' })
  }

  const supabase = useSupabaseAdmin()
  const { data, error } = await supabase.auth.signInWithPassword({ email, password })

  if (error || !data.session) {
    throw createError({ statusCode: 401, statusMessage: error?.message || 'Authentication failed' })
  }

  return {
    access_token: data.session.access_token,
    user_id: data.user.id
  }
})
