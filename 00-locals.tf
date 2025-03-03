

resource "random_string" "workspace_id" {
  length      = 6
  min_numeric = 1
  special     = false
  upper       = false
}

locals {

  instance_architecture    = var.cluster_architecture == "amd64" ? "x86_64" : var.cluster_architecture
  path_to_workspace_dir    = "${abspath(path.root)}/.terraform/.workspace-${random_string.workspace_id.id}"
  path_to_kubeconfig_file  = "${local.path_to_workspace_dir}/kubeconfig"
  path_to_talosconfig_file = "${local.path_to_workspace_dir}/talosconfig"

  common_config_patch = {
    cluster = {
      id          = var.cluster_id,
      clusterName = var.cluster_name,
      apiServer = {
        extraArgs = {
          cloud-provider = "external"
        }
        certSANs = [
          "${replace(module.nb-k8s-nb.nb_ip_address,".","-")}.ip.linodeusercontent.com"
        ]  },
      controllerManager = {
        extraArgs = {
          allocate-node-cidrs = var.allocate_node_cidrs
          cloud-provider = "external"
        }
      },
      network = {
        cni = {
          name = "none"
        },
        podSubnets = [
          var.pod_cidr
        ],
        serviceSubnets = [
          var.service_cidr
        ]
      },
      extraManifests = [
        "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
      ],
      allowSchedulingOnControlPlanes = var.allow_workload_on_cp_nodes
    },
    machine = {
      
      kubelet = {
        registerWithFQDN = true
        
      },
      certSANs = [
          "${replace(module.nb-k8s-nb.nb_ip_address,".","-")}.ip.linodeusercontent.com"
          ],
      kubelet = {
        extraArgs = {
          rotate-server-certificates = true
          cloud-provider = "external"

        }
      }
    }
  }

  # Used to configure Cilium Kube-Proxy replacement
  config_cilium_patch = {
    cluster = {
      proxy = {
        disabled = var.disable_kube_proxy
      }
    },
    machine = {
      features = {
        kubePrism = {
          enabled = true,
          port    = 7445
        }
      }
    }
  }

  config_patches_common = [
    for path in var.config_patch_files : file(path)
  ]

  cluster_required_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

}
