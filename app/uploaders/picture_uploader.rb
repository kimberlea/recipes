class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :fog

  process resize_to_limit: [1000, 1000]
  version :thumb do
    process resize_to_fill: [200, 200]
  end

  def store_dir
    "#{model.class.to_s.underscore}_picture/#{model.id}"
  end

end
