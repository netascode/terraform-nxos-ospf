terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    nxos = {
      source  = "netascode/nxos"
      version = ">=0.3.8"
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

module "main" {
  source = "../.."

  name = "OSPF1"
  depends_on = [
    nxos_ospf.ospfEntity
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
