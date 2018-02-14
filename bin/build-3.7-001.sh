#!/usr/bin/env bash

set -ex
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repo_dir="`dirname $script_dir`"

### Config vars ###
base_image="alpine@sha256:7df6db5aa61ae9480f52f0b3a06a140ab98d427f86d8d5de0bedab9b8df6b1c0"
build_tag="fission:3.7-001"
build_dir="$repo_dir/build_dirs/001"
###################

build_id="`docker create \
    -it \
    -v \"$build_dir:/mnt/build_dir:ro\" \
    \"$base_image\" \
    '/mnt/build_dir/do_build.sh'`"

function cleanup {
    docker rm $build_id
}
trap cleanup EXIT

docker start -ia $build_id
docker commit \
    -c 'ENTRYPOINT ["/usr/bin/dumb-init", "--"]' \
    -c 'CMD ["/sbin/fission_init"]' \
    -m "Manual built to avoid unnecessary layers" \
    $build_id \
    $build_tag 
