provider "google" {
  project = "project-bd35fdf8-3277-4d41-a98" # my first project
  region  = "australia-southeast1"
}

resource "google_compute_instance" "devops_vm" {
  name         = "devops-lab-vm"
  machine_type = "e2-micro" # Free tier eligible in some regions
  zone         = "australia-southeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP to allow internet access
    }
  }

  # This is the "DevOps Magic" - it installs Nginx on boot
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    echo "<h1>Hello from Terraform and GitHub Actions!</h1>" > /var/www/html/index.html
  EOT

  # This allows the VM to be reached on Port 80
  tags = ["http-server"]
}

# This opens the firewall for the "http-server" tag
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}