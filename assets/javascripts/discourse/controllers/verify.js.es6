import { ajax } from "discourse/lib/ajax";

import DiscourseURL from "discourse/lib/url";

import User from "discourse/models/user";

import {
  default as computed
} from "ember-addons/ember-computed-decorators";

export default Ember.Controller.extend({

  errorMessage: null,
  infoMessage: null,
  phoneverify: {
    phone: '',
    code: ''
  },
  sendDisable: false,
  timer: null,
  count: 30,
  btnText: '发送验证码',

  @computed()
  username() {
    return User.currentProp("username").toLowerCase();
  },

  init() {
    this._super();
  },
  actions: {
    counter() {
      if (this.count > 0) {
        this.count --;
        // this.set('count', this.count - 1);
        this.set('btnText', this.count)
      } else {
        this.set('sendDisable', false);
        this.set('btnText', '发送验证码')
      }
      this.timer = setTimeout(() => {
        this.counter()
      }, 1000)
    },
    timerInterval() {
      if (this.timer) {
        clearTimeout(this.timer)
        this.timer = null
      }
      this.set('btnText', this.count)
      this.timer = setTimeout(() => {
        this.counter()
      }, 1000)
    },
    sendVerifyCode() {
      let phone = this.phoneverify && this.phoneverify.phone ? this.phoneverify.phone : ''
      phone = phone.trim()
      if (!phone) return
      // this.sendDisable = true
      this.set('sendDisable', true)
      ajax('/verifycode?phone=' + phone, { type: 'GET' }).then(() => {
        this.set("infoMessage", "发送验证码成功");
        this.set("errorMessage", null);
        this.timerInterval();
      }).catch(e => {
        console.log(e)
        this.set('sendDisable', false)
        if (e.jqXHR && e.jqXHR.status === 429) {
          this.set("errorMessage", I18n.t("user.second_factor.rate_limit"));
        } else {
          this.set("errorMessage", "System error");
        }
        this.set("infoMessage", null);
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
          this.set("errorMessage", "System Error");
        }
      })
    }
  }
})