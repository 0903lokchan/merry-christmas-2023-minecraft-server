#! /bin/bash

# To be configured as the start-up script of server VM
disk_mount=/home/minecraft
screen_name=mcs

$disk_mount/backup.sh
sudo screen -r $screen_name -X stuff '/stop\n'