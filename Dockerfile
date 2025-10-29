# Use official Python slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies (if any) and create a non-root user
RUN useradd -m appuser \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose port used by the Flask app
EXPOSE 5001

# Drop privileges
USER appuser

# Default command to run the web app
# PORT environment variable is read by app.py (supports Render.com dynamic ports)
CMD ["python", "app.py"]


