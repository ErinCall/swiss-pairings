Feature: Display tournaments
  As a tournament coordinator
  I need to be able to see past tournaments

  Scenario: list of no tournaments
    Given I am on the tournaments page
    Then I should see "Tournaments"

  Scenario: List with tournaments
    Given a tournament exists with name: "Sealed"
    And a tournament exists with name: "Invitational"
    And I am on the tournaments page
    Then I should see "Tournaments"
    And I should see "Sealed"
    And I should see "Invitational"

  Scenario: Drill into a tournament
    Given a tournament exists with name: "Sealed"
    And I am on the tournaments page
    When I follow "Sealed"
    Then I should be on the tournament's page

  Scenario: See how many players are in a tournament
    Given a tournament exists
    And the following players are signed up for the tournament
      | name |
      | Drew |
      | Kane |
    And I am on the tournaments page
    Then I should see "(2 players)"

  Scenario: Tournaments with one player should use the singular 'player'
    Given a tournament exists
    And the following players are signed up for the tournament
      | name |
      | Kane |
    And I am on the tournaments page
    Then I should see "(1 player)"

  Scenario: Tournaments that have started should list the complete and total number of rounds
    Given a tournament exists with current_round: 2, total_rounds: 3
    And I am on the tournaments page
    Then I should see "; 2 of 3 rounds complete)"
