Given /^I am not logged in$/ do
  Given %{I am on the destroy user session page}
end

Given /^I am a logged in user$/ do
  user = Factory.create(:user)

  Given %{I am on the new user session page}
  And %{I fill in "Email" with "#{user.email}"}
  And %{I fill in "Password" with "#{user.password}"}
  And %{I press "Sign in"}
end
