#!/bin/bash
# Dockerfile for stretch based images

# Exit on any non-zero status.
trap 'exit' ERR
set -E

export DEBIAN_FRONTEND=noninteractive
apt-get -qy update
apt-get -qy --no-install-suggests --no-install-recommends install \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    git \
    openssh-client \
    gnupg \
    dirmngr \
    locales \
    procps
apt-get -y clean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/*
rm -rf /usr/share/doc/*
rm -rf /usr/share/doc-gen/*
rm -fr /usr/share/man/*
# Try different servers as one can be timed out (Cf. https://github.com/tianon/gosu/issues/39) :
for server in ha.pool.sks-keyservers.net \
    hkp://p80.pool.sks-keyservers.net:80 \
    keyserver.ubuntu.com \
    hkp://keyserver.ubuntu.com:80 \
    pgp.mit.edu ; do
    gpg --keyserver "${server}" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || echo "Trying new server..."
done
curl -fsSL "$GOSU_DOWNLOAD_URL" -o /usr/bin/gosu
curl -fsSL "${GOSU_DOWNLOAD_URL}.asc" -o /usr/bin/gosu.asc
gpg --verify /usr/bin/gosu.asc
rm -f /usr/bin/gosu.asc
chmod +x /usr/bin/gosu

## ensure locale is set during build with this image :
dpkg-reconfigure -fnoninteractive locales <<- EOF
221
2
EOF

exit 0

