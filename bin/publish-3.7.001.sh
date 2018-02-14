#!/usr/bin/env bash

set -ex

### Config vars ###
local_tag="fission:3.7-001"
publish_tags="codeape/fission:3.7-001 codeape/fission:3.7 codeape/fission:latest"
###################

for tag in $publish_tags; do
    docker tag "$local_tag" "$tag"
    docker push "$tag"
done
