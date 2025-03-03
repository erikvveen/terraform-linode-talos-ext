output "path_to_talosconfig_file" {
  description = "The generated talosconfig."
  value       = local.path_to_talosconfig_file
}

output "path_to_kubeconfig_file" {
  description = "The generated kubeconfig."
  value       = local.path_to_kubeconfig_file
}

output "control_plane_nodes_id" {
  description = "ID of the controlplane instance"
  value       = module.talos_control_plane_nodes.*.id
}

output "worker_nodes_id" {
  description = "ID of the controlplane instance"
  value       = module.talos_worker_nodes.*.id
}
output "control_plane_nodes_ip_addresses" {
  description = "IP addresses of the control plane nodes"
  value       = module.talos_control_plane_nodes[*].ip_address
}

output "worker_nodes_ip_addresses" {
  description = "IP addresses of the control plane nodes"
  value       = module.talos_worker_nodes[*].ip_address
}

output "nb_ip_address" {
  description = "IP address of the nodebalancer"
  value       = module.nb-k8s-nb.nb_ip_address
}

output "nb-k8s-nb_id" {
  description = "ID of the nodebalancer"
  value       = module.nb-k8s-nb.id
}

output "control_plane_private_ip_addresses" {
  description = "Local IP addresses of the worker nodes"
  value       = module.talos_control_plane_nodes.*.private_ip_address
}

output "worker_nodes_private_ip_addresses" {
  description = "Local IP addresses of the worker nodes"
  value       = module.talos_worker_nodes.*.private_ip_address
}
output "cluster_name" {
  description = "Name of cluster"
  value       = var.cluster_name
}

output "kubeconfig_file" {
  description = "Kubeconfig content"
  value       = local.path_to_kubeconfig_file
}
