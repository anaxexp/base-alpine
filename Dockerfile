FROM alpine:edge
MAINTAINER AnaxExp <support@anaxexp.com>

# global variables, will be available in any heritable images
ENV TERM="xterm-color" ANAXEXP_USER="anaxexp" ANAXEXP_GROUP="anaxexp" ANAXEXP_GUID="41532" ANAXEXP_HOME="/srv" ANAXEXP_OPT="/opt/anaxexp"
ENV ANAXEXP_REPO="${ANAXEXP_HOME}/repo" ANAXEXP_FILES="${ANAXEXP_HOME}/files" ANAXEXP_BACKUPS="${ANAXEXP_HOME}/backups" ANAXEXP_LOGS="${ANAXEXP_HOME}/logs" ANAXEXP_CONF="${ANAXEXP_HOME}/conf"
ENV ANAXEXP_BUILD="${ANAXEXP_HOME}/.build" ANAXEXP_DOCROOT="${ANAXEXP_REPO}" ANAXEXP_BIN="${ANAXEXP_OPT}/bin"
ENV ANAXEXP_STATIC="${ANAXEXP_DOCROOT}/static"

# define local variables first (to easy maintain in future)
RUN export S6_OVERLAY_VER=1.17.2.0 && \
# add anaxexp user and group, it must me elsewhere with the same uid/gid
# run any services which generate any forders/files from this user
    addgroup -S -g "${ANAXEXP_GUID}" "${ANAXEXP_GROUP}" && adduser -HS -u "${ANAXEXP_GUID}" -h "${ANAXEXP_HOME}" -s /bin/bash -G "${ANAXEXP_GROUP}" "${ANAXEXP_USER}" && \
# generate random password for anaxexp user
    pass=$(pwgen -s 24 1) echo -e "${pass}\n${pass}\n" | passwd anaxexp && \
# fixed alpine bug when /etc/hosts isn't processed
    echo 'hosts: files dns' >> /etc/nsswitch.conf && \
# install ca certs to communicate external sites by SSL
# and rsync as we'ar using it to syncronize folders
# and bush as a lot of customers like it
    apk add --update libressl ca-certificates rsync bash curl wget nmap-ncat busybox-suid less grep sed tar gzip && \
# install s6-overlay (https://github.com/just-containers/s6-overlay)
    wget -qO- https://s3.amazonaws.com/wodby-releases/s6-overlay/v${S6_OVERLAY_VER}/s6-overlay-amd64.tar.gz | tar xz -C / && \
# clear cache data and disable su
    rm -rf /var/cache/apk/* /tmp/* /usr/bin/su

# copy our scripts to the image
COPY rootfs /

# default entrypoint, never overright it
ENTRYPOINT ["/init"]
