#!/bin/bash -e

if [ -n "$USER_ID" ]; then
  sudo usermod -u $USER_ID $USER_NAME > /dev/null
fi

if [ -n "$GROUP_ID" ]; then
  sudo groupmod -g $GROUP_ID $USER_NAME > /dev/null
fi

exec setpriv --reuid=$USER_ID --regid=$GROUP_ID --init-groups --reset-env "$@"

