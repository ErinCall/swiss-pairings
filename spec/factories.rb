Factory.define :user do |u|
  u.sequence(:email) { |n| "person#{n}@example.com" }
  u.password 'password'
  u.password_confirmation 'password'
end

Factory.define :tournament do |t|
  t.sequence(:name) { |n| "Tournament #{n}" }
end

Factory.define :player do |p|
  p.sequence(:name) { |n| "Player #{n}" }
end

Factory.define :match do |p|
end
