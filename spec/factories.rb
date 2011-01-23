Factory.define :user do |u|
  u.sequence(:email) { |n| "person#{n}@example.com" }
  u.password 'password'
  u.password_confirmation 'password'
end
