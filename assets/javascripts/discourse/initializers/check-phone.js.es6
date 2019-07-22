export default {
  name: 'check-phone',
  initialize(container) {
    const user = container.lookup('current-user:main');
    console.log(user)
    if (window.location.href.substr(0, 7) == '/verify') return
    if (user && !user.admin && user.custom_fields && !user.custom_fields.phone) {
      window.location = '/verify'
    }
  }
}