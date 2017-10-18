df_config_file = File.join(Rails.root, 'config', 'dishfave.yml')
df_config_template = ERB.new(File.new(df_config_file).read).result(binding)
APP_CONFIG = YAML.load(df_config_template)[Rails.env].with_indifferent_access

Stripe.api_key = APP_CONFIG[:stripe_secret_key]
#Stripe.verify_ssl_certs = false

MailMaker.stylesheet = {
  "center" => "text-align: center;",
  "padded" => "padding: 20px;",
  "p" => "padding: 20px 0px 20px 0px;",
  "h2" => "font-size: 24px; text-align: center; padding: 20px;",
  "small" => "font-size: 12px;",
  "muted" => "color: #aaa;",
}


QuickScript::ApiEndpoints.configure("/api") do
  model_endpoints_for "Dish" do
    post '/dish/favorite', action: 'favorite_as_action!'
    post '/dishes/import_from_url', class_action: 'import_from_url_as_action!'
    get '/dishes/search',  class_action: 'search_as_action!'
  end
  model_endpoints_for "UserReaction" do
    post '/user_reactions/react', class_action: 'react_as_action!'
  end
  model_endpoints_for "Following"
  model_endpoints_for "Comment"
  model_endpoints_for "User"
  model_endpoints_for "Location"
  model_endpoints_for "Feature" do
    post '/feature/cancel', action: 'cancel_as_action!'
  end
  model_endpoints_for "Invoice"
end
