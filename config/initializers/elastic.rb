ELASTIC_CONFIG = {
  settings: {
    analysis: {
      analyzer: {
        folding: {
          type: "custom",
          tokenizer: "standard",
          filter: ["lowercase", "asciifolding"]
        }
      }
    }
  },
  mappings: {
    dish: proc {
      indexes :id, index: 'not_analyzed'
      indexes :title, analyzer: 'english'
      indexes :description, analyzer: 'english'
      indexes :tags, analyzer: 'english'
      indexes :creator_id, index: 'not_analyzed'
      indexes :locations, &ELASTIC_CONFIG[:mappings][:location]
      indexes :creator, &ELASTIC_CONFIG[:mappings][:user]
    },
    user: proc {
      indexes :id, index: 'not_analyzed'
      indexes :full_name, analyzer: 'folding'
      indexes :bio, analyzer: 'english'
    },
    location: proc {
      indexes :id, index: 'not_analyzed'
      indexes :city, analyzer: 'folding'
      indexes :admin, analyzer: 'folding'
      indexes :country, analyzer: 'folding'
      indexes :point, type: 'geo_point'
    }
  }
}

Elasticsearch::Model.client = Elasticsearch::Client.new(host: "http://localhost:9200")
