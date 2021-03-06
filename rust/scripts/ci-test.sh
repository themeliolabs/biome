#!/bin/bash

set -ex

SCRIPTS_DIRECTORY="$(dirname "${0}")"
PLAN_DIRECTORY="$(dirname "${SCRIPTS_DIRECTORY}")"

sudo rm -rf /usr/share/rust/

sudo bio pkg install --binlink themelio/bats

source "${PLAN_DIRECTORY}/plan.sh"

bio pkg build "${pkg_name}"

source results/last_build.env

sudo bio pkg install --binlink --force "results/${pkg_artifact}"

bats --print-output-on-failure "${SCRIPTS_DIRECTORY}/test.bats"