region  = "europe-west1"

database = {
  tier    = "db-f1-micro"
  region  = "europe-west1"
}

servers = {
  region              = "europe-west1"
  cidr_range          = "10.128.0.0/20"
  machine_type        = "e2-micro"
  target_size         = 3
  authorized_networks = "91.183.51.235/32"
}

agents = {
  eu001 = {
    region        = "europe-west4",
    cidr_range    = "10.164.0.0/20"
    machine_type  = "e2-micro"
    target_size   = 2
  },
  eu002 = {
    region        = "europe-north1",
    cidr_range    = "10.166.0.0/20"
    machine_type  = "e2-micro"
    target_size   = 2
  },
  eu003 = {
    region        = "europe-west2",
    cidr_range    = "10.154.0.0/20"
    machine_type  = "e2-medium"
    target_size   = 2
  },
}