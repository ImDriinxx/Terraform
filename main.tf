terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.1" # ou latest, si tu veux la dernière version stable
    }
  }
}
provider "openstack" {
  auth_url    = "https://api.pub1.infomaniak.cloud/identity/v3"
  user_name   = "PCU-ON33OMZ"
  password    = "Azerty1234+"
  tenant_name = "PCP-ON33OMZ"
  domain_name = "Default"
  region      = "dc3-a"
}

# 1. Clé SSH publique
resource "openstack_compute_keypair_v2" "default" {
  name       = "ma-cle-ssh"
  public_key = file("~/.ssh/id_rsa.pub") # chemin local vers ta clé publique
}

# 2. Réseau privé
resource "openstack_networking_network_v2" "private_network" {
  name           = "reseau-prive"
  admin_state_up = true
}

# 3. Sous-réseau privé
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "subnet-prive"
  network_id      = openstack_networking_network_v2.private_network.id
  cidr            = "192.168.42.0/24"
  ip_version      = 4
  gateway_ip      = "192.168.42.1"
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# 4. Routeur
resource "openstack_networking_router_v2" "router" {
  name                = "routeur-prive"
  admin_state_up      = true
  external_network_id = "0f9c3806-bd21-490f-918d-4a6d1c648489" # ID de ext-floating1
}

# 5. Interface routeur vers sous-réseau
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}

# 6. IP flottante (publique)
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "ext-floating1"
}

# 7. Création de la VM
resource "openstack_compute_instance_v2" "vm" {
  name            = "vm-debian12"
  image_name      = "Debian 12 bookworm"
  flavor_name     = "a1-ram2-disk20-perf1"
  key_pair        = openstack_compute_keypair_v2.default.name
  security_groups = ["default"]

  network {
    uuid = openstack_networking_network_v2.private_network.id
  }
}

# 8. Association IP flottante à la VM
resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.vm.id
}
