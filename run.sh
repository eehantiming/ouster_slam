xhost +local:docker 
docker run -it --rm \
    --privileged \
    --gpus=all \
	--net=host \
	--ipc host \
    -e "DISPLAY=$DISPLAY" \
    -e "QT_X11_NO_MITSHM=1" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -v "$PWD/mountvol:/root/mountvol" \
    --name ouster_slam \
    eehantiming/ouster_slam:1.0

