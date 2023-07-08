FROM python:3.9-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git openssh git-lfs

RUN git lfs install

COPY git-filter-repo /git-filter-repo
COPY src/setup-ssh.sh /setup-ssh.sh
COPY src/mirror.sh /mirror.sh
COPY src/cleanup.sh /cleanup.sh
COPY src/modules.sh /modules.sh

ENTRYPOINT ["/mirror.sh"]
