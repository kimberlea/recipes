### Generated by SchemaSync
class SchemaSyncAvpbu < ActiveRecord::Migration
	def change
		add_column :dishes, :cached_ratings_count, :integer
		add_column :dishes, :cached_ratings_avg, :decimal
	end
end