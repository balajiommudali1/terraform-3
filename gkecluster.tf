resource "google_container_cluster" "mycluster" {
  name               = "cptest15"
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
master_authorized_networks_config {
  cidr_blocks {
      cidr_block   = "10.128.0.0/20"
      display_name = "azai"
    }
}

ip_allocation_policy  {
cluster_ipv4_cidr_block  = "10.31.0.0/21"
}
  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}

provider "google" {
  credentials = file("./creds/serviceaccount.json")
  project     = "it-sec-gcp-training"
  region      = "us-central1"
}


# resource "google_compute_network" "nwrk" {
#   name                    = "test-network"
#   auto_create_subnetworks = true
# }
# 
# resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
#   name          = "test-subnetwork"
#   ip_cidr_range = "10.2.0.0/16"
#   region        = "us-central1"
#   network       = google_compute_network.nwrk.self_link
#   secondary_ip_range {
#     range_name    = "tf-test-secondary-range-update1"
#     ip_cidr_range = "192.168.10.0/24"
#   }
#}




resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "nginx"
    }
  }

  spec {
    container {
      image = "gcr.io/hello-minikube-zero-install/hello-node"
      name  = "example"

      port {
        container_port = 8080
      }
    }
  }
}


resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_pod.nginx.metadata[0].labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.nginx.load_balancer_ingress[0].ip
}

data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file = false
  host = google_container_cluster.mycluster.endpoint
  token = data.google_client_config.default.access_token

  client_certificate = base64decode(google_container_cluster.mycluster.master_auth[0].client_certificate)
  client_key = base64decode(google_container_cluster.mycluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.mycluster.master_auth[0].cluster_ca_certificate)
}



#resource "google_compute_instance" "shell" {
#  name         = "shell"
#    machine_type = "n1-standard-1"
#	  zone         = "us-central1-a"
#
#
#  boot_disk {
#      initialize_params {
#	        image = "centos-cloud/centos-8"
#			    }
#				  }
#
#  network_interface {
#    network = "default"
#
#    access_config {
#      // Ephemeral IP
#    }
#  }
#
#	  }
