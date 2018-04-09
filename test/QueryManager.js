const QueryManager = artifacts.require("../contracts/QueryManager");
const Token = artifacts.require("../contracts/Token");

contract('QueryManager test', async (accounts) => {

  it("The token address is the one we deployed", async () => {
     let tokenInstance = await Token.deployed();
     let queryManagerInstance = await QueryManager.deployed();
     let tokenAddress = await queryManagerInstance.getTokenAddress.call();
     assert.equal(tokenAddress, tokenInstance.address);
  });

});
