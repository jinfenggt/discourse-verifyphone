require_dependency 'final_destination'

class VerifycodeController < ApplicationController
  def index
  end
  def get
    phone = params[:phone]
    now = Date.today.to_time.to_i
    Rails.logger.info 'Called verifycode#get'
    Rails.logger.info 'verifyphone: ' + phone
    Rails.logger.info 'verifynow: ' + now
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
    Rails.logger.info 'Called verifycode#verify'
    Rails.logger.info 'verifyphone: ' + phone
    Rails.logger.info 'verify code: ' + code
    phonecode = PluginStore.get('verifycode', phone)
    now = Date.today.to_time.to_i
    unless phonecode && phonecode[:code] == code && now < phonecode.expiredAt
      render json: success_json
    end
    render json: failed_json, status: 400
  end
end