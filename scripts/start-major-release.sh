#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD) && \
git config user.email "circleci@kenect.com" && \
git config user.name "Circle CI" && \
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.nextMajorVersion}.0.0-SNAPSHOT versions:commit && \
CURRENT_VERSION=$(mvn -q \
    -Dexec.executable=echo \
    -Dexec.args='${project.version}' \
    --non-recursive \
    exec:exec) && \
git add pom.xml && \
git commit -m "Bumped version number to $CURRENT_VERSION" && \
VERSION_SUFFIX="-SNAPSHOT" && \
TARGET_VERSION=$(echo "$CURRENT_VERSION" | sed -e "s/$VERSION_SUFFIX$//") && \
git checkout -b release/$TARGET_VERSION && \
git push origin release/$TARGET_VERSION && \
git checkout ${CURRENT_BRANCH} && \
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.nextMinorVersion}.0-SNAPSHOT versions:commit && \
NEXT_VERSION=$(mvn -q \
    -Dexec.executable=echo \
    -Dexec.args='${project.version}' \
    --non-recursive \
    exec:exec) && \
git add pom.xml && \
git commit -m "Bumped version number to $NEXT_VERSION" && \
git push origin $CURRENT_BRANCH
