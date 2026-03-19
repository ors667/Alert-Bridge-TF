locals {
  app = "vitalbridge"
  env = var.environment

  labels = {
    app              = local.app
    env              = local.env
    "data-sensitivity" = "phi"
    "hipaa-scope"      = "true"
    managed-by       = "terraform"
  }
}
