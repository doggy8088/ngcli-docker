#!/bin/bash

NGCLIVersions=""

DockerHubTags=$(mktemp /tmp/DockerHubTags.XXXXXX.json)
NpmVersions=$(mktemp /tmp/NpmVersions.XXXXXX.json)

wget -q https://registry.hub.docker.com/v1/repositories/willh/ngcli/tags -O -   | jq '[.[].name]' > "$DockerHubTags"

npm view @angular/cli versions --json \
    | jq '[.[] | select(. | startswith("1.") | not)]' \
    | jq '[.[] | select(. | startswith("6.") | not)]' \
    | jq '[.[] | select(. | contains("-next"))]' \
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
        docker build -t willh/ngcli:$v --build-arg CLI_VERSION=$v -f Dockerfile .

        echo --------------------------------------------------------------
        echo "Pushing willh/ngcli:$v to Docker Hub ..."
        echo --------------------------------------------------------------
        docker push willh/ngcli:$v
        if [ "$?" = "0" ]
        then
            NGCLIVersions="${NGCLIVersions}$v "
        else
            return 1
        fi

        echo --------------------------------------------------------------
        echo "Removing willh/ngcli:$v locally."
        echo --------------------------------------------------------------
        docker image rm willh/ngcli:$v
    fi

done < <(jq -S -c '.[]' "$NpmVersions")

if [ "${NGCLIVersions}" = "" ]
then
  echo "##vso[task.setvariable variable=agent.jobstatus;]canceled"
  echo "##vso[task.complete result=Canceled;]DONE"
fi

rm "$NpmVersions"
rm "$DockerHubTags"

echo "##vso[task.setvariable variable=NGCLIVersions]${NGCLIVersions}"
