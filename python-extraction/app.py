"""Modal application for Recipe Extraction API.

Deployment:
    modal deploy app.py

Development:
    modal serve app.py
"""

import modal

app = modal.App("cooked-recipe-extraction")

image = (
    modal.Image.debian_slim(python_version="3.11")
    .apt_install("ffmpeg")
    .pip_install(
        "instaloader",
        "yt-dlp",
        "fastapi[standard]",
        "pydantic",
    )
    .add_local_file("content_extractor.py", "/root/content_extractor.py")
)


@app.function(
    image=image,
    secrets=[modal.Secret.from_name("cooked-extraction")],
    timeout=300,
    memory=2048,
)
@modal.fastapi_endpoint(method="POST")
def extract(request_data: dict):
    """Extract content from a URL."""
    import logging
    import sys

    from fastapi.responses import JSONResponse
    from pydantic import BaseModel

    sys.path.insert(0, "/root")
    from content_extractor import extract_content

    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    url = request_data.get("url")
    if not url or not url.startswith(("http://", "https://")):
        return JSONResponse(
            status_code=400,
            content={"success": False, "error": "Invalid URL format"},
        )

    try:
        logger.info(f"Extracting from: {url}")
        result = extract_content(url)
        return {"success": True, **result}

    except Exception as e:
        logger.exception(f"Extraction failed: {e}")
        return JSONResponse(
            status_code=500,
            content={"success": False, "error": str(e)},
        )


@app.function(image=image)
@modal.fastapi_endpoint(method="GET")
def health():
    """Health check endpoint."""
    return {"status": "healthy"}
