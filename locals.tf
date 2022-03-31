locals {
  storage_buckets = {
  cloudfs1 : {
    type     = "cloudfs"
    location = "us-central1"
  },
  cloudmirror : {
    type     = "cloudmirror"
    location = "us-central1"
  },
  cloudfs2 : {
    type     = "cloudfs"
    location = "us-central1"
  },
}
  project_name = "tryme2"
  windows_image = "windows-cloud/windows-2019"
  zone_id     = "us-central1-a"
}