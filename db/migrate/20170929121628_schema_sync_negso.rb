### Generated by SchemaSync
class SchemaSyncNegso < ActiveRecord::Migration
	def change
		add_column :features, :created_at, :datetime
		add_column :features, :updated_at, :datetime
	end
end