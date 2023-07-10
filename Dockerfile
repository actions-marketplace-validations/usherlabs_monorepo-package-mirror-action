FROM python:3.9-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git openssh git-lfs bash curl

RUN git lfs install

RUN mkdir /scripts

# add scripts to path
# we still want to make this scripts are executable from any part
ENV PATH="/scripts:${PATH}"

# Download the script
RUN curl -o /git-filter-repo https://raw.githubusercontent.com/newren/git-filter-repo/v2.38.0/git-filter-repo && chmod +x /git-filter-repo

COPY src/setup-ssh.sh /scripts/setup-ssh.sh
COPY src/mirror.sh /scripts/mirror.sh
COPY src/cleanup.sh /scripts/cleanup.sh
COPY src/modules.sh /scripts/modules.sh

ENTRYPOINT ["/scripts/mirror.sh"]
