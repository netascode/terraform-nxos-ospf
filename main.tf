locals {
  vrf_map = { for v in var.vrfs : v.name => v }
  area_map = merge([
    for vrf_entry in var.vrfs : vrf_entry.areas == null ? {} : {
      for area_entry in vrf_entry.areas : "${vrf_entry.name}_${area_entry.area}" => merge(area_entry, { "vrf" : vrf_entry.name })
    }
  ]...)
  interface_map = merge([
    for vrf_entry in var.vrfs : vrf_entry.interfaces == null ? {} : {
      for interface_entry in vrf_entry.interfaces : "${vrf_entry.name}_${interface_entry.interface}" => merge(interface_entry, { "vrf" : vrf_entry.name })
    }
  ]...)

  interface_auth_map = merge([
    for vrf_entry in var.vrfs : vrf_entry.interfaces == null ? {} : {
      for interface_entry in vrf_entry.interfaces : "${vrf_entry.name}_${interface_entry.interface}" => merge(interface_entry, { "vrf" : vrf_entry.name })
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
  name                    = each.value.name
  admin_state             = each.value.admin_state == null || each.value.admin_state == true ? "enabled" : "disabled"
  bandwidth_reference     = each.value.bandwidth_reference != null ? each.value.bandwidth_reference : 40000
  banwidth_reference_unit = each.value.banwidth_reference_unit != null ? each.value.banwidth_reference_unit : "mbps"
  distance                = each.value.distance != null ? each.value.distance : 110
  router_id               = each.value.router_id != null ? each.value.router_id : "0.0.0.0"

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
  authentication_type = each.value.authentication_type != null ? each.value.authentication_type : "unspecified"
  cost                = each.value.cost != null ? each.value.cost : 1
  type                = each.value.type != null ? each.value.type : "regular"

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
  advertise_secondaries = each.value.advertise_secondaries != null ? each.value.advertise_secondaries : true
  area                  = each.value.area != null ? each.value.area : "0.0.0.0"
  bfd                   = each.value.bfd != null ? each.value.bfd : "unspecified"
  cost                  = each.value.cost != null ? each.value.cost : 0
  dead_interval         = each.value.dead_interval != null ? each.value.dead_interval : 0
  hello_interval        = each.value.hello_interval != null ? each.value.hello_interval : 10
  network_type          = each.value.network_type != null ? each.value.network_type : "unspecified"
  passive               = each.value.passive != null ? each.value.passive : "unspecified"
  priority              = each.value.priority != null ? each.value.priority : 1

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
  key_id              = each.value.authentication_key_id != null ? each.value.authentication_key_id : 0
  key_secure_mode     = each.value.authentication_key_secure_mode != null ? each.value.authentication_key_secure_mode : false
  keychain            = each.value.authentication_keychain
  md5_key             = each.value.authentication_md5_key
  md5_key_secure_mode = each.value.authentication_md5_key_secure_mode != null ? each.value.authentication_md5_key_secure_mode : false
  type                = each.value.authentication_type

  depends_on = [
    nxos_ospf_interface.ospfIf
  ]
}
