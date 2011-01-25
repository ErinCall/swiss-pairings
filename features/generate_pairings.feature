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
