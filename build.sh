#!/bin/sh

DOCKER_TAG=$1

WORKDIR=$PWD
rm -rf optimint ethermint

# Get Optimint
git clone git@github.com:celestiaorg/optimint.git -q
echo "cloned optimint"
cd optimint
git checkout 939aa77 -q
echo "checked out 939aa77 commit"
rm -rf .git
go mod tidy -compat=1.17 -e
echo "finished tidying optimint"
cd $WORKDIR

# Get ethermint
git clone git@github.com:jbowen93/ethermint.git -q
echo "cloned ethermint"
cd ethermint
git checkout jbowen93-optimint -q
echo "checked out jbowen93-optimint branch"
rm -rf .git
go mod edit -replace=github.com/celestiaorg/optimint=../optimint
go mod tidy -compat=1.17 -e
echo "finished tidying ethermint"
cd $WORKDIR

# Cleanup
go mod edit -replace=github.com/celestiaorg/optimint=./optimint
go mod edit -replace=github.com/tharsis/ethermint=./ethermint
go mod tidy -compat=1.17 -e
echo "finished tidying evmos"

# Docker build
docker buildx build --platform linux/arm64 -f docker/debug.Dockerfile -t ghcr.io/jbowen93/evmos:$DOCKER_TAG .
