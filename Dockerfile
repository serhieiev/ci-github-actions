FROM debian:bullseye-slim

# Install necessary packages
RUN apt-get update && apt-get install -y git jq tar openssh-client && apt-get clean

# Copy the backup script to the container
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Run the script 3 times
CMD ["/bin/bash", "-c", "for i in {1..3}; do /backup.sh; done"]

