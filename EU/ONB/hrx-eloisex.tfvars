suffix      = ["alg", "o", "cus", "eloise", "31"]
landscape = "US03"
environment = "onb"
location    = "centralus"
service     = "eloise"

tags = {
  serviceOwner = "GT"
  environment  = "onb"
  costCenter   = "GB762"
  serviceName  = "eloise"
  deployedBy   = "Terraform"
}

resource_group         = "rg-alg-o-cus-eloise-31"
mssql_server_name      = "sql-alg-o-cus-eloise-31"
mssql_elasticpool_name = "sqlep-alg-o-cus-eloise-31"

exchange_db_name = "stalgocuseloise31"
exchange_db_rg   = "rg-alg-o-cus-eloise-31"

sku_name                    = "ElasticPool"
short_term_retention_policy = [{ retention_days = 7 }]
read_scale                  = false
