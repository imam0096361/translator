#!/bin/bash

# Deployment script for Daily Star Style Translator
# Usage: ./deploy.sh

set -e

echo "🚀 Starting deployment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with GEMINI_API_KEY"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check if GEMINI_API_KEY is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY not set in .env file"
    exit 1
fi

echo "✅ Environment variables loaded"

# Build and start containers
echo "📦 Building Docker image..."
docker-compose build --build-arg GEMINI_API_KEY="$GEMINI_API_KEY"

echo "🚀 Starting containers..."
docker-compose up -d

echo "⏳ Waiting for container to be healthy..."
sleep 5

# Check container status
if docker-compose ps | grep -q "Up"; then
    echo "✅ Deployment successful!"
    echo "🌐 Application should be available at:"
    echo "   - Local: http://localhost:9999"
    echo "   - Network: http://your-server-ip:9999"
    echo "   - Domain: http://translator-ai.dailystar.press:9999"
    echo ""
    echo "⚠️  Don't forget to configure firewall:"
    echo "   sudo ufw allow 9999/tcp"
    echo ""
    echo "View logs with: docker-compose logs -f"
    echo "Stop with: docker-compose down"
else
    echo "❌ Deployment failed. Check logs with: docker-compose logs"
    exit 1
fi

