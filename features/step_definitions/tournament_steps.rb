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
  page.should have_css("div#matches div:nth-child(#{matches})")
end

Then /^I should see a bye$/ do
  page.should have_css("div#matches div", text: 'BYE')
end

Given /^the matches for round (\d+) are$/ do |round, table|
  tournament = model!('tournament')

  table.hashes.each do |hash|
    Factory.create(:match,
      tournament: tournament,
      round: round,
      player_1_id: tournament.players.where(name: hash['player 1']).first.id,
      player_2_id: tournament.players.where(name: hash['player 2']).first.id
    )
  end
end

Then /^"([^"]*)" should be marked as the winner$/ do |player|
  page.should have_css('div.winner label', text: player)
end

Then /^"([^"]*)" should be marked as the loser$/ do |player|
  page.should have_css('div.loser label', text: player)
end

