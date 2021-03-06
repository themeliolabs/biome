pkg_name=caddy-grafana
pkg_origin=themelio
pkg_version=2.4.6
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_source="https://github.com/caddyserver/caddy/releases/download/v${pkg_version}/caddy_${pkg_version}_linux_amd64.tar.gz"
pkg_shasum=690ad64538a39d555294cd09b26bb22ade36abc0e3212342f0ed151de51ec128
pkg_description="This is a load balancer for grafana."
pkg_upstream_url=https://caddyserver.com
pkg_deps=(
  core/gettext
  core/glibc
)
pkg_exposes=(port)
pkg_exports=(
  [port]=http.port
)
pkg_bin_dirs=(bin)
pkg_dirname="${pkg_name}-v${pkg_version}"
pkg_svc_user="root"
pkg_svc_group="$pkg_svc_user"

do_build() {
  return 0
}

do_install() {
  install -Dm755 "${HAB_CACHE_SRC_PATH}/caddy" "${pkg_prefix}/bin/caddy"
}