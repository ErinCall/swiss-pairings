Feature: submit results
  As a tournament organizer
  I need to be able to record match results
  So I can determine the standings

  Scenario: submitting results
    Given a tournament exists with current_round: 1
    And the following players are signed up for the tournament
      | name  |
      | Drew  |
      | Mark  |
    And the matches for round 1 are
      | player 1 | player 2 |
      | Drew     | Mark     |
    When I am on the tournament's page
    And I fill in "Drew" with "2"
    And I fill in "Mark" with "1"
    And I press "Submit Results"
    Then "Drew" should be marked as the winner
    And "Mark" should be marked as the loser
