#! /bin/bash

disk_name=google-persistent-disk-1
disk_mount=/home/minecraft
server_dir=$disk_mount/server

# check if persistant disk is mounted
echo "INFO Checking disk mounts..."
if grep -qs '/home/minecraft' /proc/mounts; then
    echo "INFO A disk mounted to $disk_mount. Proceeding..."
else
    echo "WARNING No disk is mounted to $disk_mount. Attempting to mount disk $disk_name..."
    sudo mount /dev/disk/by-id/$disk_name $disk_mount
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "ERROR occured when mounting $disk_name to $disk_mount. Exiting with return code $retVal..."
        exit $retVal
    else
        echo "INFO Successfully mounted $disk_name to $disk_mount. Proceeding..."
    fi
fi

# Check if Minecraft server files exist
echo "INFO Checking Minecraft server files..."
if [ ! -d $server_dir ]; then
    echo "ERROR server directory $server_dir does not exist. Exiting with return code 1..."
    exit 1
fi
if [ ! -f $server_dir/run.sh ]; then
    echo "ERROR server run script $server_dir/run.sh does not exist. Exiting with return code 1..."
    exit 1
fi
echo "INFO Minecraft server checks are OK. Proceeding..."

# Check if Minecraft world save exists
echo "INFO Checking Minecraft world save..."
if [ ! -d $server_dir/world ]; then
    echo "WARNING Minecraft world data is not found. Do you wish do proceed with generating a new world?"
    select yn in "Yes" "No"; do
        case $yn in
        Yes)
            echo "INFO Proceeding with a new Minecraft world..."
            break
            ;;
        No)
            echo "ERROR server directory $server_dir/world does not exist. Exiting with return code 1..."
            exit 1
            ;;
        esac
    done
fi
world_mtime=$(stat -c %y $server_dir/world)
echo "INFO The last modification time of minecraft world is at $world_mtime"

echo "INFO All pre-checks are completed. Proceeding with starting the server..."

# Move pwd so run.sh correctly picks up the java arguments
cd /home/minecraft/server
# Start a detached screen for running Minecraft in the background, while allowing attaching for server ops
screen -dmS mcs sudo sh /home/minecraft/server/run.sh

echo 'INFO Successfully start up the Minecraft server. Run "screen -r mcs" to log into the server session.'
echo "INFO Exiting with return code 0..."
exit 0
