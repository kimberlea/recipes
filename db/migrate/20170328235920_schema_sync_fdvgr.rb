### Generated by SchemaSync
class SchemaSyncFdvgr < ActiveRecord::Migration
	def change
		create_table :comments
		add_column :comments, :user_id, :integer
		add_column :comments, :body, :string
		add_column :comments, :recipe_id, :integer
		add_column :comments, :created_at, :datetime
		add_column :comments, :updated_at, :datetime
	end
end