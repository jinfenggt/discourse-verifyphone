export default {
  name: 'check-phone',
  initialize(container) {
    const user = container.lookup('current-user:main');
    console.log(user)
    if (window.location.pathname == '/verify') return
    if (user && user.custom_fields && !user.custom_fields.phone) {
      window.location = '/verify'
    }
  }
}