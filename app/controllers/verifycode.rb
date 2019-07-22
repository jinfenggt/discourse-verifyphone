require_dependency 'final_destination'

class VerifycodeController < ApplicationController
  def index
  end
  def get
    phone = params[:phone]
    now = Date.today.to_time.to_i
    Rails.logger.info 'Called verifycode#get'
    Rails.logger.info 'verifyphone: ' + phone
    Rails.logger.info now
    phonecode = { phone: phone, code: '11111', expiredAt: now + 600 }
    PluginStore.set('verifycode', phone, phonecode)
    render json: success_json
  end
  def verify
    user = fetch_user_from_params
    guardian.ensure_can_edit!(user)

    phone = params[:phone]
    code = params[:code]
    Rails.logger.info 'Called verifycode#verify'
    Rails.logger.info 'verifyphone: ' + phone
    Rails.logger.info 'verify code: ' + code
    phonecode = PluginStore.get('verifycode', phone)
    if phonecode
      Rails.logger.info 'store verify code: ' + phonecode.code
      Rails.logger.info 'store verify phone: ' + phonecode.phone
      now = Date.today.to_time.to_i
      if now < phonecode.expiredAt
        render json: { message: 'Verify Code has expired' }
      else
        updater = UserUpdater.new(current_user, user)
        updater.update({ custom_fields: { phone: phone } })
        render json: success_json
      end
    else
      render json: { message: 'Send Verify Code to Verify Phone' }
    end
  end
end