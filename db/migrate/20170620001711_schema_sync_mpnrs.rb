### Generated by SchemaSync
class SchemaSyncMpnrs < ActiveRecord::Migration
	def change
		add_column :users, :is_superadmin, :boolean, {:default=>false}
	end
end