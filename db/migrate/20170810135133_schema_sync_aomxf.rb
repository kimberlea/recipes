### Generated by SchemaSync
class SchemaSyncAomxf < ActiveRecord::Migration
	def change
		add_column :dishes, :is_recipe_given, :boolean, {:default=>true}
	end
end