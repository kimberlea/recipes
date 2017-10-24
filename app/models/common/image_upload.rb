module Common

  class ImageUpload
    include QuickScript::HashModel
    include QuickFile::Upload

    quick_file_upload!

    style_type :avatar, 10
    style_type :media, 20

    add_style :original, lambda {|upl, file|
      QuickFile.resize_to_fit(file, 1500, 1500)
    }
    add_style :thumb, lambda {|upl, file|
      QuickFile.resize_to_fit(file, 250, 250)
    }

    def validate!
      error_log << "Upload must be an image for now." if !self.is_image?
    end

    def storage_path(style_name, ext)
      ids = self.id.to_s
      "image/#{ids}/#{style_name.to_s}#{ext}"
    end

    def to_api(opts={})
      ret = {}
      ret[:id] = self.id.to_s
      ret[:state] = self.state
      ret[:url] = self.url_hash
      return ret
    end
    
  end

end
