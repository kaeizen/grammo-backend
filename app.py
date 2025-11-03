"""
Hugging Face Spaces entry point.
This file allows the app to run as a standalone Python script for Spaces.
"""
import os
import uvicorn

if __name__ == "__main__":
    # Get port from environment (Hugging Face Spaces sets this)
    port = int(os.environ.get("PORT", 7860))

    # Run the ASGI application
    uvicorn.run(
        "backend.asgi:application",
        host="0.0.0.0",
        port=port,
        workers=1,
        log_level="info"
    )

