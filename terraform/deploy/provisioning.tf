resource "null_resource" "k8s-master-init" {
  depends_on = [yandex_compute_instance.k8s-master01]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.k8s-master01.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo '192.168.200.101 k8s-master01' | sudo tee -a /etc/hosts",
      "echo '192.168.200.102 k8s-worker01' | sudo tee -a /etc/hosts",
      "sudo tee /etc/modules-load.d/containerd.conf <<EOF\noverlay\nbr_netfilter\nEOF",
      "sudo modprobe overlay",
      "sudo modprobe br_netfilter",
      "sudo tee /etc/sysctl.d/kubernetes.conf <<EOF\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nEOF",
      "sudo sysctl --system",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg",
      "sudo add-apt-repository -y 'deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable'",
      "sudo apt update",
      "sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates containerd.io",
      "containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1",
      "sudo sed -i 's/SystemdCgroup \\= false/SystemdCgroup \\= true/g' /etc/containerd/config.toml",
      "sudo systemctl restart containerd",
      "sudo systemctl enable containerd",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "sudo apt-add-repository -y 'deb http://apt.kubernetes.io/ kubernetes-xenial main'",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "sudo kubeadm init --control-plane-endpoint=k8s-master01",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]
  }

  provisioner "local-exec" {
    command = "TOKEN=$(ssh -i ${var.ssh_credentials.private_key} -o StrictHostKeyChecking=no ${var.ssh_credentials.user}@${yandex_compute_instance.k8s-master01.network_interface.0.nat_ip_address} kubeadm token create --print-join-command); echo \"#!/usr/bin/env bash\nsudo $TOKEN\nexit 0\" >| join.sh"
  }
}


resource "null_resource" "k8s-worker-init" {
  depends_on = [yandex_compute_instance.k8s-worker01, null_resource.k8s-master-init]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.k8s-worker01.network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "join.sh"
    destination = "join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '192.168.200.102 k8s-worker01' | sudo tee -a /etc/hosts",
      "echo '192.168.200.101 k8s-master01' | sudo tee -a /etc/hosts",
      "sudo tee /etc/modules-load.d/containerd.conf <<EOF\noverlay\nbr_netfilter\nEOF",
      "sudo modprobe overlay",
      "sudo modprobe br_netfilter",
      "sudo tee /etc/sysctl.d/kubernetes.conf <<EOF\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nEOF",
      "sudo sysctl --system",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg",
      "sudo add-apt-repository -y 'deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable'",
      "sudo apt update",
      "sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates containerd.io",
      "containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1",
      "sudo sed -i 's/SystemdCgroup \\= false/SystemdCgroup \\= true/g' /etc/containerd/config.toml",
      "sudo systemctl restart containerd",
      "sudo systemctl enable containerd",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "sudo apt-add-repository -y 'deb http://apt.kubernetes.io/ kubernetes-xenial main'",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "chmod +x ~/join.sh",
      "~/join.sh"
    ]
  }

  provisioner "local-exec" {
    command = "rm join.sh"
  }
}

resource "null_resource" "k8s-network-init" {
  depends_on = [yandex_compute_instance.k8s-master01, yandex_compute_instance.k8s-worker01, null_resource.k8s-master-init]
  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.k8s-master01.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O",
      "kubectl apply -f calico.yaml"
    ]
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl",
    {
      server_ip = yandex_compute_instance.srv01.network_interface.0.nat_ip_address
      master_node_ip = yandex_compute_instance.k8s-master01.network_interface.0.nat_ip_address
      worker_node_ip = yandex_compute_instance.k8s-worker01.network_interface.0.nat_ip_address
    }
  )
  filename = "inventory"
}

resource "null_resource" "Ansible" {
  depends_on = [null_resource.k8s-network-init, yandex_compute_instance.srv01]

  provisioner "local-exec" {
    command = "./provisioning.sh  ${yandex_compute_instance.k8s-master01.network_interface.0.nat_ip_address} ${yandex_compute_instance.k8s-worker01.network_interface.0.nat_ip_address} ${yandex_compute_instance.srv01.network_interface.0.nat_ip_address}"
  }
}
