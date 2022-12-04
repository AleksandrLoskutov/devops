output "Master-node" {
  value = "KUBERNETES CLUSTER SUCCESSFULLY DEPLOYED! Connect to its control plane node by executing: ssh ubuntu@${yandex_compute_instance.k8s-master01.network_interface.0.nat_ip_address}"
}

output "Worker-node" {
  value = "KUBERNETES CLUSTER SUCCESSFULLY DEPLOYED! Connect to its worker by executing: ssh ubuntu@${yandex_compute_instance.k8s-worker01.network_interface.0.nat_ip_address}"
}

output "Server" {
  value = "GITLAB SERVER SUCCESSFULLY DEPLOYED! Connect to its console by executing: ssh ubuntu@${yandex_compute_instance.srv01.network_interface.0.nat_ip_address}"
}
