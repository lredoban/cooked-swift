# Recipe Extraction API (Modal)

Serverless API that extracts recipes from video URLs using [social_recipes](https://github.com/pickeld/social_recipes), hosted on [Modal](https://modal.com).

Returns raw Schema.org recipe data - transformation to iOS format is handled by the Nuxt backend.

## Setup

### 1. Install Modal CLI

```bash
pip install modal
modal setup
```

### 2. Create Modal Secret

```bash
modal secret create cooked-extraction \
  GOOGLE_API_KEY=your-gemini-api-key \
  API_AUTH_TOKEN=your-secure-random-token
```

### 3. Deploy

```bash
cd python-extraction
modal deploy app.py
```

## API

### POST /extract

**Request:**
```json
{
  "url": "https://www.tiktok.com/@user/video/1234567890"
}
```

**Response:**
```json
{
  "success": true,
  "recipe": {
    "@context": "https://schema.org",
    "@type": "Recipe",
    "name": "Creamy Pasta",
    "recipeIngredient": ["1 lb pasta", "1 cup heavy cream"],
    "recipeInstructions": [...]
  },
  "metadata": {
    "uploader": "TikTok Chef",
    "title": "Best pasta recipe!",
    "thumbnail": "https://..."
  }
}
```

**Error:**
```json
{
  "success": false,
  "error": "Invalid URL format"
}
```

### GET /health

Returns `{"status": "healthy"}`.

## Development

```bash
modal serve app.py
```
