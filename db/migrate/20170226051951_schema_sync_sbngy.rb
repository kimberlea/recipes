### Generated by SchemaSync
class SchemaSyncSbngy < ActiveRecord::Migration
	def change
		add_column :users, :crypted_password, :string
		add_column :users, :password_salt, :string
		add_column :users, :persistent_token, :string
		add_column :users, :perishable_token, :string
		add_column :users, :perishable_token_exp, :datetime
	end
end