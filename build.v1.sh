#!/bin/bash

# sudo apt-get install jq -y

DockerHubTags=$(mktemp /tmp/DockerHubTags.XXXXXX.json)
NpmVersions=$(mktemp /tmp/NpmVersions.XXXXXX.json)

wget -q https://registry.hub.docker.com/v1/repositories/willh/ngcli/tags -O -   | jq '[.[].name]' > "$DockerHubTags"

npm view @angular/cli versions --json \
    | jq '[.[] | select(. | startswith("1."))]' \
    | jq '[.[] | select(. | contains("-next") | not)]' \
    | jq '[.[] | select(. | contains("-rc") | not)]' \
    | jq '[.[] | select(. | contains("-beta") | not)]' \
    > "$NpmVersions"

while read n; do
    IsCreated=0
    v=${n//\"/}

    # Buggy releases
    [ "$v" = "1.4.0" ] && continue
    [ "$v" = "1.4.1" ] && continue
    [ "$v" = "1.4.2" ] && continue
    [ "$v" = "1.4.3" ] && continue
    [ "$v" = "1.4.4" ] && continue
    [ "$v" = "1.4.5" ] && continue
    [ "$v" = "1.4.6" ] && continue
    [ "$v" = "1.4.7" ] && continue
    [ "$v" = "1.4.8" ] && continue
    [ "$v" = "1.4.9" ] && continue

    [ "$v" = "1.5.0" ] && continue
    [ "$v" = "1.5.1" ] && continue
    [ "$v" = "1.5.2" ] && continue
    [ "$v" = "1.5.3" ] && continue
    [ "$v" = "1.5.4" ] && continue
    [ "$v" = "1.5.5" ] && continue

    [ "$v" = "1.6.0" ] && continue
    [ "$v" = "1.6.1" ] && continue
    [ "$v" = "1.6.2" ] && continue
    [ "$v" = "1.6.3" ] && continue

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
        docker build -t willh/ngcli:$v --build-arg CLI_VERSION=$v -f Dockerfile.v1 .
        echo --------------------------------------------------------------
        echo "Pushing willh/ngcli:$v to Docker Hub ..."
        echo --------------------------------------------------------------
        docker push willh/ngcli:$v
        echo --------------------------------------------------------------
        echo "Removing willh/ngcli:$v locally."
        echo --------------------------------------------------------------
        docker image rm willh/ngcli:$v
    fi

done < <(jq -S -c '.[]' "$NpmVersions")

rm "$NpmVersions"
rm "$DockerHubTags"
