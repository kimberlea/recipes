### Generated by SchemaSync
class SchemaSyncCwvxh < ActiveRecord::Migration
	def change
		create_table :user_reactions
		add_column :user_reactions, :user_id, :integer
		add_column :user_reactions, :recipe_id, :integer
		add_column :user_reactions, :is_favorite, :boolean
		add_column :user_reactions, :created_at, :datetime
		add_column :user_reactions, :updated_at, :datetime
	end
end