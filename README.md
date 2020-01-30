# Angular CLI Docker Images

## Features

- Included all `@angular/cli` releases starts from `v1.0.0` except some buggy releases.
- Includes a default app created by `ng new` command in `/app` folder.
- Turn off Google Analytics by default.

## Usage

> Note: After container started, just navigate to <https://localhost:4200> to see app running!

1. Simply running the default app using `Angular CLI v6.0.0` and `ng serve` command.

    ```sh
    docker run --name myapp --rm -d -p 4200:4200 willh/ngcli:6.0.0
    ```

    > With `--rm` argument, when container stopped, the container will be removed automatically.

2. Mount your own app into container and run `ng serve` automatically.

    ```sh
    docker run --name myapp -d -p 4200:4200 -v /ng8:/app willh/ngcli:8.3.23
    ```

    > This will not run `npm install` automatically!

3. Mount your own app (`G:\ng8`) into container and don't run `ng serve` automatically.

    ```sh
    docker run --name myapp -it -p 4200:4200 -v G:\ng8:/app --entrypoint bash willh/ngcli:8.3.23
    npm install
    ng serve --disable-host-check --host 0.0.0.0 --poll 1000
    ```

4. Mount your own folder (`G:\ng8`) into container and `ng new` a brand new app.

    ```sh
    mkdir g:\ng8
    docker run --name myapp -it -p 4200:4200 -v G:\ng8:/app --entrypoint bash willh/ngcli:8.3.23
    cd /
    ng new app --defaults --skip-git
    cd /app
    ng serve --disable-host-check --host 0.0.0.0 --poll 1000
    ```

5. Check logs

    ```sh
    docker logs myapp
    ```

6. Check logs continuously

    ```sh
    docker logs myapp -f
    ```

7. Enter container

    ```sh
    docker exec -it myapp bash
    ```

8. Restart container (The `ng serve` will restart.)

    ```sh
    docker restart myapp
    ```

9. Stop container

    ```sh
    docker stop myapp
    ```

10. Remove container

    ```sh
    docker rm myapp
    ```

11. If you want to include some dev tools/utilities such as vim, net-tools, ... etc. inside container, check the following commands.

    ```sh
    RUN apt-get update \
        && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
        && apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" \
        && apt-get install -y --no-install-recommends apt-utils net-tools vim \
        && rm -rf /var/lib/apt/lists/*
    ```

## Build notes

1. `build.sh`

    Build all GA version from v7

2. `build.beta.sh`

    Build all BETA version from v7

3. `build.rc.sh`

    Build all RC version from v7

4. `build.next.sh`

    Build all NEXT version from v7

5. `build.v6.0.sh`

    Build all GA version for v6.0.x

6. `build.v6.1.sh`

    Build all GA version for v6.1.x

7. `build.v6.2.sh`

    Build all GA version for v6.2.x
