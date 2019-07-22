import { ajax } from "discourse/lib/ajax";

import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  errorMessage: null,
  phoneverify: {
    phone: '',
    code: ''
  },
  sendDisable: false,

  username: Ember.computed.alias("user.model.username_lower"),

  init() {
    this._super();
  },
  actions: {
    sendVerifyCode() {
      let phone = this.phoneverify && this.phoneverify.phone ? this.phoneverify.phone : ''
      phone = phone.trim()
      if (!phone) return
      ajax('/verifycode?phone=' + phone, { type: 'GET' }).then(() => {
        this.sendDisable = true
      }).catch(e => {
        if (e.jqXHR && e.jqXHR.status === 429) {
          this.set("errorMessage", I18n.t("user.second_factor.rate_limit"));
        } else {
          this.set("errorMessage", I18n.t("System error"));
        }
      })
    },
    verify() {
      let phone = this.phoneverify && this.phoneverify.phone ? this.phoneverify.phone : ''
      let code = this.phoneverify && this.phoneverify.code ? this.phoneverify.code : ''
      phone = phone.trim()
      code = code.trim()
      if (!phone || !code) return
      ajax('/verifycode/' + this.username, { type: 'POST', data: { phone: phone, code: code } }).then(result => {
        if (result.success) {
          DiscourseURL.redirectTo("/");
        } else {
          if (result.message) {
            this.set("errorMessage", result.message);
          }
        }
      }).catch(e => {
        if (e.jqXHR && e.jqXHR.status === 429) {
          this.set("errorMessage", I18n.t("user.second_factor.rate_limit"));
        } else {
          this.set("errorMessage", I18n.t("System error"));
        }
      })
    }
  }
})