#!/bin/bash

set -e

echo "Starting certificate installation..."

# Define custom truststore location next to app.jar
CUSTOM_TRUSTSTORE="/home/default/custom-truststore.jks"
TRUSTSTORE_PASSWORD="changeit"

# Check if CERT_URLS is set and not empty
if [ -z "$CERT_URLS" ]; then
    echo "No certificates to install (CERT_URLS is empty)"
    echo "Skipping custom truststore creation"
    exit 0
fi

# Create temporary directory for certificates
CERT_DIR=$(mktemp -d)
echo "Created temporary directory: $CERT_DIR"

echo "Creating new custom truststore from scratch at: $CUSTOM_TRUSTSTORE"

# Remove existing truststore if it exists
rm -f "$CUSTOM_TRUSTSTORE"

# Split CERT_URLS by comma and process each URL
IFS=',' read -ra URLS <<< "$CERT_URLS"
CERT_INDEX=1

for url in "${URLS[@]}"; do
    # Trim whitespace
    url=$(echo "$url" | xargs)
    
    if [ -z "$url" ]; then
        continue
    fi
    
    echo "Downloading certificate from: $url"
    
    # Download certificate
    CERT_FILE="$CERT_DIR/cert-${CERT_INDEX}.crt"
    
    if curl -ksSfL -o "$CERT_FILE" "$url"; then
        echo "Certificate downloaded successfully"
        
        # Generate alias for the certificate
        ALIAS="custom-cert-${CERT_INDEX}"
        
        # Import certificate into custom truststore
        echo "Installing certificate with alias: $ALIAS"
        
        if ! keytool -import -trustcacerts -noprompt \
            -alias "$ALIAS" \
            -file "$CERT_FILE" \
            -keystore "$CUSTOM_TRUSTSTORE" \
            -storepass "$TRUSTSTORE_PASSWORD" 2>/dev/null; then
            
            echo "Warning: Failed to install certificate from $url (it may already exist)"
        else
            echo "Certificate installed successfully"
        fi
        
        CERT_INDEX=$((CERT_INDEX + 1))
    else
        echo "Error: Failed to download certificate from $url"
        # Continue with other certificates instead of failing
    fi
done

# Cleanup
rm -rf "$CERT_DIR"
echo "Certificate installation completed"
echo "Custom truststore location: $CUSTOM_TRUSTSTORE"
