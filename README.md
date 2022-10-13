# FAST-LIO on OUSTER hardware in Docker
## Requirements
- docker, working ouster lidar hardware

## How to run
1. Get the docker image `docker pull eehantiming/ouster_slam:1.0`
2. Make sure the lidar is connected, then start the container with `./run.sh`
3. `cd ~/mountvol/fastlio && roslaunch main.launch`

## Configs
- The main launch file starts various launch files, comment out what you do not need
    1. ouster_ros to activate lidar
    2. external imu ros drivers if you are using one
    3. fast_lio for mapping
    4. rviz for visualization