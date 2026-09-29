module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "law" {
  source  = "codectl/law/azure"
  version = "~> 1.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "dcr_windows" {
  source  = "codectl/dcr/azure"
  version = "~> 1.0"

  rule = {
    name                = module.naming.data_collection_rule.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    destinations = {
      log_analytics = {
        la1 = {
          workspace_resource_id = module.law.workspace.id
        }
      }
    }

    data_flow = {
      df_perf = {
        streams      = ["Microsoft-Perf"]
        destinations = ["la1"]
      }
    }

    data_sources = {
      performance_counter = {
        cpu = {
          streams                       = ["Microsoft-Perf"]
          sampling_frequency_in_seconds = 60
          counter_specifiers = [
            "\\Processor(_Total)\\%% Processor Time",
            "\\Memory\\Available Bytes"
          ]
        }
        memory = {
          streams                       = ["Microsoft-Perf"]
          sampling_frequency_in_seconds = 30
          counter_specifiers = [
            "\\Memory\\Available Bytes",
            "\\Memory\\%% Committed Bytes In Use"
          ]
        }
      }
    }
  }
}
