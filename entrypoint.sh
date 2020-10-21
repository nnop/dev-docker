#!/bin/sh

USER_ID=${HOST_USER_ID:-9001}
GROUP_ID=${HOST_GROUP_ID:-9001}

groupadd --non-unique -g "$GROUP_ID" group
if [ ! -z "$USER_ID" ] && [ "$(id -u guoqiang)" != "$USER_ID" ]; then
  usermod --non-unique --uid "$USER_ID" --gid "$GROUP_ID" guoqiang
fi

chown -R guoqiang:group /home/guoqiang

exec /sbin/su-exec guoqiang "$@"
