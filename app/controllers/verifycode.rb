require_dependency 'final_destination'

require 'net/http'
require 'securerandom'
require 'uri'
require 'json'
require 'digest/md5'

class VerifycodeController < ApplicationController
  def index
  end
  def get
    phone = params[:phone]
    now = Date.today.to_time.to_i
    Rails.logger.info 'Called verifycode#get'
    Rails.logger.info 'verifyphone: ' + phone
    Rails.logger.info now
    code = rand(999999).to_s
    Rails.logger.info code
    sendCode(phone, code)
    phonecode = { phone: phone, code: code, expiredAt: now + 600 }
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
  def sendCode(phone, code)
    timestamp = Date.today.to_time.to_i.to_s
    appKey = SiteSetting.agora_sms_appkey
    secret = SiteSetting.agora_sms_appsecret
    sign = Digest::MD5.hexdigest('app_key=' + appKey + '&timestamp=' + timestamp + secret)
    uri = URI.parse("https://dove.agora.io/api/messages/sms?app_key=" + appKey + "&timestamp=" + timestamp + "&sign=" + sign)
    data = {
      uuid: SecureRandom.uuid,
      content: 'RTCDeveloper 论坛手机验证码：' + code,
      toUser: phone,
      provide: 'cn'
    }
    header = {'Content-Type': 'application/json'}
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data.to_json
    http.request(request)
  end
end