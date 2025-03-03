resource "random_string" "name" {
  length      = 6
  min_numeric = 1
  special     = false
  upper       = false
}

module "talos_control_plane_nodes" {
  source  = "git::https://github.com/erikvveen/talos-nodes-ext.git"

  count = var.controlplane_count

  name = "${var.cluster_name}-control-plane-${count.index}-${random_string.name.id}"
  tags = var.tags
  region = var.region
  instance_type = var.control_plane.instance_type
  metadata_options = data.talos_machine_configuration.controlplane[count.index].machine_configuration

}
module "talos_worker_nodes" {
  source  = "git::https://github.com/erikvveen/talos-nodes-ext.git"

  count = var.workers_count

  name = "${var.cluster_name}-worker-${count.index}-${random_string.name.id}"
  tags = var.tags
  region = var.region
  instance_type = var.control_plane.instance_type
  metadata_options = data.talos_machine_configuration.worker[count.index].machine_configuration
}

resource "talos_machine_secrets" "this" {
}
output "machine_secrets" {
  value = talos_machine_secrets.this
}

data "talos_machine_configuration" "controlplane" {
  for_each = { for index in range(var.controlplane_count) : index => index }

  cluster_name       = "${var.cluster_name}-${random_string.name.id}"
  cluster_endpoint   = "https://${replace(module.nb-k8s-nb.nb_ip_address,".","-")}.ip.linodeusercontent.com"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
  config_patches = concat(
    local.config_patches_common,
    [yamlencode(local.common_config_patch)],
    [yamlencode(local.config_cilium_patch)],
    [for path in var.control_plane.config_patch_files : file(path)]
  )
}

data "talos_machine_configuration" "worker" {
  for_each = { for index in range(var.workers_count) : index => index }

  cluster_name       = "${var.cluster_name}-${random_string.name.id}"
  cluster_endpoint   = "https://${replace(module.nb-k8s-nb.nb_ip_address,".","-")}.ip.linodeusercontent.com"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
  config_patches = concat(
    local.config_patches_common,
    [yamlencode(local.common_config_patch)],
    [yamlencode(local.config_cilium_patch)],
    [for path in var.control_plane.config_patch_files : file(path)]
  )
}


resource "talos_machine_configuration_apply" "controlplane" {
count = var.controlplane_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[count.index].machine_configuration
  endpoint                    = module.talos_control_plane_nodes[count.index].ip_address
  node                        = module.talos_control_plane_nodes[count.index].private_ip_address
}
resource "talos_machine_configuration_apply" "worker" {
  count = var.workers_count

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[count.index].machine_configuration
  endpoint                    = module.talos_worker_nodes[count.index].ip_address
  node                        = module.talos_worker_nodes[count.index].private_ip_address
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane] 
  
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = module.talos_control_plane_nodes[0].ip_address
  node                 = module.talos_control_plane_nodes[0].private_ip_address
}

data "talos_client_configuration" "this" {
  cluster_name         = "${var.cluster_name}-${random_string.name.id}"
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = module.talos_control_plane_nodes.*.ip_address
}

resource "local_file" "talosconfig" {
  content  = nonsensitive(data.talos_client_configuration.this.talos_config)
  filename = local.path_to_talosconfig_file
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = module.talos_control_plane_nodes[0].ip_address
  node                 = module.talos_control_plane_nodes[0].private_ip_address

}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = local.path_to_kubeconfig_file
  lifecycle {
    ignore_changes = [content]
  }
}
