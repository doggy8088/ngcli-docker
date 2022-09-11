#!/bin/bash

DockerHubTags=$(mktemp /tmp/DockerHubTags.XXXXXX.json)
NpmVersions=$(mktemp /tmp/NpmVersions.XXXXXX.json)

wget -q https://registry.hub.docker.com/v2/repositories/willh/ngcli/tags -O -   | jq '[.[].name]' > "$DockerHubTags"

npm view @angular/cli versions --json \
    | jq '[.[] | select(. | startswith("9."))]' \
    | jq '[.[] | select(. | contains("-next") | not)]' \
    | jq '[.[] | select(. | contains("-beta") | not)]' \
    | jq 'reverse' \
    > "$NpmVersions"
    # | jq '[.[] | select(. | contains("-rc") | not)]' \

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
        docker build -t willh/ngcli:$v --build-arg CLI_VERSION=$v -f Dockerfile .
        echo --------------------------------------------------------------
        echo "Pushing willh/ngcli:$v to Docker Hub ..."
        echo --------------------------------------------------------------
        # echo docker push willh/ngcli:$v >> docker_push_v9.log
        docker push willh/ngcli:$v
        echo --------------------------------------------------------------
        echo "Removing willh/ngcli:$v locally."
        echo --------------------------------------------------------------
        # echo docker push willh/ngcli:$v >> docker_rmi_v9.log
        docker image rm willh/ngcli:$v
    fi

done < <(jq -S -c '.[]' "$NpmVersions")

rm "$NpmVersions"
rm "$DockerHubTags"
