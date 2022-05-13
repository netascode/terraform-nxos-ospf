terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    nxos = {
      source  = "netascode/nxos"
      version = ">=0.3.10"
    }
  }
}

# requirement
resource "nxos_feature_ospf" "fmOspf" {
  admin_state = "enabled"
}

resource "nxos_ospf" "ospfEntity" {
  admin_state = "enabled"
  depends_on = [
    nxos_feature_ospf.fmOspf
  ]
}

resource "nxos_feature_interface_vlan" "fmInterfaceVlan" {
  admin_state = "enabled"
}

resource "nxos_svi_interface" "svi100" {
  interface_id = "vlan100"

  depends_on = [
    nxos_feature_interface_vlan.fmInterfaceVlan
  ]
}

resource "nxos_svi_interface" "svi101" {
  interface_id = "vlan101"

  depends_on = [
    nxos_feature_interface_vlan.fmInterfaceVlan
  ]
}

module "main" {
  source = "../.."

  name = "OSPF1"
  vrfs = [
    {
      vrf                     = "default"
      admin_state             = false
      bandwidth_reference     = 1000
      banwidth_reference_unit = "gbps"
      distance                = 120
      router_id               = "100.1.1.1"
      areas = [
        {
          area = "0.0.0.0"
        },
        {
          area                = "10.0.0.0"
          authentication_type = "md5"
          cost                = 100
          type                = "nssa"
        }
      ]
      interfaces = [
        {
          interface = "vlan100"
        },
        {
          interface             = "vlan101"
          area                  = "10.0.0.0"
          advertise_secondaries = false
          bfd                   = "enabled"
          cost                  = 1000
          dead_interval         = 60
          hello_interval        = 20
          network_type          = "p2p"
          passive               = "enabled"
          authentication_key    = "0 foo"
          authentication_key_id = 12
          authentication_type   = "simple"
          priority              = 100
        }
      ]
    }
  ]

  depends_on = [
    nxos_ospf.ospfEntity,
    nxos_svi_interface.svi100,
    nxos_svi_interface.svi101
  ]
}

data "nxos_ospf_instance" "ospfInst" {
  name       = "OSPF1"
  depends_on = [module.main]
}

resource "test_assertions" "nxos_ospf_instance" {
  component = "nxos_ospf_instance"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_ospf_instance.ospfInst.admin_state
    want        = "enabled"
  }
}

data "nxos_ospf_vrf" "ospfDom" {
  instance_name = "OSPF1"
  name          = "default"
  depends_on    = [module.main]
}

resource "test_assertions" "nxos_ospf_vrf" {
  component = "nxos_ospf_vrf"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_ospf_vrf.ospfDom.admin_state
    want        = "disabled"
  }

  equal "bandwidth_reference" {
    description = "bandwidth_reference"
    got         = data.nxos_ospf_vrf.ospfDom.bandwidth_reference
    want        = 1000
  }

  equal "banwidth_reference_unit" {
    description = "banwidth_reference_unit"
    got         = data.nxos_ospf_vrf.ospfDom.banwidth_reference_unit
    want        = "gbps"
  }

  equal "distance" {
    description = "distance"
    got         = data.nxos_ospf_vrf.ospfDom.distance
    want        = 120
  }

  equal "router_id" {
    description = "router_id"
    got         = data.nxos_ospf_vrf.ospfDom.router_id
    want        = "100.1.1.1"
  }
}

data "nxos_ospf_area" "ospfArea_0" {
  instance_name = "OSPF1"
  vrf_name      = "default"
  area_id       = "0.0.0.0"
  depends_on    = [module.main]
}

resource "test_assertions" "nxos_ospf_area_0" {
  component = "nxos_ospf_area_0"

  equal "area_id" {
    description = "area_id"
    got         = data.nxos_ospf_area.ospfArea_0.area_id
    want        = "0.0.0.0"
  }

  equal "authentication_type" {
    description = "authentication_type"
    got         = data.nxos_ospf_area.ospfArea_0.authentication_type
    want        = "unspecified"
  }

  equal "cost" {
    description = "cost"
    got         = data.nxos_ospf_area.ospfArea_0.cost
    want        = 1
  }

  equal "type" {
    description = "type"
    got         = data.nxos_ospf_area.ospfArea_0.type
    want        = "regular"
  }
}

data "nxos_ospf_area" "ospfArea_10" {
  instance_name = "OSPF1"
  vrf_name      = "default"
  area_id       = "10.0.0.0"
  depends_on    = [module.main]
}

resource "test_assertions" "nxos_ospf_area_10" {
  component = "nxos_ospf_area_10"

  equal "area_id" {
    description = "area_id"
    got         = data.nxos_ospf_area.ospfArea_10.area_id
    want        = "10.0.0.0"
  }

  equal "authentication_type" {
    description = "authentication_type"
    got         = data.nxos_ospf_area.ospfArea_10.authentication_type
    want        = "md5"
  }

  equal "cost" {
    description = "cost"
    got         = data.nxos_ospf_area.ospfArea_10.cost
    want        = 100
  }

  equal "type" {
    description = "type"
    got         = data.nxos_ospf_area.ospfArea_10.type
    want        = "nssa"
  }
}

data "nxos_ospf_interface" "ospfIf_vlan100" {
  instance_name = "OSPF1"
  vrf_name      = "default"
  interface_id  = "vlan100"
  depends_on    = [module.main]
}

resource "test_assertions" "ospfIf_vlan100" {
  component = "ospfIf_vlan100"

  equal "advertise_secondaries" {
    description = "advertise_secondaries"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.advertise_secondaries
    want        = true
  }

  equal "area" {
    description = "area"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.area
    want        = "0.0.0.0"
  }

  equal "cost" {
    description = "area"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.cost
    want        = 0
  }

  equal "dead_interval" {
    description = "dead_interval"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.dead_interval
    want        = 0
  }

  equal "hello_interval" {
    description = "hello_interval"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.hello_interval
    want        = 10
  }

  equal "network_type" {
    description = "network_type"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.network_type
    want        = "unspecified"
  }

  equal "passive" {
    description = "passive"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.passive
    want        = "unspecified"
  }

  equal "priority" {
    description = "priority"
    got         = data.nxos_ospf_interface.ospfIf_vlan100.priority
    want        = 1
  }
}

data "nxos_ospf_interface" "ospfIf_vlan101" {
  instance_name = "OSPF1"
  vrf_name      = "default"
  interface_id  = "vlan101"
  depends_on    = [module.main]
}

resource "test_assertions" "ospfIf_vlan101" {
  component = "ospfIf_vlan101"

  equal "advertise_secondaries" {
    description = "advertise_secondaries"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.advertise_secondaries
    want        = false
  }

  equal "area" {
    description = "area"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.area
    want        = "10.0.0.0"
  }

  equal "cost" {
    description = "area"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.cost
    want        = 1000
  }

  equal "dead_interval" {
    description = "dead_interval"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.dead_interval
    want        = 60
  }

  equal "hello_interval" {
    description = "hello_interval"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.hello_interval
    want        = 20
  }

  equal "network_type" {
    description = "network_type"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.network_type
    want        = "p2p"
  }

  equal "passive" {
    description = "passive"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.passive
    want        = "enabled"
  }

  equal "priority" {
    description = "passive"
    got         = data.nxos_ospf_interface.ospfIf_vlan101.priority
    want        = 100
  }
}

data "nxos_ospf_authentication" "ospfAuthNewP" {
  instance_name = "OSPF1"
  vrf_name      = "default"
  interface_id  = "vlan101"
  depends_on    = [module.main]
}

resource "test_assertions" "ospfAuthNewP" {
  component = "ospfAuthNewP"

  equal "key_id" {
    description = "key_id"
    got         = data.nxos_ospf_authentication.ospfAuthNewP.key_id
    want        = 12
  }

  equal "type" {
    description = "type"
    got         = data.nxos_ospf_authentication.ospfAuthNewP.type
    want        = "simple"
  }
}
