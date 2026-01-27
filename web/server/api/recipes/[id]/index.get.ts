export default defineEventHandler(async (event) => {
  const userId = await requireAuth(event)

  const recipeId = getRouterParam(event, 'id')
  if (!recipeId) {
    throw createError({ statusCode: 400, statusMessage: 'Recipe ID is required' })
  }

  const supabase = useSupabaseAdmin()

  const { data: recipe, error } = await supabase
    .from('recipes')
    .select('*')
    .eq('id', recipeId)
    .eq('user_id', userId)
    .single()

  if (error || !recipe) {
    throw createError({ statusCode: 404, statusMessage: 'Recipe not found' })
  }

  return recipe
})
