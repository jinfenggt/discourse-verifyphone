export default {
  name: 'check-phone',
  initialize(container) {
    const user = container.lookup('current-user:main');
    console.log(user)
  }
}