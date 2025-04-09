output "nom_vm" {
  value = openstack_compute_instance_v2.vm.name
}

output "ip_publique_vm" {
  value = openstack_networking_floatingip_v2.fip.address
}
