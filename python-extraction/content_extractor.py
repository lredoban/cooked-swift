"""Content extraction from social media URLs.

Supports:
- Instagram (via instaloader)
- TikTok, YouTube (via yt-dlp)
"""

import logging
import re
import tempfile
from urllib.parse import urlparse

logger = logging.getLogger(__name__)


def extract_instagram(url: str) -> dict:
    """Extract content from Instagram post/reel."""
    import instaloader

    # Extract shortcode from URL
    # URLs like: instagram.com/p/ABC123/ or instagram.com/reel/ABC123/
    match = re.search(r"/(p|reel|reels)/([A-Za-z0-9_-]+)", url)
    if not match:
        raise ValueError(f"Could not extract Instagram shortcode from URL: {url}")

    shortcode = match.group(2)
    logger.info(f"Extracting Instagram post: {shortcode}")

    L = instaloader.Instaloader(
        download_videos=False,
        download_video_thumbnails=False,
        download_geotags=False,
        download_comments=False,
        save_metadata=False,
        compress_json=False,
    )

    try:
        post = instaloader.Post.from_shortcode(L.context, shortcode)

        return {
            "platform": "instagram",
            "shortcode": shortcode,
            "url": url,
            "caption": post.caption or "",
            "owner_username": post.owner_username,
            "owner_id": post.owner_id,
            "is_video": post.is_video,
            "video_url": post.video_url if post.is_video else None,
            "thumbnail_url": post.url,  # This is the image/thumbnail URL
            "likes": post.likes,
            "comments_count": post.comments,
            "timestamp": post.date_utc.isoformat() if post.date_utc else None,
            "hashtags": list(post.caption_hashtags) if post.caption_hashtags else [],
            "mentions": list(post.caption_mentions) if post.caption_mentions else [],
        }
    except Exception as e:
        logger.error(f"Instaloader error: {e}")
        raise


def extract_ytdlp(url: str) -> dict:
    """Extract content using yt-dlp (TikTok, YouTube, etc.)."""
    import yt_dlp

    logger.info(f"Extracting with yt-dlp: {url}")

    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "extract_flat": False,
        "skip_download": True,  # Don't download, just get info
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)

    # Determine platform from extractor
    platform = info.get("extractor", "unknown").lower()
    if "tiktok" in platform:
        platform = "tiktok"
    elif "youtube" in platform:
        platform = "youtube"

    return {
        "platform": platform,
        "url": url,
        "title": info.get("title"),
        "description": info.get("description") or "",
        "uploader": info.get("uploader"),
        "uploader_id": info.get("uploader_id"),
        "channel": info.get("channel"),
        "duration": info.get("duration"),
        "view_count": info.get("view_count"),
        "like_count": info.get("like_count"),
        "comment_count": info.get("comment_count"),
        "thumbnail_url": info.get("thumbnail"),
        "video_url": info.get("url"),  # Direct video URL if available
        "timestamp": info.get("timestamp"),
        "hashtags": info.get("tags", []),
    }


def extract_content(url: str) -> dict:
    """Extract content from a social media URL.

    Automatically detects platform and uses appropriate extractor.
    """
    parsed = urlparse(url)
    domain = parsed.netloc.lower().replace("www.", "")

    if "instagram.com" in domain:
        return extract_instagram(url)
    else:
        # Use yt-dlp for everything else (TikTok, YouTube, etc.)
        return extract_ytdlp(url)
