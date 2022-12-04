terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "***Specify OAuth Token***"
  cloud_id  = "***Specify Cloud ID***"
  folder_id = "***Specify Folder ID***"
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.200.0/24"]
}

resource "yandex_compute_instance" "k8s-master01" {
  name = "k8s-master01"
  hostname = "k8s-master01"
  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    ip_address = "192.168.200.101"
    nat = true
  }

  metadata = {
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }
}

resource "yandex_compute_instance" "k8s-worker01" {
  name = "k8s-worker01"
  hostname = "k8s-worker01"
  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    ip_address = "192.168.200.102"
    nat = true
  }

  metadata = {
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }
}

resource "yandex_compute_instance" "srv01" {
  name = "srv01"
  hostname = "srv01"
  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    ip_address = "192.168.200.11"
    nat = true
  }

  metadata = {
    ssh-keys = "${var.ssh_credentials.user}:${file(var.ssh_credentials.pub_key)}"
  }
}
