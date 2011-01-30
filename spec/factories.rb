Factory.define :user do |u|
  u.sequence(:email) { |n| "person#{n}@example.com" }
  u.password 'password'
  u.password_confirmation 'password'
end

Factory.define :tournament do |t|
  t.sequence(:name) { |n| "Tournament #{n}" }
end

Factory.define :player do |p|
  p.association :tournament
  p.sequence(:name) { |n| "Player #{n}" }
end

Factory.define :match do |m|
  m.association :tournament
  m.player_1 { |i| Factory.build(:player, tournament: i.tournament) }
  m.player_2 { |i| Factory.build(:player, tournament: i.tournament) }
end
