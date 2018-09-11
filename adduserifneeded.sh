#!/bin/bash
#
# add a user named USER_NAME (defaults to 'xuser') under a specific USER_ID
# (environmement variable passed to the docker run command, option -e). It is
# assumed that the group id is the same as the USER_ID when no USER_GP is
# given. If no USER_ID is given, no unix user is created.
#
# Based on this blog's article : https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
if [ -n "$USER_ID" ] ; then
    userId="$USER_ID"
    userGp="${USER_GP:-${USER_ID}}"
    userName="${USER_NAME:-xuser}"
    [ ! -z "$USER_DEBUG" ] && echo "Starting container as '$userName' ($userId:$userGp)"
    gOption=""
    [ ! -z "$USER_GP" ] && {
        gOption="-g $userGp"
        groupadd -g $userGp -o $userName
    }
    useradd --shell /bin/bash -u $userId $gOption -o -c "identity to handle permissions with docker's volumes" -m $userName
    export HOME="/home/$userName"
    # we suppose gosu is in the PATH ...
    exec gosu "$userName" "$@"
else
    [ ! -z "$USER_DEBUG" ] && echo "Starting container as '$(whoami)' ($(id -u):$(id -g))"
    exec "$@"
fi

