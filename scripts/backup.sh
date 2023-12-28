#!/bin/bash

screen_name=mcs
disk_mount=/home/minecraft
bucket_name=merry-christmas-2023-407806-minecraft-backup

# trigger saving, then turn off autosaving of minecraft server
screen -r mcs -X stuff '/save-all\n/save-off\n'
# copy world/ to bucket
/usr/bin/gsutil cp -R $disk_mount/server/world gs://$bucket_name/$(date "+%Y%m%d-%H%M%S")-world
# turn minecraft server's autosave back on
screen -r mcs -X stuff '/save-on\n'

