apt-get update 

apt install -y ansible bzip2 ca-certificates curl gcc gnupg gzip iproute2 procps python3 sudo tar unzip xz-utils zip bash git

mkdir -p /var/www/billabear
git config --global --add safe.directory /var/www/billabear