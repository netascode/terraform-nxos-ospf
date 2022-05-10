module "nxos_ospf" {
  source  = "netascode/ospf/nxos"
  version = ">= 0.1.0"

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
}
