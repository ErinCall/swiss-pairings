Feature: generate matches
  As a tournament organizer
  I need to generate matches
  So that my players know who to play

  Scenario: generate matches in the first round
    Given a tournament exists
    And the following players are signed up for the tournament
      | name  |
      | Drew  |
      | Ben   |
      | Mark  |
      | Scott |
    And I am on the tournament's page
    When I press "Start Tournament"
    Then it should be round 1 of 2
    And I should see 2 matches

  Scenario: generate matches in the first round with less than two players
    Given a tournament exists
    And I am on the tournament's page
    When I press "Start Tournament"
    Then I should see "Can't start a tournament with less than 2 players"

  Scenario: generate matches in the first round with an odd number of players
    Given a tournament exists
    And the following players are signed up for the tournament
      | name |
      | Drew |
      | Ben  |
      | Mark |
    And I am on the tournament's page
    When I press "Start Tournament"
    Then it should be round 1 of 2
    And I should see 2 matches
    And I should see a bye

  Scenario: generate matches after the first round
    Given a tournament exists with current_round: 1, total_rounds: 2
    And the following players are signed up for the tournament
      | name  |
      | Drew  |
      | Ben   |
      | Mark  |
      | Scott |
    And the matches for round 1 are
      | player 1 | player 2 | player 1 wins | player 2 wins | draws | 
      | Drew     | Ben      | 2             | 0             | 0     | 
      | Scott    | Mark     | 2             | 0             | 0     | 
    And I am on the tournament's page
    When I press "Start Next Round"
    Then "Drew" should be matched with "Scott"
    And "Mark" should be matched with "Ben"

  Scenario: can't generate matches after the tournament is complete
    Given a tournament exists with current_round: 1, total_rounds: 1
    And the following players are signed up for the tournament
      | name |
      | Drew |
      | Ben  |
    And the matches for round 1 are
      | player 1 | player 2 | player 1 wins | player 2 wins | draws | 
      | Drew     | Ben      | 2             | 0             | 0     |
    When I am on the tournament's page
    Then there should not be a button for "Start Next Round"
