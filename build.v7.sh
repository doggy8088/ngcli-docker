#!/bin/bash

DockerHubTags=$(mktemp /tmp/DockerHubTags.XXXXXX.json)
NpmVersions=$(mktemp /tmp/NpmVersions.XXXXXX.json)

wget -q https://registry.hub.docker.com/v2/repositories/willh/ngcli/tags -O -   | jq '[.[].name]' > "$DockerHubTags"

npm view @angular/cli versions --json \
    | jq '[.[] | select(. | startswith("7."))]' \
    | jq '[.[] | select(. | contains("-next") | not)]' \
    | jq '[.[] | select(. | contains("-rc") | not)]' \
    | jq '[.[] | select(. | contains("-beta") | not)]' \
    | jq 'reverse' \
    > "$NpmVersions"

while read n; do
    IsCreated=0
    v=${n//\"/}
    # echo Npm Version: $v
    while read d; do
        if [ "$v" = "${d//\"/}" ]
        then
            IsCreated=$((1))
            echo --------------------------------------------------------------
            echo "This Docker Tag willh/ngcli:$v is already created!"
            echo --------------------------------------------------------------
        fi
    done < <(jq -c '.[]' "$DockerHubTags")

    if [ "$IsCreated" = "0" ]
    then
        echo --------------------------------------------------------------
        echo "Creating willh/ngcli:$v ..."
        echo --------------------------------------------------------------
        docker build -t willh/ngcli:$v --build-arg CLI_VERSION=$v -f Dockerfile.v7 .
        echo --------------------------------------------------------------
        echo "Pushing willh/ngcli:$v to Docker Hub ..."
        echo --------------------------------------------------------------
        docker push willh/ngcli:$v
        # echo docker push willh/ngcli:$v >> docker_push_v7.log
        echo --------------------------------------------------------------
        echo "Removing willh/ngcli:$v locally."
        echo --------------------------------------------------------------
        docker image rm willh/ngcli:$v
    fi

done < <(jq -S -c '.[]' "$NpmVersions")

rm "$NpmVersions"
rm "$DockerHubTags"
