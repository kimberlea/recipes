module APIUtils

  module Validation
    def validate_length_of(field, field_name, min=1, max=5000)
      val = self.send(field)
      if val.present? && (val.length > max || val.length < min)
        errors.add(field, "The #{field_name} must be between #{min} and #{max} characters long.")
      end
    end
  end

end
