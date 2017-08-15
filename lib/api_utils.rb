require 'nokogiri'
require 'open-uri'
require 'iso8601'

module APIUtils

  module Validation
    def validate_length_of(field, field_name, min=1, max=5000)
      val = self.send(field)
      if val.present? && (val.length > max || val.length < min)
        errors.add(field, "The #{field_name} must be between #{min} and #{max} characters long.")
      end
    end
  end

  def self.import_big_oven_recipe(url, opts={})
    if opts[:all]
      urls = self.find_all_big_oven_links(url)
      urls.each do |url|
        begin
          next if Dish.where(source_url: url).count > 0
          self.import_big_oven_recipe(url)
          puts "Waiting 5 seconds"
          sleep 5
        rescue => ex
          QuickScript.log_exception(ex)
          puts "Could not parse recipe #{url}"
        end
      end
      return
    end
    d = opts[:dish] || Dish.new
    url = d.source_url if d && url.nil?
    url = url.strip
    # check if url already added
    if d.new_record? && Dish.where(source_url: url).count > 0
      return {success: false, error: "This url has already been added.", error_type: "AlreadyAddedError"}
    end
    xml = Nokogiri::XML(open(url).read)
    json = xml.css("script[type='application/ld+json']").first.text
    r = YAML.load(json)
    d.title = r['name']
    d.description = r['description']
    d.description = r['name'] if d.description.blank?
    d.serving_size = r['recipeYield'].to_i || 1
    d.ingredients = r['recipeIngredient'].collect{|l| l.strip}.join("\n")
    d.directions = r['recipeInstructions'].join("\n")
    d.prep_time_mins = ISO8601::Duration.new(r['totalTime']).to_seconds / 60
    d.remote_image_url = r['image']
    d.source_url = url
    d.creator_id = Rails.env.production? ? 9 : 1 
    saved = d.save
    if saved
      puts "Dish was saved! #{d.view_path(full: true)}"
    else
      puts "Dish was NOT saved! #{d.error_message}"
    end
    return {success: saved, data: d, error: d.error_message}
  end

  def self.find_all_big_oven_links(url)
    xml = Nokogiri::XML(open(url).read)
    as = xml.css("a")
    urls = as.collect{|a| a["href"]}.compact.collect{|l| l.strip}
    urls = urls.select {|url| url.include?("bigoven.com/recipe")}.uniq
    return urls
  end

end
