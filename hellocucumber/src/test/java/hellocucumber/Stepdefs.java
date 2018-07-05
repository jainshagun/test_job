package hellocucumber;

import cucumber.api.PendingException;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;
import cucumber.api.java.en.Then;
import static org.junit.Assert.*;
import io.restassured.RestAssured;
import io.restassured.http.Method;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import io.restassured.*;

public class Stepdefs {
	
	private Response response = RestAssured.get("http://localhost:9999");
	
	@When("^I go to the homepage$")
		public void i_go_to_the_homepage() throws Exception {
		// Write code here that turns the phrase above into concrete actions
		//throw new PendingException();
	}

	@Then("^I receives status code of (\\d+)$")
		public void i_receives_status_code_of(int statusCode) throws Exception {
		// Write code here that turns the phrase above into concrete actions
		//throw new PendingException();
		assertEquals(response.getStatusCode(), statusCode);
	}

	@Then("^I should see the message \"([^\"]*)\"$")
		public void i_should_see_the_message(String version) throws Exception {
		// Write code here that turns the phrase above into concrete actions
		//throw new PendingException();
		assertEquals(response.asString(), version);
	}
}