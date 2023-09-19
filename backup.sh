#!/bin/bash

REPO_URL="git@github.com:serhieiev/devops_intern_serhieiev.git"
BACKUP_DIR=/backups
VERSIONS_FILE="$BACKUP_DIR/versions.json"

# Check for jq installation
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed."
    exit 1
fi

# Set up the SSH key for git operations
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo -n "$PRIVATE_KEY_ENCODED" | base64 -d > /root/.ssh/id_rsa
chmod 700 /root/.ssh/id_rsa
ls -l /root/.ssh/id_rsa
ssh-keyscan github.com >> /root/.ssh/known_hosts

# Clone the repo
git clone $REPO_URL temp_repo
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone the repository."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Determine the next backup version
if [ ! -f $VERSIONS_FILE ]; then
    echo "[]" > $VERSIONS_FILE
    VERSION="1.0.0"
else
    LAST_VERSION=$(jq -r '.[-1].version' $VERSIONS_FILE)
    IFS='.' read -ra ADDR <<< "$LAST_VERSION"
    ADDR[2]=$((ADDR[2]+1))
    VERSION="${ADDR[0]}.${ADDR[1]}.${ADDR[2]}"
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
jq ". += [{\"version\": \"$VERSION\", \"date\": \"$DATE\", \"size\": $SIZE, \"filename\": \"devops_internship_$VERSION.tar.gz\"}]" $VERSIONS_FILE > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" $VERSIONS_FILE

# Handle max backups
if [ "$1" == "--max-backups" ] && [ -n "$2" ]; then
    while [ $(jq 'length' $VERSIONS_FILE) -gt $2 ]; do
        OLDEST_FILE=$(jq -r '.[0].filename' $VERSIONS_FILE)
        if [ -f "$BACKUP_DIR/$OLDEST_FILE" ]; then
            rm "$BACKUP_DIR/$OLDEST_FILE"
        else
            echo "Warning: File $OLDEST_FILE not found."
        fi
        jq 'del(.[0])' $VERSIONS_FILE > "$VERSIONS_FILE.tmp" && mv "$VERSIONS_FILE.tmp" $VERSIONS_FILE
    done
fi

# Cleanup
rm -rf temp_repo

# Remove the SSH key after use
rm /root/.ssh/id_rsa

echo "Backup completed successfully!"
