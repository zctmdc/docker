#!/bin/bash
set -x

apt-get update && apt-get upgrade -y
work_dir=/opt/docker
if [[ ! -d "${work_dir}" ]]; then
  work_dir="$(pwd)"
fi
chmod a+x ${work_dir}/my_settings/*.sh

cd ${work_dir}/my_settings/caddy/site &&
  chmod 755 . -R &&
  find -type d -exec chmod 755 {} \; &&
  find -iname "*.php" -exec chmod 644 {} \;

cd ${work_dir}/ &&
  docker-compose build --pull n2n_ntop file-server &&
  docker-compose push n2n_ntop file-server &&
  docker-compose build --pull &&
  docker-compose push

cd ${work_dir}/my_settings &&
  docker-compose pull &&
  docker-compose up -d
