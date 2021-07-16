#!/bin/bash
wget https://sukebei.nyaa.si/download/3386625.torrent

aria2c -x 64 --bt-remove-unselected-file=true --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 *.torrent

#aria2c -x 64 --bt-remove-unselected-file=true --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 --select-file=$i-$j "magnet:?xt=urn:btih:8be1ba2cc5729d9398a6f879d2c11bab491201a7"
#rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ nice:/杂项/

#aria2c -x 64 --bt-remove-unselected-file=true --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 --select-file=601-847 *.torrent
#rm -rf ./*/*/*
#rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ nice:/杂项/
#rm -rf *.torrent

#rclone move -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ nice:/Anime
rclone copy -v --transfers 12 --checkers 16 --onedrive-chunk-size 200M --exclude "*.{sh,torrent,aria2}" /home/runner/work/DrivesDown/DrivesDown/download/ nice:/本子
#sed -i 's/1qlwVq_cOqKzqrBs-H8SQtRSjFX73puKl/1I_UqJr_96FBspNf3H_O77Xt4fHYnQsf3/g' /home/runner/.config/rclone/rclone.conf
#rclone copy -v --transfers 12 --checkers 16 --onedrive-chunk-size 100M --exclude "*.{sh,torrent,aria2}" gd:/ nice:/杂项/FC2
