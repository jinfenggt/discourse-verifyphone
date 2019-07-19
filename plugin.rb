# frozen_string_literal: true

# name: phone verify

enabled_site_setting :verifycode_enabled

after_initialize do
  Discourse::Application.routes.append do
    get '/verifycode' => 'verifycode#get'
    post 'verifycode' => 'verifycode#verify'
  end
end
