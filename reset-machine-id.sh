#!/bin/bash

RESET_FILE_PATH="/root/.reset-machine-id"

function help() {
  cat <<EOF
Usage:
 sudo ./reset-machine-id.sh                 Reset machine id and create already run indicator under path $RESET_FILE_PATH

 sudo ./reset-machine-id.sh install         Install service which run reset-machine-id.sh on every system startup if indicator file $RESET_FILE_PATH doesn't exists.
 sudo ./reset-machine-id.sh prepare         Remove indicator file so reset id script file can run during next startup.
 sudo ./reset-machine-id.sh uninstall       Uninstall script
 sudo ./reset-machine-id.sh help            Open this help
EOF
}

function resetMachineIdIfNotReset() {
  if [ ! -f "$RESET_FILE_PATH" ]; then
    printf "Going to reset machine id. \n"
    sudo rm -f /etc/machine-id
    sudo dbus-uuidgen --ensure=/etc/machine-id
    sudo rm /var/lib/dbus/machine-id
    sudo dbus-uuidgen --ensure
    sudo dhclient -r
    sudo touch "$RESET_FILE_PATH"
    printf "Machine id reset, please reboot your machine. \n"
  fi
}

function prepareForReset() {
  sudo rm "$RESET_FILE_PATH"
}

function install() {
  sudo bash -c 'echo "
[Unit]
Description=Reset machine id runner
After=default.target

[Service]
Type=simple
User=root
ExecStart=$(pwd)/reset-machine-id.sh

[Install]
WantedBy=default.target
" > /usr/lib/systemd/system/reset-machine-id.service'

  sudo systemctl enable reset-machine-id.service

  echo "Script reset-machine-id installed successfully!"
}

function uninstall() {
  sudo systemctl disable reset-machine-id.service
  sudo rm /usr/lib/systemd/system/reset-machine-id.service
  sudo rm "$RESET_FILE_PATH" &>/dev/null
  sudo rm reset-machine-id.sh
  echo "Script uninstalled successfully!"
}

if [ "$EUID" -ne 0 ]; then
  printf "Please run script as root. \n\n"
  help
  exit
fi

if [[ $# -gt 0 ]]; then

  param="$1"
  case $param in
  prepare | PREPARE)
    prepareForReset
    exit
    ;;
  install | INSTALL)
    install
    exit
    ;;
  uninstall | UNINSTALL)
    uninstall
    exit
    ;;
  help | HELP)
    help
    exit
    ;;
  esac
else
  resetMachineIdIfNotReset "$@"
fi
