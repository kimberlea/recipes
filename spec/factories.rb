FactoryGirl.define do

  factory :user do
    first_name { Faker::Name.unique.first_name }
    last_name { Faker::Name.unique.last_name }
    email { "#{first_name}.#{last_name}@example.com".downcase }
    password "testpassword"
  end

end