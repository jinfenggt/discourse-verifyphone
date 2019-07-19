# frozen_string_literal: true

# name: phone verify

enabled_site_setting :verifycode_enabled

after_initialize do
  load File.expand_path('../app/controllers/verifycode.rb', __FILE__)

  Discourse::Application.routes.append do
    get '/verify' => 'verifycode#index'
    get '/verifycode' => 'verifycode#get'
    post '/verifycode' => 'verifycode#verify'
  end
end
