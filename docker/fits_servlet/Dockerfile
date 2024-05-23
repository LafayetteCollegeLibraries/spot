##
# Target: fits-installer
# !! Not for general consumption !!
##
FROM alpine:3 as fits-installer
ARG FITS_VERSION="1.6.0"
ENV FITS_VERSION="${FITS_VERSION}"
WORKDIR /tmp

ADD https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip /tmp

RUN unzip -d /tmp/fits /tmp/fits-${FITS_VERSION}.zip && \
    chmod a+x /tmp/fits/fits.sh && \
    rm /tmp/fits-${FITS_VERSION}.zip

##
# Target: servlet-installer
# !! Not for general consumption !!
##
FROM alpine:3 as servlet-installer
ARG FITS_SERVLET_VERSION="2.1.0"
ENV FITS_SERVLET_VERSION="${FITS_SERVLET_VERSION}"
ADD https://github.com/harvard-lts/FITSservlet/releases/download/${FITS_SERVLET_VERSION}/fits-service-${FITS_SERVLET_VERSION}.war /tmp/fits-service.war

##
# Default image
##
FROM docker.io/tomcat:9-jre17-temurin-jammy

# see https://github.com/harvard-lts/FITSservlet/blob/2.1.0/docker/Dockerfile#L18-L42
RUN apt-get update && \
    apt-get install -yqq \
    # jpylyzer dependencies
    python3 \
    python-is-python3 \
    # exiftool dependencies https://github.com/exiftool/exiftool
    libarchive-zip-perl \
    libio-compress-perl \
    libcompress-raw-zlib-perl \
    libcompress-bzip2-perl \
    libcompress-raw-bzip2-perl \
    libio-digest-perl \
    libdigest-md5-file-perl \
    libdigest-perl-md5-perl \
    libdigest-sha-perl \
    libposix-strptime-perl \
    libunicode-linebreak-perl\
    # file dependencies
    file \
    make \
    gcc \
    # mediainfo dependencies
    libmms0 \
    libcurl3-gnutls \
    && rm -rf /var/lib/apt/lists/*

# Install FITS + servlet
COPY --from=fits-installer /tmp/fits /opt/fits
COPY --from=servlet-installer /tmp/fits-service.war $CATALINA_HOME/webapps/fits.war

# Copy config, scripts, etc
COPY assets/catalina.properties $CATALINA_HOME/conf/catalina.properties
COPY scripts/fits-servlet-entrypoint.sh /opt/fits-servlet-entrypoint.sh

# Bind the current working directory here so that FITS can access files on the host
WORKDIR /work

ENTRYPOINT ["/opt/fits-servlet-entrypoint.sh"]