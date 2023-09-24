# Task 1 DevOps 1.0

## DO #1 - Bash Scripting

First you need to clone the following repo to you host machine with the next command:
```
git clone git@github.com:serhieiev/devops_intern_serhieiev.git
```

Once the repository is cloned, change your directory to the root folder of the project.

To build the `Docker`` image. Use the following command to build the image:
```
docker build -t repo_backup_image .
```

Don't forget t build the new image with `-no-cache` flag if `backup.sh` has been modified:
```
docker build --no-cache -t repo_backup_image .
```

Once the `Docker` image has been built successfully, you can run the container using the command below. This command mounts a local directory backups to the container, which will store the backup files. Additionally, it mounts your specific GitHub private key to the container. Ensure that the path to your private key (`~/.ssh/id_rsa` in the example) is correct. If you use a different key for GitHub or if it's located elsewhere, replace `~/.ssh/id_rsa` with the appropriate path.

```
docker run -v $(pwd)/backups:/backups -v ~/.ssh/id_rsa:/root/.ssh/id_rsa repo_backup_image
```

Also adding the `-e MAX_BACKUPS=some_int` environment variable determines the maximum number of backup versions to keep. If the number of backups exceeds this value, the oldest backups will be deleted until the count matches the specified maximum. Passong `-e MAX_BACKUPS=0` deletes all backups.

Example of a command can look like (keep 5 latest backups):
```
docker run -v $(pwd)/backups:/backups -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -e MAX_BACKUPS=5 repo_backup_image
```

After executing the above command, you should see a folder named `backups` in your current directory. Inside this folder, you'll find the backup files, which are the result of executing the `backup.sh` script inside the Docker container.


## DO #2 - Docker/Docker Compose

Make sure that the following repo is cloned to you host machine :
```
git clone git@github.com:serhieiev/devops_intern_serhieiev.git
```

Change your directory to the root folder of the project.

Copy the sample of environment configuration file:
```
cp .env.sample .env
```

Adjust the `.env` file and update variables according your setup.

Build and start the `Docker` containers with `docker-compose`:
```
docker-compose up --build
```

Navigate to the following link in your browser:
``` 
http://localhost
```

You should see helth-check like:
```
Status: 200
Date: 9/23/23, 5:54 PM
Message: I'm alive
```

To stop containers:
```
docker-compose down
```