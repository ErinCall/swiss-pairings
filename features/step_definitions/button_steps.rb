Then /^there should be a button for "([^"]*)"$/ do |text|
  page.should have_css("input[type='submit'][value='#{text}']")
end

Then /^there should not be a button for "([^"]*)"$/ do |text|
  page.should have_no_css("input[type='submit'][value='#{text}']")
end
