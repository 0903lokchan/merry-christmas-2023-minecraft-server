#!/bin/bash
# trigger saving, then turn off autosaving of minecraft server
screen -r mcs -X stuff '/save-all\n/save-off\n'
# copy world/ to bucket
/usr/bin/gsutil cp -R ${BASH_SOURCE%/*}/server/world gs://merry-christmas-2023-407806-minecraft-backup/$(date "+%Y%m%d-%H%M%S")-world
# turn minecraft server's autosave back on
screen -r mcs -X stuff '/save-on\n'

