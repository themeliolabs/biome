pkg_name=caddy-loki
pkg_origin=themelio
pkg_version=2.4.5
pkg_maintainer="Meade Kincke <meade@themelio.org>"
pkg_source="https://github.com/caddyserver/caddy/releases/download/v${pkg_version}/caddy_${pkg_version}_linux_amd64.tar.gz"
pkg_shasum=7b28c989091a03c6aa5e397eb37d3e2c7ed3826c894534e30fd2de2f4084e770
pkg_description="This is a load balancer for loki."
pkg_upstream_url=https://caddyserver.com
pkg_deps=(core/glibc)
pkg_svc_run="caddy -conf ${pkg_svc_config_path}/Caddyfile"
pkg_exposes=(port)
pkg_exports=(
  [port]=http.port
)
pkg_bin_dirs=(bin)
pkg_dirname="${pkg_name}-v${pkg_version}"

do_build() {
  return 0
}

do_install() {
  install -Dm755 "${HAB_CACHE_SRC_PATH}/caddy" "${pkg_prefix}/bin/caddy"
}