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
git tag -a "v$RELEASE_VERSION" -m "Patch Release v$RELEASE_VERSION" && \
git push origin master && \
git push origin "v$RELEASE_VERSION"

RELEASE_BRANCHES=$( (git branch -r | cut -c 3-) | grep "origin/release" | sed -e "s/origin\///" )

if [ -n "${RELEASE_BRANCHES}" ]
then
  for branch in "${RELEASE_BRANCHES[@]}"; do
    echo "Merging $CURRENT_BRANCH into $branch" && \
    git checkout $branch && \
    (git merge --no-ff --no-edit $CURRENT_BRANCH || true) && \
    git checkout --ours pom.xml && \
    git add pom.xml && \
    git commit --no-edit && \
    git push origin $branch
  done && \
  echo "Closing $CURRENT_BRANCH branch" && \
  git push origin -d $CURRENT_BRANCH
else
  echo "Merging $CURRENT_BRANCH into develop" && \
  git checkout develop && \
  (git merge --no-ff --no-edit $CURRENT_BRANCH || true) && \
  git checkout --ours pom.xml && \
  git add pom.xml && \
  git commit --no-edit && \
  git push origin develop && \
  echo "Closing $CURRENT_BRANCH branch" && \
  git push origin -d $CURRENT_BRANCH
fi
