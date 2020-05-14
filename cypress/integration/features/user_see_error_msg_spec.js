describe("error messages", () => {
  it("when enters bad values", () => {
    cy.search(0);
    cy.get("[data-cy=msg]").contains("Invalid entries");
  });
  it("when bad status code", () => {
    cy.server();
    cy.route({
      url: "**//www.dictionaryapi.com/**",
      status: 503,
      response: {},
    }).as("search");
    cy.search("hello");
    cy.wait("@search");
    cy.get("[data-cy=msg]").contains(
      "Something's wrong with Merriam-Webster API, try later?"
    );
  });

  // it("when bad url", () => {
  //     cy.visit('/');
  //     cy.server();
  //     cy.route({url: "**//www.dictionaryapi.com/**", status : 400 , response: {}}).as('search');
  //     cy.get("[data-cy=input]").type("hello");
  //     cy.get("[data-cy=submit]").click();
  //     cy.wait("@search");
  //     cy.get("[data-cy=msg]").contains("URL invalid");
  // });

  it("when time out", () => {
    cy.server();
    cy.route({
      url: "**//www.dictionaryapi.com/**",
      delay: 3000,
      response: {},
    }).as("search");
    cy.search("hello");
    cy.wait("@search");
    cy.get("[data-cy=msg]").contains("Time out, try again?");
  });
});
