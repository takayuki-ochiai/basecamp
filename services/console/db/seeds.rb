private_user = User.create!(
  uid: 'hogehogehogheo',
  email: '4dqcPo7mP6.private.user@gmail.com'
)

org1 = Organization.create!(name: 'Organization1')

org1_user = User.create!(
  uid: 'hogehogehogheo',
  email: '4dqcPo7mP6.organization.user@gmail.com'
)

org1_user.organizations = [org1]

PrivateCalendar.create!(
  user: private_user,
  title: 'マイカレンダー'
)

PrivateCalendar.create!(
  user: org1_user,
  title: 'マイカレンダー'
)



