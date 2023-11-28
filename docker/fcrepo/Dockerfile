# NOTE: fcrepo:4.7.6-s3-streaming image is built from SoftServ's fork:
#       https://github.com/scientist-softserv/docker-fcrepo/tree/softserv_updates
FROM ghcr.io/samvera/fcrepo:4.7.6-s3-streaming

# install netcat so we can wait for the postgres db to be up
# before starting fedora
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends netcat && \
    apt-get clean

COPY ./scripts/ldr-fedora-entrypoint.sh /

ENTRYPOINT "/ldr-fedora-entrypoint.sh"

EXPOSE 8080

HEALTHCHECK CMD curl -kf http://localhost:8080/rest/ || exit 1
