FROM ghcr.io/samvera/fcrepo4:4.7.5
COPY --chown=jetty:jetty ./scripts/spot-fedora-entrypoint.sh /spot-fedora-entrypoint.sh

ENTRYPOINT "/spot-fedora-entrypoint.sh"
