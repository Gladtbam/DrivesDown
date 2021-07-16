#rclone copy onedrive:/软件/cadence/Linux虚拟机/EDA.part01.rar $GITHUB_WORKSPACE/download
#wget -P $GITHUB_WORKSPACE/download http://www-static.cc.gatech.edu/data_files/large_models/bunny.ply.g
cp ../*.torrent .
aria2c -x 64 --seed-time=0 --bt-tracker-connect-timeout=10 --bt-tracker-timeout=10 --select-file=1-5 *.torrent
