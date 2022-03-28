resource "random_string" "bucket" {
  for_each = local.storage_buckets
  length   = 2
  special  = false
  upper    = false
}
resource "google_compute_disk" "windows_boot_disk" {
  project = local.project_name
  name    = "Windows-server-ad"
  image   = "windows-cloud/windows-2019"
  type    = "pd-ssd"
  zone    = ""
  size    = 100
}

resource "google_compute_disk" "addition_disks" {
  project = local.project_name
  name    = "metadata"
  type    = "pd-ssd"
  zone    = "us-central1"
  size    = 100
}

resource "google_compute_instance" "windows-instance" {
  project                   = local.project_name
  machine_type              = "n2-standard-4"
  name                      = "Windows-server-AD"
  zone                      = ""
  allow_stopping_for_update = true
  boot_disk {
    source = google_compute_disk.windows_boot_disk.self_link
  }
  network_interface {
    network            = "default"
    subnetwork_project = "project_id"
  }
}

resource "google_compute_disk" "cloudfs_cache_disk" {
  project = local.project_name
  name    = "Windows-server-ad"
  image   = "image_id"
  type    = "pd-ssd"
  zone    = ""
  size    = 200
}

resource "google_compute_instance" "cloudfs-instance" {
  project                   = local.project_name
  machine_type              = "n2-standard-4"
  name                      = "Windows-server-AD"
  zone                      = ""
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network            = "default"
    subnetwork_project = "project_id"
  }
}

resource "google_compute_attached_disk" "attach_metadata_disk" {
  project  = local.project_name
  zone     = "us-central1"
  disk     = google_compute_disk.addition_disks.name
  instance = google_compute_instance.cloudfs-instance.name
}

resource "google_compute_attached_disk" "attach_cache_disk" {
  project  = local.project_name
  zone     = "us-central1"
  disk     = google_compute_disk.cloudfs_cache_disk.name
  instance = google_compute_instance.cloudfs-instance.name
}

resource "google_storage_bucket" "cloudfs_bucket" {
  for_each = local.storage_buckets
  project  = local.project_name
  location = "us-central1"
  name     = "${local.project_name}-${each.value.type}-${random_string.bucket[each.key].result}"
}

data "google_iam_policy" "admin" {
  binding {
    members = [
      "user:example@example.com",
    ]
    role = "roles/storage.admin"
  }
  binding {
    members = [
      "serviceAccount:"
    ]
    role = "roles/storage.objectAdmin"
  }
}
resource "google_storage_bucket_iam_policy" "policy" {
  for_each    = local.storage_buckets
  bucket      = google_storage_bucket.cloudfs_bucket[each.key].name
  policy_data = data.google_iam_policy.admin.policy_data
}
