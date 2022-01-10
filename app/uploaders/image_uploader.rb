require "image_processing/mini_magick"

class ImageUploader < Shrine
  Attacher.validate do
    validate_max_size 5*1024*1024
    validate_mime_type %w[image/jpeg image/png image/webp image/tiff]
    validate_extension %w[jpg jpeg png webp tiff tif]
  end

  plugin :processing # allows hooking into promoting
  plugin :versions   # enable Shrine to handle a hash of files
  plugin :delete_raw # delete processed files after uploading

  process(:store) do |io, context|
    versions = { original: io } # retain original

    io.download do |original|
      pipeline = ImageProcessing::MiniMagick.source(original)

      versions[:large]  = pipeline.resize_to_limit!(800, 800)
      versions[:medium] = pipeline.resize_to_limit!(500, 500)
      versions[:small]  = pipeline.resize_to_limit!(150, 150)
    end

    versions # return the hash of processed files
  end
end
