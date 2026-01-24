terraform {
  backend "gcs" {
    bucket = "sysdev-tfstate"
    prefix = "bootstrap/root"
  }
}
