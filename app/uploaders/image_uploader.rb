# frozen_string_literal: true

# Shrine uploader for cleaning photos. Deliberately minimal — derivatives and
# strict validation are out of scope for the test. Storage is local filesystem
# in dev/test (see config/initializers/shrine.rb); S3 in production.
class ImageUploader < Shrine
end
