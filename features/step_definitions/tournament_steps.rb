Then /^"([^"]*)" should be listed as a player$/ do |player|
  page.should have_css('ol#players li', text: player)
end

Given /^the following players are signed up for the tournament$/ do |table|
  table.hashes.each do |hash|
    Factory.create(:player, name: hash['name'], tournament: model!('tournament'))
  end
end

Then /^it should be round (\d+) of (\d+)$/ do |round, total_rounds|
  page.should have_content("Round #{round} of #{total_rounds}")
end

Then /^I should see (\d+) matches/ do |matches|
  page.should have_css("table#matches tbody tr:nth-child(#{matches})")
end

Then /^I should see a bye$/ do
  page.should have_css("table#matches tbody", text: 'BYE')
end
