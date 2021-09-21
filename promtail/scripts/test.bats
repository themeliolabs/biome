source "${BATS_TEST_DIRNAME}/../plan.sh"

@test "Version matches" {
  result="$(promtail -version | head -1 | awk '{print $3}')"
  [ "$result" = "${promtail_version}" ]
}

@test "Help flag works" {
  run promtail --help
  [ $status -eq 0 ]
}

@test "Service is running" {
  result="$(nmap 127.0.0.1 -p 11814 | tail -3 | head -1 | awk '{print $2}')"
  [ "$result" = "open" ]
}

@test "Metrics webserver is running" {
  result="$(nmap 127.0.0.1 -p 8080 | tail -3 | head -1 | awk '{print $2}')"
  [ "$result" = "open" ]
}

@test "Metrics webserver returns 200" {
  result="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/metrics)"
  [ "$result" = "200" ]
}