#!/bin/bash

set -ex

SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

sudo bio pkg install --binlink themelio/bats
sudo bio pkg install --binlink core/curl
sudo bio pkg install --binlink core/net-tools

wget -q https://github.com/themeliolabs/artifacts/raw/master/htmlq
chmod +x htmlq
sudo mv htmlq /bin

source "${PLAN_DIRECTORY}/plan.sh"

sudo bio sup run &

bio pkg build "${pkg_name}"

source results/last_build.env

sudo bio pkg install --binlink --force "results/${pkg_artifact}"

sudo useradd hab -s /bin/bash -p '*'

sudo bio svc load "${pkg_ident}"

echo "Sleeping for 15 seconds for the service to start."
sleep 15

CURL_OUTPUT=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9090/graph)

echo "Curl output is: $CURL_OUTPUT"

if bats --print-output-on-failure "${SCRIPTS_DIRECTORY}/test.bats"; then
  sudo rm -rf /bin/htmlq
  sudo bio svc unload "${pkg_ident}"
else
  sudo rm -rf /bin/htmlq
  sudo bio svc unload "${pkg_ident}"
  exit 1
fi