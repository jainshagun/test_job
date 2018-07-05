Feature: Hello World
  Scenario: User sees the Hello World message
    When I go to the homepage
	Then I receives status code of 200
    And I should see the message "Hello World!"