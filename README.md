## Example Usage
```
First upload talos image, see: https://github.com/siderolabs/talos/releases/tag/v1.9.5 and get the image_id.

Second, get your linode token.

// Create a Talos Linux cluster

module "talos_linode_clusters" {
  source = "git::https://github.com/erikvveen/terraform-linode-talos-ext.git"
  
  providers = {
    talos = talos
    random = random
    linode = linode
  }

  cluster_name       = "talos-cute"
  region             = "nl-ams"
  tags               = local.tags
  pod_cidr           = "10.245.0.0/16"
  service_cidr       = "10.97.0.0/12"
  linode_token       = "XXXXX"
  talos_version      = "v1.9.1"
  kubernetes_version = "1.31.0"
  config_patch_files = ["cilium.yaml"]
  image              = "private/<image_id>
}

```

# terraform-linode-talos