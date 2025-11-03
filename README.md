---
title: Grammo
emoji: 👀
colorFrom: purple
colorTo: yellow
sdk: docker
pinned: false
license: gpl-3.0
short_description: AI Translation and Grammar Correction
---

# Grammo Backend

Django REST API backend for Grammo, an AI-powered translation and grammar correction service.

## Overview

The Grammo backend provides a RESTful API for translation and grammar correction services. It leverages LangChain and HuggingFace models to process language requests, with LangGraph managing conversation state across sessions.

## Features

- 🌐 **Translation Service** - Natural, contextually appropriate translations between languages
- ✏️ **Grammar Correction** - Fixes grammar, spelling, and punctuation errors
- 💬 **Session Management** - Maintains conversation context using Django sessions and LangGraph checkpoints
- 🎭 **Customizable Modes** - Supports Default and Grammar modes
- 🎨 **Tone Control** - Configurable tone (Default, Formal, Casual) for responses
- 🔒 **Security** - CORS support, CSRF protection, secure session management
- 📦 **HuggingFace Integration** - Uses GPT-OSS-Safeguard-20B model via HuggingFace API

## Tech Stack

- **Django 5.2.7** - Web framework
- **Django REST Framework** - API development
- **LangChain** - AI agent orchestration
- **LangGraph** - Conversation state management
- **HuggingFace** - Language model integration (GPT-OSS-Safeguard-20B)
- **Python 3.14+** - Programming language
- **SQLite** - Database (development)
- **Uvicorn** - ASGI server

## Prerequisites

- Python 3.14 or higher
- pip (Python package manager)
- HuggingFace API Token ([Get one here](https://huggingface.co/settings/tokens))

## Installation

### 1. Navigate to the backend directory

```bash
cd backend
```

### 2. Create and activate a virtual environment

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Set up environment variables

Create a `.env` file in the `backend` directory (or copy from the example):

```bash
cp .env.example .env  # or: touch .env
```

At minimum, set the variables below (see [Environment Variables](#environment-variables) for details):

```env
# Required
SECRET_KEY=your-secret-key-here
HUGGINGFACEHUB_API_TOKEN=your-huggingface-api-token

# Common
DEBUG=True
MODE=development  # change to "production" for deployment
```

To generate a Django secret key:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 5. Run database migrations

```bash
python manage.py migrate
```

## Environment Variables

Create a `.env` file in the `backend` directory. The backend loads variables from this file using `python-dotenv`.

### Required

```env
# Django Secret Key (generate one using the command above)
SECRET_KEY=your-secret-key-here

# HuggingFace API Token (any of these will be picked up; preferred shown first)
HUGGINGFACEHUB_API_TOKEN=your-huggingface-api-token
# HF_TOKEN=your-huggingface-api-token
# HF_API_TOKEN=your-huggingface-api-token
```

### Core Runtime

```env
# Debug mode (default: True)
DEBUG=True

# App mode: "development" (default) or "production"
MODE=development

# Port only used when running `python app.py` (Hugging Face Spaces)
# PORT=7860
```

### Production-only

When `MODE=production`, the following become relevant:

```env
# Allowed hosts (comma-separated, no spaces)
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# CSRF trusted origins (comma-separated)
CSRF_TRUSTED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

Notes:
- Most security and CORS flags are derived automatically from `MODE` in `backend/settings.py`:
  - In development: permissive defaults for local usage
  - In production: `CORS_ALLOW_ALL_ORIGINS=False`, secure cookies, HSTS, content type nosniff, and SSL redirect are enabled
- Do not set `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, `CORS_ALLOW_ALL_ORIGINS`, or `SECURE_*` directly via env; they are computed from `MODE`.

## Running the Application

### Development Mode

**Option 1: Django Development Server (with warnings)**

```bash
python manage.py runserver
```

The server will run on `http://localhost:8000`

**Option 2: Uvicorn ASGI Server (production-like, no warnings)**

```bash
uvicorn backend.asgi:application --host 0.0.0.0 --port 8000 --reload
```

### Production Mode

```bash
# Set DEBUG=False in .env
uvicorn backend.asgi:application --host 0.0.0.0 --port 8000

# With multiple workers:
uvicorn backend.asgi:application --host 0.0.0.0 --port 8000 --workers 4
```

### Standalone Script (for HuggingFace Spaces)

The backend can also be run as a standalone script:

```bash
python app.py
```

This uses the `PORT` environment variable (defaults to 7860) and is configured for HuggingFace Spaces deployment.

## API Endpoints

### Base URL

All endpoints are prefixed with `/api/v1/`

### `GET /api/v1/hello/`

Health check endpoint.

**Response:**
```json
{
  "message": "Hello from Grammo!"
}
```

### `POST /api/v1/chat/`

Send a message to start or continue a chat session.

**Request Body:**
```json
{
  "message": "Translate this text to French",
  "chatSession": 0,
  "mode": "default",
  "tone": "default"
}
```

**Parameters:**
- `message` (required): The user's message
- `chatSession` (optional): Session identifier to maintain conversation context
- `mode` (optional): `"default"` or `"grammar"` - Determines how the message is processed
- `tone` (optional): `"default"`, `"formal"`, or `"casual"` - Sets the tone of the response

**Response (Success):**
```json
{
  "status": "success",
  "response": "**Original**: \nTranslate this text to French\n**Output**: \nTraduisez ce texte en français\n___\n**Explanation**: \n> Direct translation maintaining the original meaning"
}
```

**Response (Error):**
```json
{
  "status": "error",
  "response": "Invalid message."
}
```

### `POST /api/v1/end/`

End the current chat session and clear conversation history.

**Request Body:**
```json
{}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Session ended successfully"
}
```

**Response (Error):**
```json
{
  "status": "error",
  "response": "No active session."
}
```

## Project Structure

```
backend/
├── agent_manager/           # AI agent management module
│   └── __init__.py         # LangChain agent setup, session management
├── api/                    # Django REST API application
│   ├── views.py            # API view handlers (chat, hello, end)
│   ├── urls.py             # URL routing
│   └── apps.py             # App configuration
├── backend/                # Django project settings
│   ├── settings.py         # Django configuration
│   ├── urls.py             # Main URL configuration
│   ├── asgi.py             # ASGI application
│   └── wsgi.py             # WSGI application
├── app.py                  # Standalone entry point (HuggingFace Spaces)
├── manage.py               # Django management script
├── requirements.txt        # Python dependencies
├── Dockerfile              # Docker configuration for deployment
└── README.md               # This file
```

## Development

### Session Management

- Sessions are managed using Django's session framework
- Session data is stored in the cache backend (in-memory for development)
- Each session maintains its own LangGraph agent with conversation checkpointing
- Sessions expire after 24 hours of inactivity or when explicitly ended

### Agent Architecture

- Uses LangChain's `create_agent` with a structured output wrapper
- Structured output ensures consistent JSON responses for translation/correction tasks
- Agents are cached per session key for efficient memory usage
- Supports task types: `translation`, `correction`, `follow-up`, `invalid`

### Database

- Uses SQLite by default (suitable for development)
- No models are currently defined, but Django is configured for future database needs
- Run `python manage.py migrate` to set up the database schema

### Caching

- In-memory cache is used for sessions (development)
- **Note:** For production, consider switching to Redis or another persistent cache backend

### CORS Configuration

- CORS is configured to allow cross-origin requests
- In production, configure `CORS_ALLOW_ALL_ORIGINS` and `ALLOWED_HOSTS` appropriately

## Deployment

### Docker Deployment (HuggingFace Spaces)

The backend includes a `Dockerfile` configured for HuggingFace Spaces deployment.

1. **Set environment variables** in your Space settings:
   - `SECRET_KEY`
   - `HUGGINGFACEHUB_API_TOKEN`
   - `MODE=production`
   - `DEBUG=False`
   - `ALLOWED_HOSTS=your-space-name.hf.space`
   - `CSRF_TRUSTED_ORIGINS=https://your-space-name.hf.space`

2. **Push your code** to the Space repository

3. **The API will be available** at `https://your-space-name.hf.space/api/v1/`

### General Production Deployment

1. Set production environment variables (see [Environment Variables](#environment-variables))
   - `MODE=production`, `DEBUG=False`
   - `ALLOWED_HOSTS` and `CSRF_TRUSTED_ORIGINS`
3. Configure a proper database (PostgreSQL recommended)
4. Set up Redis or another cache backend for sessions
5. Use a production ASGI server (Uvicorn with multiple workers or Gunicorn with Uvicorn workers)
6. Configure reverse proxy (Nginx, Apache) with SSL/TLS
7. Set up static file serving or use a CDN

## Testing

To test the API endpoints:

```bash
# Health check
curl http://localhost:8000/api/v1/hello/

# Send a chat message
curl -X POST http://localhost:8000/api/v1/chat/ \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, translate this to Spanish", "mode": "default", "tone": "default"}'

# End session
curl -X POST http://localhost:8000/api/v1/end/
```

## Troubleshooting

### Common Issues

1. **Module not found errors**: Ensure your virtual environment is activated and dependencies are installed
2. **Secret key errors**: Make sure `SECRET_KEY` is set in your `.env` file
3. **HuggingFace API errors**: Verify your `HUGGINGFACEHUB_API_TOKEN` is valid
4. **CORS errors**: Check `CORS_ALLOW_ALL_ORIGINS` and `ALLOWED_HOSTS` settings
5. **Session not persisting**: Ensure cache backend is configured correctly

## Notes

- The application uses in-memory session storage for development. For production, consider using Redis.
- The HuggingFace model (`openai/gpt-oss-safeguard-20b`) is used for all language processing tasks.
- Conversation state is managed per Django session using LangGraph's checkpoint system.
- The structured output wrapper ensures responses follow a consistent JSON schema.

## License

See the [LICENSE](LICENSE) file for details.

