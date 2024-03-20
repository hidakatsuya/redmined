#!/bin/bash -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [ "$GROUP_ID" != "0" ]; then
  groupadd -g $GROUP_ID -o $USER_NAME
fi

if [ "$USER_ID" != "0" ]; then
  useradd -d /home/$USER_NAME -m -s /bin/bash -u $USER_ID -g $GROUP_ID $USER_NAME
fi

sudo chmod u-s /usr/sbin/useradd
sudo chmod u-s /usr/sbin/groupadd

exec $@

