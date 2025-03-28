resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_D4s_v3"
  vnet_subnet_id        = azurerm_subnet.subnet1.id
  orchestrator_version  = local.aks_version
  priority              = "Spot"
  spot_max_price        = -1
  eviction_policy       = "Delete"
  auto_scaling_enabled  = true
  min_count           = 1
  max_count           = 3

#  node_labels = {
#    role                                    = "spot"
#    "kubernetes.azure.com/scalesetpriority" = "spot"
#  }

#  node_taints = [
#    "spot:NoSchedule",
#    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
#  ]

  tags = {
    env = local.env
  }


}
