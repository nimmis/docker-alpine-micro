#!/usr/bin/env bats

#!/usr/bin/env bats

: ${BRANCH:=edge}
VER=${BRANCH#v}
TAG=${VER}
REPO=${REPO}

@test "runit installed" {

  run docker run --rm $REPO:$TAG sh -c 'ls -1 /sbin/runit'
  [ "${lines[0]}" = "/sbin/runit" ]
}

@test "test runit starting crond and rsyslogd" {

  run ./tests/runit-test.sh $REPO:$TAG
  [ $status -eq 0 ]
}
