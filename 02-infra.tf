module "nb-k8s-nb" {
  source  = "git::https://github.com/erikvveen/nb-k8s-nb-ext.git"

  name         = "${var.cluster_name}-k8s-api"
  region      = var.region
  instances_ip   = module.talos_control_plane_nodes[*].private_ip_address

}
