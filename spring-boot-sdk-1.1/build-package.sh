#!/bin/bash

# Publish a Release to Artifactory and Maven Central

set -euo pipefail

mkdir -p maven_cache

# Jenkins reads the changelog and writes the latest version to a file called VERSION
# If a developer runs these scripts locally, the VERSION file won't exist, so
# we generate a placeholder VERSION file.
if [[ ! -r VERSION ]]; then
    echo "1.0.0-SNAPSHOT" > VERSION
fi

# Use tools image to update version in pom file to match the version in CHANGELOG.md
docker run \
    --volume "${PWD}:${PWD}" \
    --volume "${PWD}/maven_cache":/root/.m2 \
    --workdir "${PWD}" \
    tools \
        mvn --batch-mode versions:set -DnewVersion="$(<VERSION)" -Dmaven.test.skip
# TODO: Update sample app dependency to use this version.

# Use Tools image to package code
docker run \
    --volume "${PWD}:${PWD}" \
    --volume "${PWD}/maven_cache":/root/.m2 \
    --workdir "${PWD}" \
    tools \
        mvn --batch-mode -f pom.xml package -Dmaven.test.skip
