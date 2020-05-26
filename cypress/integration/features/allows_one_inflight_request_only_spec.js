describe("Multiple requests", () => {
    it("cancels previous requests with the latest", () => {
        cy.server(); 
        cy.route({
            url: "**//www.dictionaryapi.com/**/apple**",
            delay: 2000,
            response: {},
          }).as("apple");
        cy.route({
            url: "**//www.dictionaryapi.com/**/add**",
            delay: 1500,
            response: {},
          }).as("add");
        cy.route({
            url: "**//www.dictionaryapi.com/**/astronaut**",
            delay: 500
          }).as("astronaut");
        cy.search("apple");
        cy.search("add");
        cy.search("astronaut");
    

        cy.wait("@apple"); 
        // cy.wait("@add"); 
        // cy.wait("@astronaut"); 

        cy.get("[data-cy=word]").contains("astronaut"); 
    })
})