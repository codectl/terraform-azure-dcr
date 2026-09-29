module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["dcr", "dev"]
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

module "dcr" {
  source  = "codectl/dcr/azure"
  version = "~> 1.0"

  rule = {
    name                = module.naming.data_collection_rule.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    data_flow = {
      df1 = {
        streams      = ["Microsoft-InsightsMetrics"]
        destinations = ["la1"]
      }
    }

    destinations = {
      log_analytics = {
        la1 = {
          workspace_resource_id = module.law.workspace.id
        }
      }
    }
  }
}
