export default {
  name: 'check-phone',
  initialize(container) {
    const user = container.lookup('current-user:main');
    if (user && !user.admin && user.custom_fields && !user.custom_fields.phone) {
      window.location = '/verify'
    }
  }
}