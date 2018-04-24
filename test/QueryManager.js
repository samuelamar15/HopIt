const QueryManager = artifacts.require("../contracts/QueryManager");
const Token = artifacts.require("../contracts/Token");
const Answer = artifacts.require("../contracts/Answer");

async function deployAnswer(queryManagerInst, tokenInst, queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID){

  //// TODO: add token allowance here and make sure the querier sends to funds to the contract answer
  await queryManagerInst.deployAnswer(queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID);
  let answerAddr = await queryManagerInst.getQueryAnswerAddress(queryHash, answerID);
  let answerInst = Answer.at(answerAddr)

  return answerInst;
}

contract('QueryManager test', async (accounts) => {
  let tokenInst;
  let queryManagerInst;

  beforeEach("Getting deployed Instances", async () => {
    tokenInst = await Token.deployed();
    queryManagerInst = await QueryManager.deployed();
  });

  it("The token address is the one we deployed", async () => {
     let tokenAddress = await queryManagerInst.getTokenAddress.call();
     assert.equal(tokenAddress, tokenInst.address);
  });

  it("We are the owner of the query manager", async () => {
    let owner = await queryManagerInst.owner();
     assert.equal(accounts[0], owner);
  });

  it("Adding a query to the system", async () => {
    let queryHash = 1;
    let queryPrice = 100;
    await queryManagerInst.addQuery(queryHash, queryPrice);
    let result = await queryManagerInst.getQueryData(queryHash);

     assert.equal(result[1], queryPrice);
  });

  it("Adding a seconde query to the system", async () => {
    let queryHash = 2;
    let queryPrice = 200;
    await queryManagerInst.addQuery(queryHash, queryPrice);
    let result = await queryManagerInst.getQueryData(queryHash);

     assert.equal(result[1], queryPrice);
  });

  it("Deploying an answer without refferal", async () => {
    let queryHash = 1;
    let replier = accounts[1];
    let referrer = "0x0";
    let disputeTime = 100;
    let price = 1000;
    let encryptedAnswerHash = 123456789;
    let answerID = 3;

    let answerInst = await deployAnswer(queryManagerInst, queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID);
    let retrivedAnswerHash = await answerInst.getAnswerHash();
    assert.equal(retrivedAnswerHash, encryptedAnswerHash);

    let retrievedPrice = await answerInst.getPrice();
    assert(retrievedPrice, price);
  });

  it("Deploying an answer with refferal", async () => {
    let queryHash = 1;
    let replier = accounts[1];
    let referrer = accounts[2];
    let disputeTime = 100;
    let price = 1000;
    let encryptedAnswerHash = 1234567890;
    let answerID = 4;

    let answerInst = await deployAnswer(queryManagerInst, tokenInst, queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID);
    let retrivedAnswerHash = await answerInst.getAnswerHash();
    assert.equal(retrivedAnswerHash, encryptedAnswerHash);

    let retrievedPrice = await answerInst.getPrice();
    assert(retrievedPrice, price);
  });

});
