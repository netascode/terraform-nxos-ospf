<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-nxos-ospf/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-nxos-ospf/actions/workflows/test.yml)

# Terraform NX-OS OSPF Module

Manages NX-OS OSPF

Model Documentation: [Link](https://developer.cisco.com/docs/cisco-nexus-3000-and-9000-series-nx-api-rest-sdk-user-guide-and-api-reference-release-9-3x/#!configuring-ospf)

## Examples

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | >= 0.3.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nxos"></a> [nxos](#provider\_nxos) | >= 0.3.10 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_device"></a> [device](#input\_device) | A device name from the provider configuration. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | OSPF Process Name. | `string` | n/a | yes |
| <a name="input_vrfs"></a> [vrfs](#input\_vrfs) | OSPF VRF list.<br>  Default value `admin_state`: `true`.<br>  Default value `bandwidth_reference`: `40000`.<br>  Choices `banwidth_reference_unit`: `mbps`, `gbps`. Default value `banwidth_reference_unit`: `mbps`.<br>  Default value `distance`: `110`.<br>  List `areas`:<br>  Allowed formats `area`: `0.0.0.10`. Default value `area`: `0.0.0.0`.<br>  Choices `authentication_type`: `unspecified`, `simple`, `md5`, `none`. Default value `authentication_type`: `unspecified`.<br>  Default value `cost`: `110`.<br>  List `interfaces`:<br>  Default value `advertise_secondaries`: `true`.<br>  Allowed formats `area`: `0.0.0.10`. Default value `area`: `0.0.0.0`.<br>  Default value `advertise_secondaries`: `true`.<br>  Choices `bfd`: `unspecified`, `enabled`, `disabled`. Default value `bfd`: `unspecified`.<br>  Default value `cost`: `0`.<br>  Default value `dead_interval`: `0`.<br>  Default value `hello_interval`: `10`.<br>  Choices `network_type`: `unspecified`, `p2p`, `bcast`. Default value `network_type`: `unspecified`.<br>  Choices `passive`: `unspecified`, `enabled`, `disabled`. Default value `passive`: `unspecified`.<br>  Default value `priority`: `1`.<br>  Allowed formats `authentication_key`: '0 <unencrypted-key>', '3 <3DES-format-encrypted-key>', '7 <Cisco-type-encrypted-key>'. Default value `area`: `0.0.0.0`.<br>  Default value `authentication_key_id`: `0`.<br>  Default value `authentication_key_secure_mode`: `false`.<br>  Default value `authentication_md5_key_secure_mode`: `false`.<br>  Choices `authentication_type`: `unspecified`, `simple`, `md5`, `none`. Default value `authentication_type`: `unspecified`. | <pre>list(object({<br>    vrf                     = string<br>    admin_state             = optional(bool)<br>    bandwidth_reference     = optional(number)<br>    banwidth_reference_unit = optional(string)<br>    distance                = optional(number)<br>    router_id               = optional(string)<br>    # adjancency_logging_level = optional(string)<br>    areas = optional(list(object({<br>      area                = string<br>      authentication_type = optional(string)<br>      cost                = optional(number)<br>      type                = optional(string)<br>    })))<br>    interfaces = optional(list(object({<br>      interface                          = string<br>      advertise_secondaries              = optional(bool)<br>      area                               = optional(string)<br>      bfd                                = optional(string)<br>      cost                               = optional(number)<br>      dead_interval                      = optional(number)<br>      hello_interval                     = optional(number)<br>      network_type                       = optional(string)<br>      passive                            = optional(string)<br>      priority                           = optional(number)<br>      authentication_key                 = optional(string)<br>      authentication_key_id              = optional(number)<br>      authentication_key_secure_mode     = optional(bool)<br>      authentication_keychain            = optional(string)<br>      authentication_md5_key             = optional(string)<br>      authentication_md5_key_secure_mode = optional(bool)<br>      authentication_type                = optional(string)<br>    })))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dn"></a> [dn](#output\_dn) | Distinguished name of the object. |

## Resources

| Name | Type |
|------|------|
| [nxos_ospf_area.ospfArea](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/ospf_area) | resource |
| [nxos_ospf_authentication.ospfAuthNewP](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/ospf_authentication) | resource |
| [nxos_ospf_instance.ospfInst](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/ospf_instance) | resource |
| [nxos_ospf_interface.ospfIf](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/ospf_interface) | resource |
| [nxos_ospf_vrf.ospfDom](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/ospf_vrf) | resource |
<!-- END_TF_DOCS -->