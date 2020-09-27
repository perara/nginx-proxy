#!/bin/bash

function replace(){
  echo $1 | sed -re "s@$2@$3@"
}

function write_upstream_section() {
  upstream_conf="upstream backend {\n\tzone tcp_mem 64k;\n"
  for server in ${TARGET_SERVER//;/ } ; do
     server=$(replace "$server" "(http://|https://)" "")
     upstream_conf="${upstream_conf}\tserver ${server};\n"
  done
  upstream_conf="${upstream_conf}}\n"
  echo "$upstream_conf"
}

# Check required variables
if [[ -z ${TARGET_SERVER} ]]; then echo "TARGET_SERVER is not set. Exiting."; exit; fi;
if [[ -z ${LISTEN_PORT} ]]; then echo "LISTEN_PORT is not set. Exiting."; exit; fi;

if [[ ${PROTOCOL:-http} == "tcp" ]]; then
  # In the case of TCP forward

  echo "stream { include stream.conf; }" | tee -a /etc/nginx/nginx.conf

  tcp_config="$(write_upstream_section)
server {
  listen ${LISTEN_PORT};
  proxy_pass backend;
}"

  echo -e "${tcp_config}" | tee /etc/nginx/stream.conf
  cat /etc/nginx/stream.conf

elif [[ ${PROTOCOL:-http} == "http" ]] || [[ ${PROTOCOL:-http} == "https" ]]; then
  # In the case of HTTP forward




  http_config="$(write_upstream_section)
server {
  listen ${LISTEN_PORT};
  server_name docker;
  "

  if [[ ${HTTP_AUTH_USERNAME} ]] && [[ ${HTTP_AUTH_PASSWORD} ]]; then
    # Basic auth should be activated.
    htpasswd -b -c /.htpasswd "${HTTP_AUTH_USERNAME}" "${HTTP_AUTH_PASSWORD}"
    http_config="${http_config}
  auth_basic          \"Restricted Area\";
  auth_basic_user_file /.htpasswd;
    "
  fi;


  http_config="${http_config}
  location / {
    # Add a filter block
    proxy_pass                 ${PROTOCOL}://backend;
    proxy_set_header           Host ${HOST_SERVER:-\$host};
    proxy_set_header           X-Real-IP \$remote_addr;
    proxy_set_header           X-Forwarded-For \$proxy_add_x_forwarded_for;
    fastcgi_buffers 16 16k; 
    fastcgi_buffer_size 32k;
    proxy_connect_timeout      150;
    proxy_send_timeout         100;
    proxy_read_timeout         100;
    proxy_buffer_size          128k;
    proxy_buffers              4 256k;
    proxy_busy_buffers_size    256k;
    client_max_body_size       0;

    proxy_set_header           Upgrade \$http_upgrade;
    proxy_set_header           Connection \"upgrade\";
  }
}
  "
  echo -e "${http_config}" | tee /etc/nginx/conf.d/default.conf

fi;

nginx -g "daemon off;"
