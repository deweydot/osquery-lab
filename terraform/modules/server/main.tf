resource "google_cloud_run_v2_service" "service" {
    name = "osquery-lab-server"
    location = var.location
    deletion_protection = false
    ingress = "INGRESS_TRAFFIC_ALL"

    scaling {
        min_instance_count = 0
        max_instance_count = 1
    }

    template {
        containers {
            image = "fmi"
        }
    }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
    location = google_cloud_run_v2_service.service.location
    name     = google_cloud_run_v2_service.service.name
    role     = "roles/run.invoker"
    member   = "allUsers"
}