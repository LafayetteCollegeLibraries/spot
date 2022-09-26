FROM ghcr.io/samvera/fcrepo4:4.7.5

# install netcat so we can wait for the postgres db to be up
# before starting fedora
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat && \
    apt-get clean

# install ssl for jetty
RUN java -jar "$JETTY_HOME/start.jar" --create-startd --add-to-start=https

COPY ./scripts/ldr-fedora-entrypoint.sh /

ENTRYPOINT "/ldr-fedora-entrypoint.sh"

EXPOSE 8080
EXPOSE 8443

HEALTHCHECK CMD curl -kf https://localhost:8443/rest/ || exit 1
