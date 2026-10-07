#!/bin/bash

set -e

# Bug-Bot SLAM Simulation

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
echo "Starting SLAM Simulation..."
echo

# Run SLAM simulation in a new terminal

xterm -e "bash -c '
source ${ROS_SETUP}
source ${WS_SETUP}

ros2 launch bugbot_bringup simulated_robot.launch.py world_name:=small_house use_slam:=true
' " &

xterm_pid=$!

# Map saving

handle_input() {

    read -p "Enter command (save / save_inplace): " input

    case "$input" in

        save)
            echo "Saving map..."
            ros2 run nav2_map_server map_saver_cli -f map
            kill_xterm_and_exit
            ;;

        save_inplace)
            echo "Saving map inside Bug-Bot workspace..."

            MAP_DIR="$HOME/bugbot_ws/src/bugbot_mapping/maps/map"

            mkdir -p "$MAP_DIR"
            cd "$MAP_DIR"

            ros2 run nav2_map_server map_saver_cli -f map

            cd "$HOME/bugbot_ws"

            echo "Rebuilding bugbot_mapping..."
            colcon build --packages-select bugbot_mapping

            kill_xterm_and_exit
            ;;

        *)
            echo "Invalid command."
            echo "Use: save or save_inplace"
            ;;

    esac
}

# Kill simulation terminal

kill_xterm_and_exit() {

    echo "Stopping SLAM simulation..."

    kill "$xterm_pid" 2>/dev/null || true

    exit 0
}

# Command loop

while true; do
    handle_input
done
