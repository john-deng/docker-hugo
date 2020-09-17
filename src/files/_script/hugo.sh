#!/bin/sh

# This file is triggered inside the _base/Dockerfile-base file.

set -e
set -u

# Variables
# HUGO_VERSION is edited in Dockerfile.

# Architecture
TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

if [ "$TARGETPLATFORM" = "linux/amd64" ]; then
    HUGO_ARCH="64bit"
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then
    HUGO_ARCH="ARM64"
elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then
    HUGO_ARCH="ARM"
else
    echo "Unknown build architecture: $TARGETPLATFORM"
    exit 2
fi

# Download binaries from release
wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz
wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz
wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_checksums.txt

# Verify checksums
grep Linux-${HUGO_ARCH}.tar.gz hugo_${HUGO_VERSION}_checksums.txt | sha256sum -c

# Prepare folders
mkdir -p /hugo-standard/usr/lib/hugo
mkdir -p /hugo-extended/usr/lib/hugo

# Unpack downloaded content
tar -zxf hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz -C /hugo-standard/usr/lib/hugo
tar -zxf hugo_extended_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz -C /hugo-extended/usr/lib/hugo

# Verify executable
/hugo-standard/usr/lib/hugo/hugo version

# Create autocompletion script
mkdir /etc/bash_completion.d
/hugo-standard/usr/lib/hugo/hugo gen autocomplete > /dev/null
mkdir -p /hugo-standard/etc/bash_completion.d
mkdir -p /hugo-extended/etc/bash_completion.d
cp /etc/bash_completion.d/hugo.sh /hugo-standard/etc/bash_completion.d/hugo.sh
cp /etc/bash_completion.d/hugo.sh /hugo-extended/etc/bash_completion.d/hugo.sh

# Create version file
echo -n "${HUGO_VERSION}" > /hugo-standard/etc/hugo-release
echo -n "${HUGO_VERSION}" > /hugo-extended/etc/hugo-release
