docker-compose build --pull file-server n2n_ntop
docker-compose push file-server n2n_ntop
docker-compose build --pull
docker-compose push
cd my_settings
docker-compose pull
docker-compose up -d
