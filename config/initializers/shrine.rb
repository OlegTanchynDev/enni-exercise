# frozen_string_literal: true

require "shrine"
require "shrine/storage/file_system"

# Local filesystem storage keeps the skeleton offline — no S3, no MinIO, no keys.
# The real Enni uses Shrine with S3 in production and MinIO in dev; the uploader
# API is identical, so candidate code that attaches/reads photos transfers 1:1.
Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store")
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
