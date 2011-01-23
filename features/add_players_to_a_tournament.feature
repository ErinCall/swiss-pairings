Feature: Add players to a tournament
  As a tournament coordinator
  I need to add players to my tournaments
  So that I can generate their pairings

  Scenario: Add a player
    Given a tournament exists with name: "Sealed"
    And I am on the tournament's page
    When I fill in "Name" with "Drew"
    And I press "Add Player"
    Then "Drew" should be listed as a player
