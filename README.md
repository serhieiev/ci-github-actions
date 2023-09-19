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

Once the `Docker` image has been built successfully, you can run the container using the command below. This command also mounts a local directory `backups` to the container, which will store the backup files. Additionally it mounts your local `~/.ssh` directory to the container. This is necessary for container to access your GitHub private key for operations like cloning private repositories. Make sure that `~/.ssh` is the correct path on your system where your GitHub private key is stored. If not, adjust the path according to your actual setup.

```
docker run -v $(pwd)/backups:/backups -v ~/.ssh:/root/.ssh repo_backup_image
```

After executing the above command, you should see a folder named `backups` in your current directory. Inside this folder, you'll find the backup files, which are the result of executing the `backup.sh` script inside the Docker container.