#!/bin/bash

if [[ ! -z ${HANDLE_PREFIX+x} ]]; then
  export HANDLE_SERVER_ADMINS=${HANDLE_SERVER_ADMINS:-"300:0.NA/$HANDLE_PREFIX"}
  export HANDLE_REPLICATION_ADMINS=${HANDLE_REPLICATION_ADMINS:-"300:0.NA/$HANDLE_PREFIX"}
  export HANDLE_AUTO_HOMED_PREFIXES=${HANDLE_AUTO_HOMED_PREFIXES:-"0.NA/$HANDLE_PREFIX"}
fi

cat <<-EOCONF > $HANDLE_SERVER_HOME/config.dct
{
  "hdl_http_config" = {
    "num_threads" = "15"
    "bind_port" = "8000"
    "log_accesses" = "yes"
  }

  "server_type" = "server"
  "hdl_udp_config" = {
    "num_threads" = "15"
    "bind_port" = "2641"
    "log_accesses" = "yes"
  }

  "hdl_tcp_config" = {
    "num_threads" = "15"
    "bind_port" = "2641"
    "log_accesses" = "yes"
  }

  "log_save_config" = {
    "log_save_directory" = "logs"
    "log_save_interval" = "Never"
  }

  "no_udp_resolution" = "yes"
  "interfaces" = (
    "hdl_udp"
    "hdl_tcp"
    "hdl_http"
  )

  "server_config" = {
    "server_admins" = (
      "${HANDLE_SERVER_ADMINS:-""}"
    )

    "replication_admins" = (
      "${HANDLE_REPLICATION_ADMINS:-""}"
    )

    "auto_homed_prefixes" = (
      "${HANDLE_AUTO_HOMED_PREFIXES:-""}"
    )

    "max_session_time" = "${HANDLE_MAX_SESSION_TIME:-"86400000"}"
    "this_server_id" = "${HANDLE_SERVER_ID:-"1"}"
    "max_auth_time" = "${HANDLE_MAX_AUTH_TIME:-"60000"}"
    "server_admin_full_access" = "${HANDLE_SERVER_ADMIN_FULL_ACCESS:-"yes"}"
    "allow_na_admins" = "${HANDLE_ALLOW_NA_ADMINS:-"yes"}"
    "template_ns_override" = "${HANDLE_TEMPLATE_NS_OVERRIDE:-"no"}"
    "trace_resolution" = "${HANDLE_TRACE_RESOLUTION:-"no"}"
    "case_sensitive" = "${HANDLE_CASE_SENSITIVE:-"no"}"
    "allow_recursion" = "${HANDLE_ALLOW_RECURSION:-"no"}"
    "allow_list_hdls" = "${HANDLE_ALLOW_LIST_HDLS:-"yes"}"

    "storage_type" = "bdbje"
    "db_directory" = "${HANDLE_BDBJE_DB_DIRECTORY:-"/data"}"
    "bdbje_no_sync_on_write" = "${HANDLE_BDBJE_NO_SYNC_ON_WRITE:-"false"}"
    "bdbje_enable_status_handle" = "${HANDLE_BDBJE_ENABLE_STATUS_HANDLE:-"true"}"
  }
}
EOCONF
