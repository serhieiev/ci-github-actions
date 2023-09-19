# Task 1 DevOps 1.0

## DO #1 - Bash Scripting

First you need to the clone repo to you host machine with the next command:
```
git clone git@github.com:serhieiev/devops_intern_serhieiev.git
```

Once the repository is cloned, change your directory to the root folder of the project.

Create a `.env` file by copying the provided sample:
```
cp .env.sample .env
```

For the `PRIVATE_KEY_ENCODED` variable you the value received after encoding you private key used for github to base64 format (workability guranteed only on MacOS):
```
base64 < path_to_your_private_key > encoded_key.txt
```

After `.env` is being setup, you can now proceed to build the `Docker`` image. Use the following command to build the image:
```
docker build -t repo_backup_image .
```

Once the `Docker` image has been built successfully, you can run the container using the command below. This command also mounts a local directory `backups` to the container, which will store the backup files:

```
docker run --env-file .env -v $(pwd)/backups:/backups repo_backup_image
```

After executing the above command, you should see a folder named `backups` in your current directory. Inside this folder, you'll find the backup files, which are the result of executing the `backup.sh` script inside the Docker container.