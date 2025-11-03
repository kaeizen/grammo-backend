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

