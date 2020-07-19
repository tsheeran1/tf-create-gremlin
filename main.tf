# Configure the provider
provider "azurerm" {
  version = "~> 2.00"
  features {}
}

# Common variables
locals {
  resource_location = "northcentralus"
}

# Create a new resource group
resource "azurerm_resource_group" "rg" {
  name     = "TFgremlinRG"
  location = local.resource_location

  tags = {
    environment = "TF sandbox"
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db_acct" {
  name                = "tfex-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  consistency_policy {
    consistency_level         = "BoundedStaleness"
    max_interval_in_seconds   = 301
    max_staleness_prefix      = 100001
  }
 
  geo_location {
    location          = "southcentralus"
    failover_priority = 1
  }

  geo_location {
    prefix            = "tfex-cosmost-db-${random_integer.ri.result}-customid"
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_gremlin_database" "gr_db" {
  name                  = "tfex-cosmos-gremlin-db"
  resource_group_name   = azurerm_cosmosdb_account.db_acct.resource_group_name
  account_name          = azurerm_cosmosdb_account.db_acct.name
}

resource "azurerm_cosmosdb_gremlin_graph" "graph" {
  name                  = "tfex-cosmos-gremlin-graph" 
  resource_group_name   = azurerm_cosmosdb_account.db_acct.resource_group_name
  account_name          = azurerm_cosmosdb_account.db_acct.name
  database_name         = azurerm_cosmosdb_gremlin_database.gr_db.name
  partition_key_path    = "/Example"
  throughput            = 400

  index_policy {
    automatic         = true
    indexing_mode     = "Consistent"
    included_paths    = ["/*"]
    excluded_paths    = ["/\"_etag\"/?"]
  }

  conflict_resolution_policy {
    mode                        = "LastWriterWins"
    conflict_resolution_path    = "/_ts"
  }

  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }
}