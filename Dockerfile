# Use Python 3.14 slim image as base
FROM python:3.14-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Upgrade pip first
RUN pip install --upgrade pip

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install specific transformers
RUN pip install git+https://github.com/huggingface/transformers@8fb854cac869b42c87a7bd15d9298985c5aea96e

RUN --mount=type=secret,id=SECRET_KEY,env=SECRET_KEY
RUN --mount=type=secret,id=HUGGINGFACEHUB_API_TOKEN,env=HUGGINGFACEHUB_API_TOKEN

RUN --mount=type=secret,id=DEBUG,env=DEBUG
RUN --mount=type=secret,id=SESSION_COOKIE_SECURE,env=SESSION_COOKIE_SECURE
RUN --mount=type=secret,id=CSRF_COOKIE_SECURE,env=CSRF_COOKIE_SECURE
RUN --mount=type=secret,id=ALLOWED_HOSTS,env=ALLOWED_HOSTS
RUN --mount=type=secret,id=SECURE_CONTENT_TYPE_NOSNIFF,env=SECURE_CONTENT_TYPE_NOSNIFF
RUN --mount=type=secret,id=SECURE_SSL_REDIRECT,env=SECURE_SSL_REDIRECT
RUN --mount=type=secret,id=SECURE_HSTS_SECONDS,env=SECURE_HSTS_SECONDS
RUN --mount=type=secret,id=SECURE_HSTS_INCLUDE_SUBDOMAINS,env=SECURE_HSTS_INCLUDE_SUBDOMAINS
RUN --mount=type=secret,id=SECURE_HSTS_PRELOAD,env=SECURE_HSTS_PRELOAD
RUN --mount=type=secret,id=CORS_ALLOW_ALL_ORIGINS,env=CORS_ALLOW_ALL_ORIGINS
RUN --mount=type=secret,id=CSRF_TRUSTED_ORIGINS,env=CSRF_TRUSTED_ORIGINS

# Copy the entire backend directory
COPY . .

# Collect static files (if needed)
RUN python manage.py collectstatic --noinput || true

# Run database migrations
RUN python manage.py migrate --noinput || true

# Expose port 7860 (Hugging Face Spaces default port)
EXPOSE 7860

# Set environment variables for production
ENV DJANGO_SETTINGS_MODULE=backend.settings
ENV PYTHONUNBUFFERED=1
ENV DEBUG=False

# Run the application with uvicorn
# Hugging Face Spaces will set PORT environment variable, default to 7860
CMD uvicorn backend.asgi:application --host 0.0.0.0 --port ${PORT:-7860} --workers 1

