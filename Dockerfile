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

RUN --mount=type=secret,id=SECRET_KEY,mode=0444,required=true \
   sh -c 'printf "SECRET_KEY=%s\n" "$(cat /run/secrets/SECRET_KEY)" >> .env'

RUN --mount=type=secret,id=HUGGINGFACEHUB_API_TOKEN,mode=0444,required=true \
    sh -c 'printf "HUGGINGFACEHUB_API_TOKEN=%s\n" "$(cat /run/secrets/HUGGINGFACEHUB_API_TOKEN)" >> .env'

ARG ALLOWED_HOSTS
ARG CSRF_TRUSTED_ORIGINS

RUN printf "ALLOWED_HOSTS=%s\n" "${ALLOWED_HOSTS}" >> .env
RUN printf "CSRF_TRUSTED_ORIGINS=%s\n" "${CSRF_TRUSTED_ORIGINS}" >> .env

# Copy the entire backend directory
COPY . .

# Run database migrations
RUN python manage.py migrate --noinput || true

# Expose port 7860 (Hugging Face Spaces default port)
EXPOSE 7860

# Set environment variables for production
ENV DJANGO_SETTINGS_MODULE=backend.settings
ENV PYTHONUNBUFFERED=1
ENV DEBUG=False
ENV BUILD_MODE='production'

# Run the application with uvicorn
# Hugging Face Spaces will set PORT environment variable, default to 7860
CMD uvicorn backend.asgi:application --host 0.0.0.0 --port ${PORT:-7860} --workers 1

