### Generated by SchemaSync
class SchemaSyncSviof < ActiveRecord::Migration
	def change
		add_column :recipes, :prep_time_mins, :integer
	end
end