source "docker" "php-fpm" {
  image  = "ubuntu:20.04"
  commit = true
  changes = [
    "EXPOSE 9000",
    "ONBUILD RUN ln -sf /dev/stdout /var/log/php8.2-fpm.log",
    "ENTRYPOINT [\"/entrypoint.sh\"]"
  ]
}
variable "docker_login" {
  type    = string
  default = "${env("DOCKER_LOGIN")}"
}
variable "docker_token" {
  type    = string
  default = "${env("DOCKER_TOKEN")}"
}

build {
  name = "web"
  sources = [
    "source.docker.php-fpm"
  ]

  provisioner "shell" {
    script="web/build.sh"
  }
  provisioner "file" {
    source      = "web/entrypoint.sh"
    destination = "entrypoint.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /entrypoint.sh"
    ]
  }

  provisioner "file" {
    source      = "web/env.j2"
    destination = "/tmp/env"
  }

  provisioner "ansible-local" {
    playbook_file = "./web/playbook.yml"
  }

  provisioner "file" {
    source      = "./web/overrides.conf"
    destination = "/etc/php/8.2/fpm/pool.d/z-overrides.conf"
  }

   post-processors {
    post-processor "docker-tag" {
      repository = "billabear/backend"
      tags       = ["0.1"]
      only       = ["docker.php-fpm"]
    }

    post-processor "docker-push" {
      login = true
      login_username = "${var.docker_login}"
      login_password = "${var.docker_token}"
    }
   }
}