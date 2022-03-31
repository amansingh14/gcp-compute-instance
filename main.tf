resource "random_string" "bucket" {
  for_each = local.storage_buckets
  length   = 2
  special  = false
  upper    = false
}
resource "google_compute_disk" "windows_boot_disk" {
  count   = 3
  project = local.project_name
  name    = "Windows-server-ad-${count.index}"
  image   = local.windows_image
  type    = "pd-ssd"
  zone    = ""
  size    = 100
}

resource "google_compute_disk" "cloudfs-ps-disk" {
  count   = 3
  project = local.project_name
  name    = "cloudfs-ps-disk-${count.index}"
  image   = local.windows_image
  type    = "pd-ssd"
  zone    = ""
  size    = 50
}

resource "google_compute_disk" "addition_cache_disks" {
  count   = 2
  project = local.project_name
  name    = "cloudfs-cache-disk-${count.index}"
  type    = "pd-ssd"
  zone    = local.zone_id
  size    = 100
}

resource "google_compute_disk" "addition_metadata_disks" {
  count   = 2
  project = local.project_name
  name    = "cloudfs-metadata-disk-${count.index}"
  type    = "pd-ssd"
  zone    = local.zone_id
  size    = 100
}
resource "google_compute_instance" "windows-instance" {
  count                     = 3
  project                   = local.project_name
  machine_type              = "n2-standard-4"
  name                      = "Windows-server-AD-${count.index}"
  zone                      = ""
  allow_stopping_for_update = true
  boot_disk {
    source = google_compute_disk.windows_boot_disk[count.index].self_link
  }
  network_interface {
    network            = "default"
    subnetwork_project = "project_id"
  }
}

resource "google_compute_instance" "cloudfs-instance" {
  count                     = 2
  project                   = local.project_name
  machine_type              = "n2-standard-4"
  name                      = "cloudfs-node-inst-${count.index}"
  zone                      = ""
  allow_stopping_for_update = true
  boot_disk {
    source = google_compute_disk.cloudfs-ps-disk[count.index].self_link

  }
  network_interface {
    network            = "default"
    subnetwork_project = "project_id"
  }
}

resource "google_compute_attached_disk" "attach_metadata_disk" {
  count    = 2
  project  = local.project_name
  zone     = local.zone_id
  disk     = google_compute_disk.addition_cache_disks[count.index].name
  instance = google_compute_instance.cloudfs-instance[count.index].name
}

resource "google_compute_attached_disk" "attach_cache_disk" {
  count    = 2
  project  = local.project_name
  zone     = local.zone_id
  disk     = google_compute_disk.addition_cache_disks[count.index].name
  instance = google_compute_instance.cloudfs-instance[count.index].name
}

resource "google_storage_bucket" "cloudfs_bucket" {
  for_each = local.storage_buckets
  project  = local.project_name
  location = local.zone_id
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
