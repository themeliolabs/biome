pkg_name=prometheus
pkg_description="Prometheus monitoring"
pkg_upstream_url=http://prometheus.io
pkg_origin=themelio
pkg_version=2.31.1
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_license=('Apache-2.0')
pkg_bin_dirs=(bin)
pkg_source="https://github.com/prometheus/prometheus/archive/v${pkg_version}.tar.gz"
pkg_shasum=869a8be315721115be628f766ec3ff71aa50f1a027cee776ea54d7ba070a5026
prom_pkg_dir="${HAB_CACHE_SRC_PATH}/${pkg_name}-${pkg_version}"
prom_build_dir="${prom_pkg_dir}/src/${pkg_source}"
pkg_build_deps=(
  core/cacerts
  core/curl
  core/gcc
  themelio/go
  core/make
  core/sed
  core/yarn
  core/which
)
pkg_deps=(
  core/coreutils
  core/gettext
)
pkg_exports=(
  [port]=port
)
pkg_exposes=(port)
#pkg_binds_optional=(
#  [targets]="metric-http-port"
#)
pkg_svc_user="root"
pkg_svc_group="$pkg_svc_user"

do_setup_environment() {
  export GOPATH="${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
}

do_unpack() {
  mkdir -p "${prom_pkg_dir}/src/github.com/prometheus/prometheus"
  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus" || exit 1
  tar xf "${HAB_CACHE_SRC_PATH}/${pkg_filename}" --strip 1 --no-same-owner
  popd || exit 1
}

do_check() {
  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus" || exit 1
  make test
  popd || exit 1
}

do_build() {
  pushd "${prom_pkg_dir}/src/github.com/prometheus/prometheus" || exit 1

  rm -rf /etc/ssl
  mkdir -p /etc/ssl
  ln -s "$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem" /etc/ssl/ca-bundle.pem

  pip install yamllint

  cd web/ui/module/codemirror-promql
  npm install
  fix_interpreter "${prom_pkg_dir}/src/github.com/prometheus/prometheus/web/ui/module/codemirror-promql/node_modules/.bin/*" core/coreutils bin/env
  npm run build
  cd "${prom_pkg_dir}/src/github.com/prometheus/prometheus/web/ui"
  go generate -x -v
  cd "${prom_pkg_dir}/src/github.com/prometheus/prometheus"
  make ui-install
  npm install -g react-scripts
  fix_interpreter "$(which react-scripts)" core/coreutils bin/env
  cd "${prom_pkg_dir}/src/github.com/prometheus/prometheus/web/ui/react-app"
  npm install
  fix_interpreter "${prom_pkg_dir}/src/github.com/prometheus/prometheus/web/ui/react-app/node_modules/.bin/*" core/coreutils bin/env
  cd "${prom_pkg_dir}/src/github.com/prometheus/prometheus"
  make ui-build

  LDFLAGS="-X github.com/prometheus/common/version.Version=$pkg_version \
    -X github.com/prometheus/common/version.Revision=$pkg_version \
    -X github.com/prometheus/common/version.Branch=tarball \
    -X github.com/prometheus/common/version.BuildUser=meade@themelio.org \
    -X github.com/prometheus/common/version.BuildDate=$(date -u '+%Y%m%d-%H:%M:%S')"

  go build -trimpath -buildmode=pie -mod=readonly -modcacherw -ldflags "-linkmode external $LDFLAGS" ./cmd/prometheus
  go build -trimpath -buildmode=pie -mod=readonly -modcacherw -ldflags "-linkmode external $LDFLAGS" ./cmd/promtool

  popd || exit 1

  rm -rf /etc/ssl
}

do_install() {
  cd "${prom_pkg_dir}/src/github.com/prometheus/prometheus"
  install -Dm755 promtool "${pkg_prefix}/bin/promtool"
  install -Dm755 prometheus "${pkg_prefix}/bin/prometheus"
}