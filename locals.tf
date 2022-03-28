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
}