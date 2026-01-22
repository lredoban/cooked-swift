import { chatCompletion } from '~/utils/openrouter';

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event);
    const { url, sourceType } = body;

    if (!url) {
      throw createError({
        statusCode: 400,
        message: 'URL is required',
      });
    }

    // Fetch the URL content
    let content: string;
    try {
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; RecipeBot/1.0)',
        },
      });

      if (!response.ok) {
        throw new Error(`Failed to fetch URL: ${response.statusText}`);
      }

      content = await response.text();
    } catch (fetchError: any) {
      throw createError({
        statusCode: 400,
        message: `Failed to fetch URL: ${fetchError.message}`,
      });
    }

    // Extract recipe using LLM
    const prompt = `Extract recipe information from the following webpage content. Return ONLY valid JSON with this exact structure (no markdown, no code blocks, just raw JSON):

{
  "title": "Recipe title",
  "source_name": "Source or author name",
  "ingredients": [
    {"text": "ingredient name", "quantity": "amount (optional)"}
  ],
  "steps": ["step 1", "step 2"],
  "tags": ["tag1", "tag2"],
  "image_url": "image URL if found (optional)"
}

Important:
- Extract the main recipe title
- List ALL ingredients with quantities if available
- List ALL cooking steps in order
- Suggest relevant tags (cuisine type, meal type, cooking method, etc.)
- If you find an image URL, include it
- Return ONLY the JSON object, nothing else

Webpage content:
${content.slice(0, 15000)}`;

    const result = await chatCompletion({
      model: 'anthropic/claude-3.5-sonnet',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.3,
      maxTokens: 2000,
    });

    // Parse the LLM response as JSON
    let recipeData;
    try {
      // Remove markdown code blocks if present
      let jsonText = result.content;
      jsonText = jsonText.replace(/```json\n?/g, '');
      jsonText = jsonText.replace(/```\n?/g, '');
      jsonText = jsonText.trim();

      recipeData = JSON.parse(jsonText);
    } catch (parseError) {
      console.error('Failed to parse LLM response:', result.content);
      throw createError({
        statusCode: 500,
        message: 'Failed to parse recipe data from response',
      });
    }

    // Validate the recipe data structure
    if (!recipeData.title || !recipeData.ingredients || !recipeData.steps) {
      throw createError({
        statusCode: 400,
        message: 'Incomplete recipe data extracted',
      });
    }

    return {
      success: true,
      recipe: {
        title: recipeData.title,
        source_type: sourceType || 'url',
        source_url: url,
        source_name: recipeData.source_name || undefined,
        ingredients: recipeData.ingredients.map((ing: any) => ({
          text: ing.text || ing,
          quantity: ing.quantity || undefined,
        })),
        steps: recipeData.steps,
        tags: recipeData.tags || [],
        image_url: recipeData.image_url || undefined,
      },
    };
  } catch (error: any) {
    console.error('Recipe extraction error:', error);

    throw createError({
      statusCode: error.statusCode || 500,
      message: error.message || 'Failed to extract recipe',
    });
  }
});
