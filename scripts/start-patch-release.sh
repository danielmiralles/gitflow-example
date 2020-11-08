#!/bin/bash

git config user.email "circleci@kenect.com" && \
git config user.name "Circle CI" && \
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}-SNAPSHOT versions:commit && \
NEXT_VERSION=$(mvn -q \
    -Dexec.executable=echo \
    -Dexec.args='${project.version}' \
    --non-recursive \
    exec:exec) && \
VERSION_SUFFIX="-SNAPSHOT" && \
TARGET_VERSION=$(echo "$NEXT_VERSION" | sed -e "s/$VERSION_SUFFIX$//") && \
git checkout -b hotfix/$TARGET_VERSION && \
git add pom.xml && \
git commit -m "Bumped version number to $NEXT_VERSION" && \
git push origin hotfix/$TARGET_VERSION