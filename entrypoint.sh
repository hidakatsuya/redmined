#!/bin/bash -e

export HOME=/home/$USER_NAME

sudo chown -R $USER_NAME:$USER_NAME /bundle

# If USER_ID and GROUP_ID are set, they will be set to the UID and GID of the developer user
if [ -n "$USER_ID" ] && [ -n "$GROUP_ID" ]; then
    usermod -u $USER_ID $USER_NAME > /dev/null
    groupmod -g $GROUP_ID $USER_NAME > /dev/null

    exec setpriv --reuid=$USER_ID --regid=$GROUP_ID --init-groups "$@"
else
    exec setpriv --reuid=$(id -u $USER_NAME) --regid=$(id -g $USER_NAME) --init-groups "$@"
fi
