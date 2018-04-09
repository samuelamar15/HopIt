const Token = artifacts.require("../contracts/Token");

contract('Token test', async (accounts) => {

  it("account[0] is the sole owner of all tokens", async () => {
     let instance = await Token.deployed();
     let balance = await instance.balanceOf.call(accounts[0]);
     assert.equal(balance.valueOf(), 756*(10**6));
  });

});
