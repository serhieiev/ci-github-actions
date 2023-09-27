#!/bin/bash

REPO_URL="git@github.com:serhieiev/devops_intern_serhieiev.git"
BACKUP_DIR=/backups
VERSIONS_FILE="$BACKUP_DIR/versions.json"

# Check for jq installation
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed."
    exit 1
fi

# Ensure the private key has the correct permissions
chmod 600 /root/.ssh/id_rsa

# Ensure GitHub is in known hosts
if [ ! -f /root/.ssh/known_hosts ]; then
    touch /root/.ssh/known_hosts
fi
sed -i '/github.com/d' /root/.ssh/known_hosts
ssh-keyscan github.com >> /root/.ssh/known_hosts 2>/dev/null

# Remove temp_repo directory if it exists
rm -rf temp_repo

# Clone the repo
git clone $REPO_URL temp_repo
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone the repository."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Determine the next backup version
if [ ! -f $VERSIONS_FILE ] || [ $(jq 'length' $VERSIONS_FILE) -eq 0 ]; then
    echo "[]" > $VERSIONS_FILE
    VERSION="1.0.0"
else
    LAST_VERSION=$(jq -r '.[-1].version' $VERSIONS_FILE)
    if [[ "$LAST_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        IFS='.' read -ra ADDR <<< "$LAST_VERSION"
        ADDR[2]=$((ADDR[2]+1))
        VERSION="${ADDR[0]}.${ADDR[1]}.${ADDR[2]}"
    else
        echo "Error: Invalid version format in versions.json."
        exit 1
    fi
fi

# Check if backup with the same name already exists
if [ -f "$BACKUP_DIR/devops_internship_$VERSION.tar.gz" ]; then
    echo "Error: Backup with the name devops_internship_$VERSION.tar.gz already exists."
    exit 1
fi

# Archive the repo
tar -czf "devops_internship_$VERSION.tar.gz" temp_repo

# Move the archive to the backup directory
mv "devops_internship_$VERSION.tar.gz" $BACKUP_DIR

# Update versions.json
DATE=$(date +"%d.%m.%Y")
SIZE=$(stat -c%s "$BACKUP_DIR/devops_internship_$VERSION.tar.gz")
jq ". += [
  {
    \"version\": \"$VERSION\",
    \"date\": \"$DATE\",
    \"size\": $SIZE,
    \"filename\": \"devops_internship_$VERSION.tar.gz\"
  }
]" $VERSIONS_FILE > "$VERSIONS_FILE.tmp"
mv "$VERSIONS_FILE.tmp" $VERSIONS_FILE

# Check if MAX_BACKUPS is set as a non-negative integer
if [ -n "$MAX_BACKUPS" ]; then
    if ! [[ "$MAX_BACKUPS" =~ ^[0-9]+$ ]]; then
        echo "Error: MAX_BACKUPS should be a non-negative integer value."
        exit 1
    fi
fi

# Handle the case where MAX_BACKUPS=0
if [ "$MAX_BACKUPS" == "0" ]; then
    echo "Deleting all backups as MAX_BACKUPS is set to 0."
    rm -f "$BACKUP_DIR"/*.tar.gz
    exit 0
fi

# Handle max backups
if [ -n "$MAX_BACKUPS" ]; then
    ls -t $BACKUP_DIR/devops_internship_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f
fi

# Cleanup
rm -rf temp_repo

echo "Backup completed successfully!"
