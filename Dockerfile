# Dockerfile for stretch based images
FROM debian:stretch
MAINTAINER Didier Richard <didier.richard@ign.fr>
LABEL	version="1.0.0" \
	    debian="stretch" \
	    gosu="1.10" \
	    os="Debian Stretch" \
	    description="Stretch base image"

ARG GOSU_VERSION
ENV GOSU_VERSION ${GOSU_VERSION:-1.10}
ARG GOSU_DOWNLOAD_URL
ENV GOSU_DOWNLOAD_URL ${GOSU_DOWNLOAD_URL:-https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64}
ENV LANG "C.UTF-8"

# Cf. https://github.com/docker-library/golang/blob/master/1.6/wheezy/Dockerfile
COPY adduserifneeded.sh /usr/local/bin/adduserifneeded.sh
COPY utilities.sh /usr/local/bin/utilities.sh
COPY build.sh /tmp/build.sh

RUN /tmp/build.sh && rm -f /tmp/build.sh

# always launch this when starting a container (and then execute CMD ...)
ENTRYPOINT ["adduserifneeded.sh"]

#
CMD ["/bin/bash"]

