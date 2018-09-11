#!/usr/bin/env bats

RUNOPTS="-i --rm"
IMG="dgricci/stretch:$(< VERSION)"

setup() {
    echo "setting up ..."
}

@test "no information about the user running the container" {
    run bash -c "echo -e 'whoami\n' | docker run ${RUNOPTS} ${IMG}"
    [[ ${status} -eq 0 ]]
    [[ "$(echo ${output} | tr -d '\r\n')" = "root" ]]
}

@test "give the identifier of the current user" {
    local uid="$(id -u)"
    run bash -c "echo -e 'tail -n 1 /etc/group\ntail -n 1 /etc/passwd\nexit' | docker run ${RUNOPTS} -e USER_ID=${uid} ${IMG}"
    [[ ${status} -eq 0 ]]
    [[ "$(echo ${lines[0]} | tr -d '\r\n')" = "xuser:x:${uid}:" ]]
    [[ "$(echo ${lines[1]} | tr -d '\r\n')" = "xuser:x:${uid}:${uid}:identity to handle permissions with docker's volumes:/home/xuser:/bin/bash" ]]
}

@test "add a group id of 2000" {
    local uid="$(id -u)"
    local gid=2000
    run bash -c "echo -e 'tail -n 1 /etc/group\ntail -n 1 /etc/passwd\nexit' | docker run ${RUNOPTS} -e USER_ID=${uid} -e USER_GP=${gid} ${IMG}"
    [[ ${status} -eq 0 ]]
    [[ "$(echo ${lines[0]} | tr -d '\r\n')" = "xuser:x:${gid}:" ]]
    [[ "$(echo ${lines[1]} | tr -d '\r\n')" = "xuser:x:${uid}:${gid}:identity to handle permissions with docker's volumes:/home/xuser:/bin/bash" ]]
}

@test "add dgricci as user name" {
    local uid="$(id -u)"
    local gid=2000
    local unm="dgricci"
    run bash -c "echo -e 'tail -n 1 /etc/group\ntail -n 1 /etc/passwd\nexit' | docker run ${RUNOPTS} -e USER_ID=${uid} -e USER_GP=${gid} -e USER_NAME=${unm} ${IMG}"
    [[ ${status} -eq 0 ]]
    [[ "$(echo ${lines[0]} | tr -d '\r\n')" = "${unm}:x:${gid}:" ]]
    [[ "$(echo ${lines[1]} | tr -d '\r\n')" = "${unm}:x:${uid}:${gid}:identity to handle permissions with docker's volumes:/home/${unm}:/bin/bash" ]]
}

@test "then activate debug option" {
    local uid="$(id -u)"
    local gid=2000
    local unm="dgricci"
    run bash -c "echo -e 'tail -n 1 /etc/group\ntail -n 1 /etc/passwd\nexit' | docker run ${RUNOPTS} -e USER_DEBUG=1 -e USER_ID=${uid} -e USER_GP=${gid} -e USER_NAME=${unm} ${IMG}"
    [[ ${status} -eq 0 ]]
    [[ "$(echo ${lines[0]} | tr -d '\r\n')" = "Starting container as '${unm}' (${uid}:${gid})" ]]
    [[ "$(echo ${lines[1]} | tr -d '\r\n')" = "${unm}:x:${gid}:" ]]
    [[ "$(echo ${lines[2]} | tr -d '\r\n')" = "${unm}:x:${uid}:${gid}:identity to handle permissions with docker's volumes:/home/${unm}:/bin/bash" ]]
}

teardown() {
    echo "tearing down !"
}

