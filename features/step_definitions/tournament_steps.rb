Then /^"([^"]*)" should be listed as a player$/ do |player|
  page.should have_css('ol#players li', text: player)
end
