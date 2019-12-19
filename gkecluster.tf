resource "google_container_cluster" "gke-cluster" {
  name               = "cptest6"
  network            = "default"
  location               = "us-central1-a"
  initial_node_count = 3
  
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

}

provider "google" {
  credentials = file("./creds/serviceaccount.json")
  project     = "it-sec-gcp-training"
  region      = "us-central1"
}

