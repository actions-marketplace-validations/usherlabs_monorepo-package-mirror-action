FROM python:3.9-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git openssh git-lfs

RUN git lfs install

COPY git-filter-repo /git-filter-repo
COPY setup-ssh.sh /setup-ssh.sh
COPY mirror.sh /mirror.sh
COPY cleanup.sh /cleanup.sh

ENTRYPOINT ["/mirror.sh"]
