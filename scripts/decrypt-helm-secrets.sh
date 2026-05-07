#!/bin/bash
# Helper script to decrypt secrets for environments
# Usage: ./decrypt-helm-secrets.sh <FOLDER> [ENV|all] [-y]
# Mirrors the logic of encrypt-helm-secrets.sh but for decryption

# Parse parameters
FOLDER="${1}"
ENV="${2}"
REMOVE_ENCRYPTED=false

# Check for -y flag in any position
for arg in "$@"; do
    if [ "$arg" = "-y" ] || [ "$arg" = "--yes" ]; then
        REMOVE_ENCRYPTED=true
    fi
done

# Validate folder parameter
if [ -z "$FOLDER" ]; then
    echo "❌ Error: FOLDER parameter is required"
    echo ""
    echo "Usage: $0 <FOLDER> [ENV|all] [-y]"
    echo ""
    echo "Parameters:"
    echo "  FOLDER  - Path to configuration folder"
    echo "  ENV     - Environment name (e.g., local, dev). If omitted, uses root folder"
    echo "  all     - Decrypt root + all environment subfolders"
    echo "  -y      - Auto-remove encrypted files (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 ../ods-configuration              # Decrypt root folder only"
    echo "  $0 ../ods-configuration local        # Decrypt local environment folder"
    echo "  $0 ../ods-configuration all          # Decrypt root + all environments"
    echo "  $0 ../ods-configuration all -y       # Decrypt all, auto-remove originals"
    exit 1
fi

# Validate folder exists
if [ ! -d "$FOLDER" ]; then
    echo "❌ Folder not found: $FOLDER"
    exit 1
fi

# Check if helm-secrets is available
if ! helm plugin list | grep -q secrets; then
    echo "❌ helm-secrets plugin is not installed"
    exit 1
fi

# Check if SOPS is available
if ! command -v sops &> /dev/null; then
    echo "❌ SOPS is not installed"
    exit 1
fi

# Check if GPG is available
if ! command -v gpg &> /dev/null; then
    echo "❌ GPG is not installed"
    exit 1
fi

# Check if user has GPG keys
if ! gpg --list-secret-keys &> /dev/null || [ -z "$(gpg --list-secret-keys 2>/dev/null)" ]; then
    echo "❌ No GPG secret keys found"
    exit 1
fi

# Function to decrypt all secrets in a folder
decrypt_secrets_in_folder() {
    local folder=$1
    local label=$2
    local decrypted_count=0
    
    echo ""
    echo "Processing: $label"
    echo "  Location: $folder"
    
    if [ ! -d "$folder" ]; then
        echo "  ⚠ Folder not found"
        return 0
    fi
    
    # Find and decrypt all *.enc.yaml files
    while IFS= read -r encrypted_file; do
        # Convert filename: *.enc.yaml → *.dec.yaml
        decrypted_file="${encrypted_file%.enc.yaml}.dec.yaml"
        
        echo "  • Decrypting: $(basename "$encrypted_file")"
        helm secrets decrypt "$encrypted_file" > "$decrypted_file"
        echo "    ✓ Created: $(basename "$decrypted_file")"
        ((decrypted_count++))
        
        # Handle encrypted file removal
        if [ "$REMOVE_ENCRYPTED" = true ]; then
            rm "$encrypted_file"
            echo "    ✓ Removed: $(basename "$encrypted_file")"
        else
            if [ -t 0 ]; then
                read -p "    Remove encrypted file? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm "$encrypted_file"
                    echo "    ✓ Removed: $(basename "$encrypted_file")"
                fi
            else
                echo "    (Use -y flag to auto-remove)"
            fi
        fi
    done < <(find "$folder" -maxdepth 2 -type f -name "*secrets*.enc.yaml" 2>/dev/null)
    
    if [ $decrypted_count -eq 0 ]; then
        echo "  ⚠ No encrypted secrets files found"
        return 0
    fi
    
    echo "  ✓ Decrypted $decrypted_count file(s)"
}

# Main logic
if [ "$ENV" = "all" ]; then
    # Decrypt root + all environment folders
    echo "=== Decrypting all folders ==="
    decrypt_secrets_in_folder "$FOLDER" "root folder"
    
    # Find and process environment subfolders
    while IFS= read -r -d '' env_folder; do
        env_name=$(basename "$env_folder")
        decrypt_secrets_in_folder "$env_folder" "environment: $env_name"
    done < <(find "$FOLDER" -maxdepth 2 -type d ! -name ".*" -print0 | grep -zv "^$FOLDER$")
    
elif [ -n "$ENV" ]; then
    # Decrypt specific environment folder
    env_folder="$FOLDER/$ENV"
    if [ ! -d "$env_folder" ]; then
        echo "❌ Environment folder not found: $env_folder"
        echo ""
        echo "Available environments:"
        find "$FOLDER" -maxdepth 2 -type d ! -name ".*" ! -path "$FOLDER" -exec basename {} \;
        exit 1
    fi
    decrypt_secrets_in_folder "$env_folder" "environment: $ENV"
else
    # No ENV specified - decrypt root folder
    decrypt_secrets_in_folder "$FOLDER" "root folder"
fi

# Summary
echo ""
echo "=========================================="
echo "✓ Decryption Complete"
echo ""
echo "View decrypted files:"
echo "  cat <file>.dec.yaml"
echo ""
echo "Edit decrypted files:"
echo "  vim <file>.dec.yaml"
echo ""
echo "Re-encrypt when done:"
echo "  ./scripts/encrypt-helm-secrets.sh $FOLDER $([ -n "$ENV" ] && echo "$ENV" || echo "")"
echo "=========================================="
