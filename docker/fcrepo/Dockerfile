# Borrowing the warfile builder from samvera/fcrepo4 to use
# the very recently patched 4.7.6 release of Fedora.
#
# @todo remove this when 4.7.6 release is published
FROM        openjdk:8 as warfile
RUN         mkdir -p /build /unpack
WORKDIR     /unpack
ADD         https://raw.githubusercontent.com/samvera-labs/docker-fcrepo/main/assets/repack.sh ./repack.sh
ARG         FCREPO_VERSION=4.7.6
RUN         bash ./repack.sh

FROM ghcr.io/samvera/fcrepo4:4.7.5

# install netcat so we can wait for the postgres db to be up
# before starting fedora
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends netcat && \
    apt-get clean

COPY --chown=jetty:jetty --from=warfile /build/* ${JETTY_BASE}/fedora/

COPY ./scripts/ldr-fedora-entrypoint.sh /

ENTRYPOINT "/ldr-fedora-entrypoint.sh"

EXPOSE 8080

HEALTHCHECK CMD curl -kf http://localhost:8080/rest/ || exit 1
