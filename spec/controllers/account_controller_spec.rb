require 'rails_helper'

describe AccountController do
  describe "POST #register" do
    it "creates a new member" do
      post :register, {
        first_name: "Kimberlea", 
        last_name: "Walters",
        email: "kimberlea.walters@gmail.com",
        password: "Albertha4"
      }
      resp = JSON.parse(response.body)
      # load the user
      user = User.find(resp['data']['id'])
      # test if user with response id was created
      expect(user).not_to be_nil
      # test if new user has email above
      expect(user.email).to eq("kimberlea.walters@gmail.com")
      # test if new user has first name above
      expect(user.first_name).to eq("Kimberlea")
      # test if logged in
      expect(session[:user_id].to_i).to eq(user.id)
    end
  end

  describe "GET #login" do
    it "signs a member into their account" do
      user = create(:user)
      post :login, {
        email: user.email,
        password: "testpassword"
      }

      resp = JSON.parse(response.body)
      # test if logged in
      expect(session[:user_id].to_i).to eq(user.id)
    end
  end
end




