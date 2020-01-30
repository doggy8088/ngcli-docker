#!/bin/bash

# sudo apt-get install jq -y

DockerHubTags=$(mktemp /tmp/DockerHubTags.XXXXXX.json)
NpmVersions=$(mktemp /tmp/NpmVersions.XXXXXX.json)

wget -q https://registry.hub.docker.com/v1/repositories/willh/ngcli/tags -O -   | jq '[.[].name]' > "$DockerHubTags"


npm view @angular/cli versions --json \
    | jq '[.[] | select(. | startswith("6.0"))]' \
    | jq '[.[] | select(. | contains("-next") | not)]' \
    | jq '[.[] | select(. | contains("-rc") | not)]' \
    | jq '[.[] | select(. | contains("-beta") | not)]' \
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
        if [ "$v" = "6.0.4" ]
        then
            docker build -t willh/ngcli:$v --build-arg CLI_VERSION=$v -f Dockerfile.v6.0.4 .
        else
            docker build -t willh/ngcli:$v --build-arg CLI_VERSION=$v -f Dockerfile.v6.0-6.1 .
        fi
        echo --------------------------------------------------------------
        echo "Pushing willh/ngcli:$v to Docker Hub ..."
        echo --------------------------------------------------------------
        docker push willh/ngcli:$v
        echo --------------------------------------------------------------
        echo "Removing willh/ngcli:$v locally."
        echo --------------------------------------------------------------
        # docker image rm willh/ngcli:$v
    fi

done < <(jq -S -c '.[]' "$NpmVersions")

rm "$NpmVersions"
rm "$DockerHubTags"
