pkg_name=loki
pkg_origin=themelio
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_description="Like Prometheus, but for logs."
pkg_version="2.4.2"
pkg_license=('Apache-2.0')
pkg_upstream_url=https://grafana.com/oss/loki/
pkg_source="https://github.com/grafana/loki/archive/v${pkg_version}.tar.gz"
pkg_filename="v${pkg_version}.tar.gz"
pkg_shasum="725af867fa3bece6ccd46e0722eb68fe72462b15faa15c8ada609b5b2a476b07"
loki_pkg_dir="${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}"
loki_build_dir="${loki_pkg_dir}/src/${pkg_source}"
pkg_build_deps=(
  core/busybox-static
  core/gcc
  core/git
  themelio/go
  core/make
)
pkg_deps=(
  core/coreutils
)
pkg_bin_dirs=(bin)
pkg_exports=(
  [http_port]=http_port
  [grpc_port]=grpc_port
)
pkg_exposes=(
  http_port
  grpc_port
)
pkg_svc_user="root"
pkg_svc_group="$pkg_svc_user"

do_setup_environment() {
  export GOPATH="${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
}

do_unpack() {
  mkdir -p "${loki_pkg_dir}/src/github.com/grafana/loki"
  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
  tar xf "${HAB_CACHE_SRC_PATH}/${pkg_filename}" --strip 1 --no-same-owner
  popd > /dev/null || exit 1
}

do_prepare() {
  BASHBIN="$(pkg_path_for core/busybox-static)/bin/bash"

  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
  sed -i "s,/usr/bin/env bash,${BASHBIN}," Makefile
  popd > /dev/null || exit 1
}

do_build() {
  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
  sed -e "s#SHELL = /usr/bin/env bash#SHELL = $(pkg_path_for core/coreutils)/bin/env bash#" -i Makefile
  fix_interpreter "tools/image-tag" core/coreutils bin/env
  make loki
  make logcli
  popd > /dev/null || exit 1
}

do_install() {
  pushd "${loki_pkg_dir}/src/github.com/grafana/loki" > /dev/null || exit 1
  install -Dm755 cmd/loki/loki "${pkg_prefix}/bin/loki"
  install -Dm755 cmd/logcli/logcli "${pkg_prefix}/bin/logcli"
  popd > /dev/null || exit 1
}