Feature: Create a tournament
  As a tournament coordinator
  I need to be able to create a tournament
  So that I can track the pairings of my players

  Scenario: create a tournament
    Given I am on the new tournament page
    When I fill in "Name" with "SoM Sealed Deck"
    And I press "Create Tournament"
    Then I should see "Tournament was successfully created."
