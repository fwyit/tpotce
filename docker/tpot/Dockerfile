FROM    fwyit/alpine:gosu

RUN     apk update && apk add -t .deps --no-cache git && \
        git clone -b dev https://github.com/fwyit/tpotce && \
        tar -zcf /src.tgz -C tpotce . --remove-files && \
        apk del .deps && \
        rm -rf /root/* /var/cache/apt/* /tmp/*