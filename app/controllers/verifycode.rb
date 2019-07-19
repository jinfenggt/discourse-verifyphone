require_dependency 'final_destination'

class VerifycodeController < ApplicationController
  def get
    phone = params[:phone]
    now = Date.today.to_time.to_i
    phonecode = {
      phone => phone,
      code => '11111',
      expiredAt => now + 600
    }
    PluginStore.set('verifycode', phone, phonecode)
    render json: success_json
  end
  def verify
    phone = params[:phone]
    code = params[:code]
    phonecode = PluginStore.get('verifycode', phone)
    now = Date.today.to_time.to_i
    unless phonecode && phonecode[:code] == code && now < phonecode.expiredAt
      render json: success_json
    end
    render json: failed_json, status: 400
  end
end