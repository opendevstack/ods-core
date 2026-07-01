#!/bin/bash
# Helper script to encrypt secrets for environments
# Usage: ./encrypt-helm-secrets.sh <FOLDER> [ENV|all] [-y]

# Parse parameters
FOLDER="${1}"
ENV="${2}"
REMOVE_UNENCRYPTED=false

# Check for -y flag in any position
for arg in "$@"; do
    if [ "$arg" = "-y" ] || [ "$arg" = "--yes" ]; then
        REMOVE_UNENCRYPTED=true
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
    echo "  all     - Encrypt root + all environment subfolders"
    echo "  -y      - Auto-remove unencrypted files (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 ../ods-configuration              # Encrypt root folder only"
    echo "  $0 ../ods-configuration local        # Encrypt local environment folder"
    echo "  $0 ../ods-configuration all          # Encrypt root + all environments"
    echo "  $0 ../ods-configuration all -y       # Encrypt all, auto-remove originals"
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

# Function to encrypt all secrets in a folder
encrypt_secrets_in_folder() {
    local folder=$1
    local label=$2
    local encrypted_count=0
    
    echo ""
    echo "Processing: $label"
    echo "  Location: $folder"
    
    if [ ! -d "$folder" ]; then
        echo "  ⚠ Folder not found"
        return 0
    fi
    
    # Find and encrypt all *.secrets.* files
    while IFS= read -r secrets_file; do
        # Convert filename: *.secrets.*.dec.yaml → *.secrets.*.enc.yaml
        if [[ "$secrets_file" == *.dec.yaml ]]; then
            encrypted_file="${secrets_file%.dec.yaml}.enc.yaml"
        elif [[ "$secrets_file" == *.yaml ]]; then
            encrypted_file="${secrets_file%.yaml}.enc.yaml"
        elif [[ "$secrets_file" == *.yml ]]; then
            encrypted_file="${secrets_file%.yml}.enc.yaml"
        else
            encrypted_file="${secrets_file}.enc.yaml"
        fi
        
        echo "  • Encrypting: $(basename "$secrets_file")"
        helm secrets encrypt "$secrets_file" > "$encrypted_file"
        echo "    ✓ Created: $(basename "$encrypted_file")"
        ((encrypted_count++))
        
        # Handle unencrypted file removal
        if [ "$REMOVE_UNENCRYPTED" = true ]; then
            rm "$secrets_file"
            echo "    ✓ Removed: $(basename "$secrets_file")"
        else
            if [ -t 0 ]; then
                read -p "    Remove unencrypted file? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm "$secrets_file"
                    echo "    ✓ Removed: $(basename "$secrets_file")"
                fi
            else
                echo "    (Use -y flag to auto-remove)"
            fi
        fi
    done < <(find "$folder" -maxdepth 2 -type f \( -name "*secrets*.dec.yaml" -o -name "*secrets*.yaml" \) ! -name "*.enc.yaml" 2>/dev/null)
    
    if [ $encrypted_count -eq 0 ]; then
        echo "  ⚠ No secrets files found"
        return 0
    fi
    
    echo "  ✓ Encrypted $encrypted_count file(s)"
}

# Main logic
if [ "$ENV" = "all" ]; then
    # Encrypt root + all environment folders
    echo "=== Encrypting all folders ==="
    encrypt_secrets_in_folder "$FOLDER" "root folder"
    
    # Find and process environment subfolders
    while IFS= read -r -d '' env_folder; do
        env_name=$(basename "$env_folder")
        encrypt_secrets_in_folder "$env_folder" "environment: $env_name"
    done < <(find "$FOLDER" -maxdepth 2 -type d ! -name ".*" -print0 | grep -zv "^$FOLDER$")
    
elif [ -n "$ENV" ]; then
    # Encrypt specific environment folder
    env_folder="$FOLDER/$ENV"
    if [ ! -d "$env_folder" ]; then
        echo "❌ Environment folder not found: $env_folder"
        echo ""
        echo "Available environments:"
        find "$FOLDER" -maxdepth 2 -type d ! -name ".*" ! -path "$FOLDER" -exec basename {} \;
        exit 1
    fi
    encrypt_secrets_in_folder "$env_folder" "environment: $ENV"
else
    # No ENV specified - encrypt root folder
    encrypt_secrets_in_folder "$FOLDER" "root folder"
fi

# Summary
echo ""
echo "=========================================="
echo "✓ Encryption Complete"
echo ""
echo "View encrypted files:"
echo "  helm secrets view <file>.enc.yaml"
echo ""
echo "Edit encrypted files:"
echo "  helm secrets edit <file>.enc.yaml"
echo "=========================================="
