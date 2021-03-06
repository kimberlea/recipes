require 'rails_helper'

describe DishesController do 
  describe "POST #save" do
    it "saves a new dish" do
      user = create(:user)
      post :save, {
        title: "Southern Cabbage",
        serving_size: "4",
        description: "Family southern cooking",
        ingredients: "bacon",
        directions: "Simmer on stove",
        prep_time_mins: "30"

      }, {
        user_id: user.id
      }

      resp = JSON.parse(response.body)
      #puts resp
      # load recipe back
      dish = Dish.find(resp['data']['id'])
      # test that recipe is not nil
      expect(dish).not_to be_nil
      # test that resp has success == true
      expect(resp['success']).to eq(true)
      # test that recipe title is right
      expect(dish.title).to eq("Southern Cabbage")
    end
  end
end
