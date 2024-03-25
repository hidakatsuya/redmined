#!/bin/bash -e

if [ -n "$USER_ID" ] && [ -n "$GROUP_ID" ]; then
  sudo usermod -u $USER_ID $USER_NAME > /dev/null
  sudo groupmod -g $GROUP_ID $USER_NAME > /dev/null

  export HOME=/home/$USER_NAME

  exec setpriv --reuid=$USER_ID --regid=$GROUP_ID --init-groups "$@"
else
  exec "$@"
fi

