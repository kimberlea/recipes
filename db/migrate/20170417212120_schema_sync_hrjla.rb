### Generated by SchemaSync
class SchemaSyncHrjla < ActiveRecord::Migration
	def change
		add_column :recipes, :search_vector, :tsvector
	end
end