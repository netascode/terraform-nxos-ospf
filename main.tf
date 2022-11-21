locals {
  vrf_map = { for v in var.vrfs : v.vrf => v }
  area_map = merge([
    for vrf_entry in var.vrfs : vrf_entry.areas == null ? {} : {
      for area_entry in vrf_entry.areas : "${vrf_entry.vrf}_${area_entry.area}" => merge(area_entry, { "vrf" : vrf_entry.vrf })
    }
  ]...)
  interface_map = merge([
    for vrf_entry in var.vrfs : vrf_entry.interfaces == null ? {} : {
      for interface_entry in vrf_entry.interfaces : "${vrf_entry.vrf}_${interface_entry.interface}" => merge(interface_entry, { "vrf" : vrf_entry.vrf })
    }
  ]...)

  interface_auth_map = merge([
    for vrf_entry in var.vrfs : vrf_entry.interfaces == null ? {} : {
      for interface_entry in vrf_entry.interfaces : "${vrf_entry.vrf}_${interface_entry.interface}" => merge(interface_entry, { "vrf" : vrf_entry.vrf })
      if interface_entry.authentication_type != null
    }
  ]...)
}

resource "nxos_ospf_instance" "ospfInst" {
  device = var.device
  name   = var.name
}

resource "nxos_ospf_vrf" "ospfDom" {
  for_each                = local.vrf_map
  device                  = var.device
  instance_name           = var.name
  name                    = each.value.vrf
  admin_state             = each.value.admin_state == true ? "enabled" : "disabled"
  bandwidth_reference     = each.value.bandwidth_reference
  banwidth_reference_unit = each.value.banwidth_reference_unit
  distance                = each.value.distance
  router_id               = each.value.router_id

  depends_on = [
    nxos_ospf_instance.ospfInst
  ]
}

resource "nxos_ospf_area" "ospfArea" {
  for_each            = local.area_map
  device              = var.device
  instance_name       = var.name
  vrf_name            = each.value.vrf
  area_id             = each.value.area
  authentication_type = each.value.authentication_type
  cost                = each.value.cost
  type                = each.value.type

  depends_on = [
    nxos_ospf_vrf.ospfDom
  ]
}

resource "nxos_ospf_interface" "ospfIf" {
  for_each              = local.interface_map
  device                = var.device
  instance_name         = var.name
  vrf_name              = each.value.vrf
  interface_id          = each.value.interface
  advertise_secondaries = each.value.advertise_secondaries
  area                  = each.value.area
  bfd                   = each.value.bfd
  cost                  = each.value.cost
  dead_interval         = each.value.dead_interval
  hello_interval        = each.value.hello_interval
  network_type          = each.value.network_type
  passive               = each.value.passive
  priority              = each.value.priority

  depends_on = [
    nxos_ospf_vrf.ospfDom
  ]
}

resource "nxos_ospf_authentication" "ospfAuthNewP" {
  for_each            = local.interface_auth_map
  device              = var.device
  instance_name       = var.name
  vrf_name            = each.value.vrf
  interface_id        = each.value.interface
  key                 = each.value.authentication_key
  key_id              = each.value.authentication_key_id
  key_secure_mode     = each.value.authentication_key_secure_mode
  keychain            = each.value.authentication_keychain
  md5_key             = each.value.authentication_md5_key
  md5_key_secure_mode = each.value.authentication_md5_key_secure_mode
  type                = each.value.authentication_type

  depends_on = [
    nxos_ospf_interface.ospfIf
  ]
}
