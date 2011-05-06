Feature: See tournament standings
  As a tournament organizer
  I need to see the results of the tournament
  So that I can hand out those sweet sweet packs

  Scenario: standings for a two-player tournament
    Given a tournament exists with current_round: 1, total_rounds: 1
    And the following players are signed up for the tournament
      | name  |
      | Drew  |
      | Ben   |
    And the matches for round 1 are
      | player 1 | player 2 | player 1 wins | player 2 wins | draws |
      | Drew     | Ben      | 2             | 0             | 0     |
    And I am on the tournament's page
    Then I should see "Results"
    And I should see "Drew"
    And I should see "Ben"
