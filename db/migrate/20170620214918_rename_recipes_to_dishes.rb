class RenameRecipesToDishes < ActiveRecord::Migration
  def change
    rename_table :recipes, :dishes
    rename_column :app_events, :recipe_id, :dish_id
    rename_column :comments, :recipe_id, :dish_id
    rename_column :user_reactions, :recipe_id, :dish_id
  end
end
