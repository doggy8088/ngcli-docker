FROM node:lts AS build

RUN apt-get update \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"

# docker build -t willh/ngcli:latest --build-arg CLI_VERSION=8.0.0 -f Dockerfile .
ARG CLI_VERSION

# https://angular.io/cli/analytics
ENV NG_CLI_ANALYTICS=off

# Install Angular CLI
RUN npm install -g @angular/cli@${CLI_VERSION}

WORKDIR /app

CMD [ "bash" ]