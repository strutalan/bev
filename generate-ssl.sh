#!/bin/bash

# SSL Certificate Generation Script using mkcert Docker image
# This script generates local development SSL certificates

set -e

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found. Please copy .env.sample to .env and configure it."
    exit 1
fi

# Check if SERVER_NAME is set
if [ -z "$SERVER_NAME" ]; then
    echo "Error: SERVER_NAME not set in .env file"
    exit 1
fi

echo "Generating SSL certificates for: $SERVER_NAME"

# Create ssl directory if it doesn't exist
mkdir -p ssl

# Generate certificates using mkcert Docker image
docker run --rm -it \
    -v "$(pwd)/ssl:/root/.local/share/mkcert" \
    -v "$(pwd)/ssl:/certs" \
    alpine/mkcert \
    -install

# Generate the certificate for the domain
docker run --rm -it \
    -v "$(pwd)/ssl:/root/.local/share/mkcert" \
    -v "$(pwd)/ssl:/certs" \
    alpine/mkcert \
    -cert-file /certs/${SERVER_NAME}.pem \
    -key-file /certs/${SERVER_NAME}-key.pem \
    ${SERVER_NAME} \
    www.${SERVER_NAME}

# Fix permissions so nginx can read the certificates
sudo chown $(id -u):$(id -g) ssl/${SERVER_NAME}*.pem
chmod 644 ssl/${SERVER_NAME}*.pem

echo "SSL certificates generated in ./ssl/ directory:"
echo "  Certificate: ssl/${SERVER_NAME}.pem"
echo "  Private Key: ssl/${SERVER_NAME}-key.pem"
echo ""
echo "Next steps:"
echo "1. Run 'docker-compose down && docker-compose up -d' to restart with SSL"
echo "2. Access your site at https://$SERVER_NAME"