#!/usr/bin/env bats

: ${BRANCH:=edge}
VER=${BRANCH#v}
TAG=${VER}
REPO=${REPO}
setup() {
  docker history $REPO:$TAG >/dev/null 2>&1
}

@test "version is correct $VER" {
  case $BRANCH in
  edge) skip;;
  esac
  run docker run --rm $REPO:$TAG sh -c '. /etc/os-release; echo ${VERSION_ID%.*}'
  [ $status -eq 0 ]
  [ "${lines[0]}" = "$VER" ]
}

@test "package installs cleanly" {
  run docker run --rm $REPO:$TAG apk add --no-cache bash
  [ $status -eq 0 ]
}

@test "timezone" {
  run docker run --rm $REPO:$TAG date +%Z
  [ $status -eq 0 ]
  [ "$output" = "UTC" ]
}

@test "repository list is correct" {
  run docker run --rm $REPO:$TAG cat /etc/apk/repositories
  [ $status -eq 0 ]
  case $BRANCH in
    v3.1[3-9])
        [ "${lines[0]}" = "https://dl-cdn.alpinelinux.org/alpine/$BRANCH/main" ]
        [ "${lines[1]}" = "https://dl-cdn.alpinelinux.org/alpine/$BRANCH/community" ]
        ;;
    v3.1|v3.2)
        [ "${lines[0]}" = "http://dl-cdn.alpinelinux.org/alpine/$BRANCH/main" ]
        [ "${lines[1]}" = "@community http://dl-4.alpinelinux.org/alpine/edge/community" ]
	;;
    *)
        [ "${lines[0]}" = "http://dl-cdn.alpinelinux.org/alpine/$BRANCH/main" ]
        [ "${lines[1]}" = "http://dl-cdn.alpinelinux.org/alpine/$BRANCH/community" ]
        ;;
  esac
}

@test "cache is empty" {
  run docker run --rm $REPO:$TAG sh -c "ls -1 /var/cache/apk | wc -l"
  [ $status -eq 0 ]
  [ "$output" = "0" ]
}

@test "root password is disabled with default su" {
  run docker run --rm --user nobody $REPO:$TAG su
  [ $status -eq 1 ]
}

@test "root login is disabled" {
  run docker run --rm $REPO:$TAG awk -F: '$1=="root"{print $2}' /etc/shadow
  [ $status -eq 0 ]
  [ "$output" = "!" ]
}

@test "/dev/null should be missing" {
  container=$(docker create $REPO:$TAG)
  run sh -c "docker export $container | tar -t dev/null"
  [ $status -ne 0 ]
  docker rm $container
}

@test "python installed" {
  skip "Not needed for this build"
  run docker run --rm $REPO:$TAG python -c 'print "Installed"'
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Installed" ]
}
