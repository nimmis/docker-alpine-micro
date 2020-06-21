#!/bin/sh

# (c) 2020, nimmis <kjelll.havneskold@gmail.com>

if [ -z "$1" ]
  then
  echo "usage: test.sh <spplication version>"
  echo
  echo "Builds the specified version and do som testing"
  exit 1
fi

TAG=$1
BRANCH=$TAG
[[ $TAG == [0-9]* ]] && BRANCH=v$BRANCH
REPO=nimmis/alpine-micro-test

# build 
docker build --pull -t $REPO:$TAG $TAG/

# test
BRANCH=$BRANCH REPO=$REPO ./tests/alpine-common.bats
BRANCH=$BRANCH REPO=$REPO ./tests/alpine-tests.bats

# remove
docker rmi  $REPO:$TAG

