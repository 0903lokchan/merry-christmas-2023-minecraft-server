#! /bin/bash

world_zip_name=world.zip
disk_name=google-persistent-disk-1
disk_mount=/home/minecraft
server_dir=$disk_mount/server

if [ ! -f $world_zip_name ]; then
    echo "ERROR World save file $world_zip_name is not found in current workdir. Exiting with return code 1..."
    exit 1
fi

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

# check for existing world save
if [ -d $server_dir/world ]; then
    world_mtime=$(stat -c %y $server_dir/world)
    echo "WARNING There is an existing world save last modified at $world_mtime. Do you wish to overwrite the world save?"
    select yn in "Yes" "No"; do
        case $yn in
        Yes)
            echo "INFO Proceeding with overwriting the world save..."
            sudo rm -rf $server_dir/world
            break
            ;;
        No)
            echo "INFO Aborting the unpack of world save to $server_dir/world. Exiting with return code 0..."
            exit 0
            ;;
        esac
    done
fi

sudo unzip $world_zip_name -d $server_dir
retVal=$?
if [ $retVal -ne 0 ]; then
        echo "ERROR occured when unzipping $disk_name to $server_dir with error code $retVal. Exiting with return code $retVal..."
        exit $retVal
    else
        echo "INFO Successfully mounted unzipping $disk_name to $server_dir."
    fi