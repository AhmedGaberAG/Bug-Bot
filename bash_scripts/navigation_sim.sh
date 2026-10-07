#!/bin/bash

set -e

# Bug-Bot Navigation Simulation

ROS_DISTRO="${ROS_DISTRO:-humble}"

ROS_SETUP="/opt/ros/${ROS_DISTRO}/setup.bash"
WS_SETUP="$HOME/bugbot_ws/install/setup.bash"

# Source ROS 2

if [ ! -f "$ROS_SETUP" ]; then
    echo "ERROR: ROS 2 ${ROS_DISTRO} setup file not found:"
    echo "       ${ROS_SETUP}"
    exit 1
fi

source "$ROS_SETUP"

# Source Bug-Bot workspace

if [ ! -f "$WS_SETUP" ]; then
    echo "ERROR: Bug-Bot workspace is not built:"
    echo "       ${WS_SETUP}"
    echo "Run: colcon build"
    exit 1
fi

source "$WS_SETUP"

echo "ROS 2 Distribution : ${ROS_DISTRO}"
echo "Workspace          : ${HOME}/bugbot_ws"
echo "Starting Navigation Simulation..."
echo

ros2 launch bugbot_bringup simulated_robot.launch.py world_name:=small_house