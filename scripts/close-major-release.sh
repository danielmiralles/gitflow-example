#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD) && \
git config user.email "circleci@kenect.com" && \
git config user.name "Circle CI" && \
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} versions:commit && \
RELEASE_VERSION=$(mvn -q \
    -Dexec.executable=echo \
    -Dexec.args='${project.version}' \
    --non-recursive \
    exec:exec) && \
git add pom.xml && \
git commit -m "Bumped version number to $RELEASE_VERSION" && \
git checkout master && \
git merge --no-ff --no-edit $CURRENT_BRANCH && \
git tag -a "v$RELEASE_VERSION" -m "Major Release v$RELEASE_VERSION" && \
git push origin master && \
git push origin "v$RELEASE_VERSION" && \
git checkout develop && \
(git merge --no-ff --no-edit $CURRENT_BRANCH || true) && \
git checkout --ours pom.xml && \
git add pom.xml && \
git commit --no-edit && \
git push origin develop && \
git push origin -d $CURRENT_BRANCH