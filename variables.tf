variable "device" {
  description = "A device name from the provider configuration."
  type        = string
  default     = null
}

variable "name" {
  description = "OSPF Process Name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,32}$", var.name))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `-`. Maximum characters: 20."
  }
}

variable "vrfs" {
  description = <<EOT
  OSPF VRF list.
  Default value `admin_state`: `true`.
  Default value `bandwidth_reference`: `40000`.
  Choices `banwidth_reference_unit`: `mbps`, `gbps`. Default value `banwidth_reference_unit`: `mbps`.
  Default value `distance`: `110`.
  List `areas`:
  Allowed formats `area`: `0.0.0.10`. Default value `area`: `0.0.0.0`.
  Choices `authentication_type`: `unspecified`, `simple`, `md5`, `none`. Default value `authentication_type`: `unspecified`.
  Default value `cost`: `110`.
  List `interfaces`:
  Default value `advertise_secondaries`: `true`.
  Allowed formats `area`: `0.0.0.10`. Default value `area`: `0.0.0.0`.
  Default value `advertise_secondaries`: `true`.
  Choices `bfd`: `unspecified`, `enabled`, `disabled`. Default value `bfd`: `unspecified`.
  Default value `cost`: `0`.
  Default value `dead_interval`: `0`.
  Default value `hello_interval`: `10`.
  Choices `network_type`: `unspecified`, `p2p`, `bcast`. Default value `network_type`: `unspecified`.
  Choices `passive`: `unspecified`, `enabled`, `disabled`. Default value `passive`: `unspecified`.
  Default value `priority`: `1`.
  Allowed formats `authentication_key`: '0 <unencrypted-key>', '3 <3DES-format-encrypted-key>', '7 <Cisco-type-encrypted-key>'. Default value `area`: `0.0.0.0`.
  Default value `authentication_key_id`: `0`.
  Default value `authentication_key_secure_mode`: `false`.
  Default value `authentication_md5_key_secure_mode`: `false`.
  Choices `authentication_type`: `unspecified`, `simple`, `md5`, `none`. Default value `authentication_type`: `unspecified`.
  EOT
  type = list(object({
    vrf                     = string
    admin_state             = optional(bool, true)
    bandwidth_reference     = optional(number, 40000)
    banwidth_reference_unit = optional(string, "mbps")
    distance                = optional(number, 110)
    router_id               = optional(string, "0.0.0.0")
    # adjancency_logging_level = optional(string)
    areas = optional(list(object({
      area                = string
      authentication_type = optional(string, "unspecified")
      cost                = optional(number, 1)
      type                = optional(string, "regular")
    })))
    interfaces = optional(list(object({
      interface                          = string
      advertise_secondaries              = optional(bool, true)
      area                               = optional(string, "0.0.0.0")
      bfd                                = optional(string, "unspecified")
      cost                               = optional(number, 0)
      dead_interval                      = optional(number, 0)
      hello_interval                     = optional(number, 10)
      network_type                       = optional(string, "unspecified")
      passive                            = optional(string, "unspecified")
      priority                           = optional(number, 1)
      authentication_key                 = optional(string)
      authentication_key_id              = optional(number, 0)
      authentication_key_secure_mode     = optional(bool, false)
      authentication_keychain            = optional(string)
      authentication_md5_key             = optional(string)
      authentication_md5_key_secure_mode = optional(bool, false)
      authentication_type                = optional(string)
    })))
  }))
  default = []

  validation {
    condition = alltrue([
      for v in var.vrfs : try(contains(["mbps", "gbps"], v.banwidth_reference_unit), v.banwidth_reference_unit == null)
    ])
    error_message = "`banwidth_reference_unit`: Allowed values are: `mbps` or `gbps`."
  }

  validation {
    condition = alltrue([
      for v in var.vrfs : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", v.router_id)) || v.router_id == null
    ])
    error_message = "`router_id`: Allowed formats are: `192.168.1.1`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.areas == null ? [true] : [
        for v in value.areas : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", v.area)) || v.area == null
      ]
    ]))
    error_message = "`areas - area`: Allowed formats are: `0.0.0.10`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.areas == null ? [true] : [
        for v in value.areas : try(contains(["unspecified", "simple", "md5", "none"], v.authentication_type), v.authentication_type == null)
      ]
    ]))
    error_message = "`areas - authentication_type`: Allowed values are: `unspecified`, `simple`, `md5` or `none`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", v.area)) || v.area == null
      ]
    ]))
    error_message = "`interfaces - area`: Allowed formats are: `0.0.0.10`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(contains(["unspecified", "enabled", "disabled"], v.bfd), v.bfd == null)
      ]
    ]))
    error_message = "`interfaces - bfd`: Allowed values are: `unspecified`, `enabled` or `disabled`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(v.cost >= 0 && v.cost <= 3600, v.cost == null)
      ]
    ]))
    error_message = "`interfaces - cost`: Minimum value: `0`. Maximum value: `65535`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(v.dead_interval >= 0 && v.dead_interval <= 3600, v.dead_interval == null)
      ]
    ]))
    error_message = "`interfaces - dead_interval`: Minimum value: `0`. Maximum value: `65535`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(v.hello_interval >= 0 && v.hello_interval <= 3600, v.hello_interval == null)
      ]
    ]))
    error_message = "`interfaces - hello_interval`: Minimum value: `0`. Maximum value: `65535`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(contains(["unspecified", "p2p", "bcast"], v.network_type), v.network_type == null)
      ]
    ]))
    error_message = "`interfaces - network_type`: Allowed values are: `unspecified`, `p2p` or `bcast`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(contains(["unspecified", "enabled", "disabled"], v.passive), v.passive == null)
      ]
    ]))
    error_message = "`interfaces - passive`: Allowed values are: `unspecified`, `enabled` or `disabled`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(v.priority >= 0 && v.priority <= 255, v.priority == null)
      ]
    ]))
    error_message = "`interfaces - priority`: Minimum value: `0`. Maximum value: `255`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : can(regex("^[037] \\S+$", v.authentication_key)) || v.authentication_key == null
        # || can(regex("^3 \\S+$", v.authentication_key)) || can(regex("^7 \\S+$", v.authentication_key)) || 
      ]
    ]))
    error_message = "`interfaces - authentication_key`: Allowed formats are: '0 <unencrypted-key>', '3 <3DES-format-encrypted-key>', '7 <Cisco-type-encrypted-key>'."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(v.authentication_key_id >= 0 && v.authentication_key_id <= 255, v.authentication_key_id == null)
      ]
    ]))
    error_message = "`interfaces - authentication_key_id`: Minimum value: `0`. Maximum value: `255`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(contains(["unspecified", "simple", "md5", "none"], v.authentication_type), v.authentication_type == null)
      ]
    ]))
    error_message = "`interfaces - authentication_type`: Allowed values are: `unspecified`, `simple`, `md5` or `none`."
  }
}
