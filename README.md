# Angular CLI Docker Images

## Features

- Included all `@angular/cli` releases starts from `v1.0.0` except some buggy releases.
- All tags are identical with the `@angular/cli` npm versions ( `npm view @angular/cli versions` )
- Includes a default app created by `ng new` command that located in `/app` folder.
- Turn off Google Analytics by default.

## Usage

> Note: After container started, just navigate to <https://localhost:4200> to see app running!

1. Simply run the default app using `Angular CLI v8.3.23` and `ng serve` command.

    ```sh
    docker run --name myapp --rm -d -p 4200:4200 willh/ngcli:8.3.23 npm start
    ```

    > With `--rm` argument, when container stopped, the container will be removed automatically.

2. Enter container with `bash` using `Angular CLI v8.3.23`.

    ```sh
    docker run --name myapp --rm -it -p 4200:4200 willh/ngcli:8.3.23
    ```

    > With `--rm` argument, when container stopped, the container will be removed automatically.

3. Mount your own app into container and run `npm install` inside container.

    ```sh
    docker run --name myapp --rm -it -v /ng8:/app willh/ngcli:8.3.23 npm install
    ```

4. Mount your own app (`G:\ng8`) into container and run `npm install` and `npm start` manually.

    ```sh
    docker run --name myapp --rm -it -p 4200:4200 -v G:\ng8:/app willh/ngcli:8.3.23
    npm install
    ng serve --disable-host-check --host 0.0.0.0 --poll 1000
    ```

5. Mount empty folder (`G:\demo1`) into container and run `ng new` and `npm start` manually.

    ```sh
    mkdir g:\demo1
    docker run --name myapp --rm -it -p 4200:4200 -v G:\demo1:/app willh/ngcli:8.3.23
    cd /
    ng new app --routing --style css
    cd /app
    npm install
    ng serve --disable-host-check --host 0.0.0.0 --poll 1000
    ```

6. Mount empty folder (`G:\demo1`) into container and run `ng new`, `npm start` and `npm test` manually.

    ```sh
    mkdir g:\demo1
    docker run --name myapp --rm -it -p 4200:4200 -v G:\demo1:/app willh/ngcli:8.3.23
    cd /
    ng new app --routing --style css
    cd /app
    npm install
    ng serve --disable-host-check --host 0.0.0.0 --poll 1000
    ```

    ```sh
    docker exec -it myapp bash

    sed -i "s/browsers: \['Chrome'\],/browsers: ['ChromiumNoSandbox'],customLaunchers: {ChromiumNoSandbox: {base: 'ChromiumHeadless',flags: ['--no-sandbox','--headless','--disable-gpu','--disable-translate','--disable-extensions']}},/g" karma.conf.js
    prettier --single-quote --write karma.conf.js

    # 只跑一次 Karma Runner
    ng test --progress=false --code-coverage=true --watch=false
    # 監控資料夾變更，自動重跑 Karma Runner
    ng test --progress=false --code-coverage=true --poll=1000
    ```

    ```sh
    docker exec -it myapp bash

    sed -i "s/browserName: 'chrome'/browserName: 'chrome', chromeOptions: {args: ['--no-sandbox','--headless','--disable-gpu','--disable-translate','--disable-extensions']}/g" e2e/protractor.conf.js
    prettier --single-quote --write e2e/protractor.conf.js

    ng e2e --dev-server-target= --webdriver-update=false
    ```

7. Check logs

    ```sh
    docker logs myapp
    ```

8. Check logs continuously

    ```sh
    docker logs myapp -f
    ```

9. Stop container

    ```sh
    docker stop myapp
    ```

10. Remove container

    ```sh
    docker rm myapp
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

5. `build.v6.sh`

    Build all GA version for v6.x.x

6. `build.v6.0.sh`

    Build all GA version for v6.0.x

7. `build.v6.1.sh`

    Build all GA version for v6.1.x

8. `build.v6.2.sh`

    Build all GA version for v6.2.x

9. `build.v7.sh`

    Build all GA version for v7.x.x

10. `build.v8.sh`

    Build all GA version for v8.x.x

11. `build.v9.sh`

    Build all GA version for v9.x.x
