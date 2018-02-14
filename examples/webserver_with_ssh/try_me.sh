#!/usr/bin/env bash

set -ex

build_name="fission-demo/webserver-with-ssh:latest"
container_name="fission-demo-webserver-with-ssh"
ssh_pub_key="${SSH_PUB_KEY:-$HOME/.ssh/id_rsa.pub}"

if [[ ! -f $ssh_pub_key ]]; then
    set +x
    echo -e "\nCan't find your ssh public key at following location:"
    echo -e "\t$ssh_pub_key"
    echo -e "Please rerun this script with SSH_PUB_KEY set to the proper location like so:"
    echo -e "\tSSH_PUB_KEY=/home/MY_NAME/.ssh/id_rsa.pub"
    exit 1
fi

docker build -t "$build_name" .

container_id="`docker create -i -p 127.0.0.1:2200:22 -p 127.0.0.1:8800:80 --name $container_name $build_name`"

function cleanup {
    docker rm $container_id
}
trap cleanup EXIT

docker cp "$ssh_pub_key" "$container_id:/home/admin/.ssh/authorized_keys"

docker start -ia $container_id
