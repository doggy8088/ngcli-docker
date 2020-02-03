FROM node:lts AS build

RUN apt-get update \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" \
    && apt-get install -y --no-install-recommends apt-utils net-tools vim \
    # Install Chrome
    && apt-get install -y adwaita-icon-theme at-spi2-core dconf-gsettings-backend dconf-service fonts-liberation glib-networking glib-networking-common glib-networking-services gsettings-desktop-schemas libappindicator3-1 libasound2 libasound2-data libatk-bridge2.0-0 libatspi2.0-0 libauthen-sasl-perl libcolord2 libdbusmenu-glib4 libdbusmenu-gtk3-4 libdconf1 libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libdrm2 libegl1-mesa libencode-locale-perl libepoxy0 libfile-basedir-perl libfile-desktopentry-perl libfile-listing-perl libfile-mimeinfo-perl libfont-afm-perl libfontenc1 libgbm1 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgtk-3-0 libgtk-3-bin libgtk-3-common libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libindicator3-7 libio-html-perl libio-socket-ssl-perl libipc-system-simple-perl libjson-glib-1.0-0 libjson-glib-1.0-common libllvm3.9 liblwp-mediatypes-perl liblwp-protocol-https-perl libmailtools-perl libnet-dbus-perl libnet-http-perl libnet-smtp-ssl-perl libnet-ssleay-perl libnspr4 libnss3 libpciaccess0 libproxy1v5 librest-0.7-0 libsensors4 libsoup-gnome2.4-1 libsoup2.4-1 libtext-iconv-perl libtie-ixhash-perl libtimedate-perl libtxc-dxtn-s2tc liburi-perl libwayland-client0 libwayland-cursor0 libwayland-egl1-mesa libwayland-server0 libwww-perl libwww-robotrules-perl libx11-protocol-perl libx11-xcb1 libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-shape0 libxcb-sync1 libxcb-xfixes0 libxft2 libxkbcommon0 libxml-parser-perl libxml-twig-perl libxml-xpathengine-perl libxmu6 libxmuu1 libxshmfence1 libxss1 libxtst6 libxv1 libxxf86dga1 libxxf86vm1 perl-openssl-defaults x11-utils x11-xserver-utils xdg-utils xkb-data \
    && wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb \
    && rm -f google-chrome-stable_current_amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g prettier json-server serve rimraf

RUN echo 'alias ll="ls -laF"' >> ~/.bashrc \
    && . ~/.bashrc \
    && echo 'set background=dark' > ~/.vimrc \
    && echo 'syntax enable' >> ~/.vimrc \
    && git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/pack/editorconfig/start/editorconfig-vim \
    && git clone https://github.com/leafgarland/typescript-vim.git    ~/.vim/pack/typescript/start/typescript-vim

# docker build -t willh/ngcli:latest --build-arg CLI_VERSION=8.0.0 -f Dockerfile .
ARG CLI_VERSION

# https://angular.io/cli/analytics
ENV NG_CLI_ANALYTICS=off \
    CHROME_BIN=/usr/bin/google-chrome \
    CHROMIUM_BIN=/usr/bin/google-chrome

# Install Angular CLI
RUN npm install -g @angular/cli@${CLI_VERSION} \
    && ng new demo1 --defaults --skip-git \
    && npm cache clean --force \
    && mv /demo1 /app \
    && cd /app \
    && npx webdriver-manager update \
    && sed -i "s/browsers: \['Chrome'\],/browsers: ['ChromiumNoSandbox'],customLaunchers: {ChromiumNoSandbox: {base: 'ChromiumHeadless',flags: ['--no-sandbox','--headless','--disable-gpu','--disable-translate','--disable-extensions']}},/g" karma.conf.js \
    && sed -i "s/browserName: 'chrome'/browserName: 'chrome', chromeOptions: {args: ['--no-sandbox','--headless','--disable-gpu','--disable-translate','--disable-extensions']}/g" e2e/protractor.conf.js \
    && sed -i "s/'browserName': 'chrome'/browserName: 'chrome', chromeOptions: {args: ['--no-sandbox','--headless','--disable-gpu','--disable-translate','--disable-extensions']}/g" e2e/protractor.conf.js \
    && prettier --single-quote --write karma.conf.js e2e/protractor.conf.js \
    && sed -i 's/"start": "ng serve"/"start": "ng serve --disable-host-check --host 0.0.0.0 --poll 1000"/g' package.json \
    && sed -i 's/"build": "ng build"/"build": "ng build --prod"/g' package.json \
    && sed -i 's/"test": "ng test"/"test": "ng test --progress=false --code-coverage=true --poll 1000 --watch=false"/g' package.json \
    && sed -i 's/"e2e": "ng e2e"/"e2e": "ng e2e --dev-server-target= --webdriver-update=false"/g' package.json

EXPOSE 4200
VOLUME [ "/app" ]

WORKDIR /app
CMD [ "bash" ]
