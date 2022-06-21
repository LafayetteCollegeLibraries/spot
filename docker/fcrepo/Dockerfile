FROM ghcr.io/samvera/fcrepo4:4.7.5

# install netcat so we can wait for the postgres db to be up
# before starting fedora
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat && \
    apt-get clean

COPY ./scripts/ldr-fedora-entrypoint.sh /

ENTRYPOINT "/ldr-fedora-entrypoint.sh"
