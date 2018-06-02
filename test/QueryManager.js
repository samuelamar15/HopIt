const QueryManager = artifacts.require("../contracts/QueryManager");
const Token = artifacts.require("../contracts/Token");
const Answer = artifacts.require("../contracts/Answer");

const readline = require('readline');
const sleep = require('sleep');

async function deployAnswer(queryManagerInst, tokenInst, queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID){
  await tokenInst.approve(queryManagerInst.address, price);
  await queryManagerInst.deployAnswer(queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID);
  let answerAddr = await queryManagerInst.getQueryAnswerAddress(queryHash, answerID);
  let answerInst = Answer.at(answerAddr)

  return answerInst;
}

contract('QueryManager test', async (accounts) => {
  let tokenInst;
  let queryManagerInst;

  before("Getting deployed Instances", async () => {
    tokenInst = await Token.deployed();
    queryManagerInst = await QueryManager.deployed();

    //for the purpose of testing the server and updationg the address that has been localy deployed
    //sleep.sleep(15);
  });

  // beforeEach("Getting deployed Instances", async () => {
  //   tokenInst = await Token.deployed();
  //   queryManagerInst = await QueryManager.deployed();
  // });

  it("The token address is the one we deployed", async () => {
     let tokenAddress = await queryManagerInst.getTokenAddress.call();
     assert.equal(tokenAddress, tokenInst.address);
  });

  it("We are the owner of the query manager", async () => {
    let owner = await queryManagerInst.owner();
     assert.equal(accounts[0], owner);
  });

  it("Adding a query to the system", async () => {
    let queryHash = web3.sha3("a1");
    let queryPrice = 100;
    await queryManagerInst.addQuery(queryHash, queryPrice);
    let result = await queryManagerInst.getQueryData(queryHash);

     assert.equal(result[1], queryPrice);
  });

  it("Adding a seconde query to the system", async () => {
    let queryHash = web3.sha3("b2");
    let queryPrice = 200;
    await queryManagerInst.addQuery(queryHash, queryPrice);
    let result = await queryManagerInst.getQueryData(queryHash);

     assert.equal(result[1], queryPrice);
  });

  it("Deploying an answer without refferal", async () => {
    let queryHash = web3.sha3("a1");
    let replier = accounts[1];
    let referrer = "0x0";
    let disputeTime = 100;
    let price = 1000;
    let encryptedAnswerHash = web3.sha3("c3");
    let answerID = "cc3";

    let querierBalanceBefore = await tokenInst.balanceOf(accounts[0]);
    let replierBalanceBefore = await tokenInst.balanceOf(replier);

    //TODO: add event listeners for new answer deployment and answer started
    let answerInst = await deployAnswer(queryManagerInst, tokenInst, queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID);

    let retrievedDisputeTime = await answerInst.disputeTime();
    assert.equal(retrievedDisputeTime, disputeTime);

    let retrivedAnswerHash = await answerInst.encryptedAnswerHash();
    assert.equal(retrivedAnswerHash, encryptedAnswerHash);

    let retrievedPrice = await answerInst.price();
    assert.equal(retrievedPrice, price);

    let retrievedAnswerAddress = await queryManagerInst.getQueryAnswerAddress(queryHash, answerID);
    assert.equal(retrievedAnswerAddress, answerInst.address);

    //Test the answer fee can be redeemed
    await answerInst.startDispute();
    await answerInst.declineDispute();

    let querierBalanceAfter = await tokenInst.balanceOf(accounts[0]);
    let replierBalanceAfter = await tokenInst.balanceOf(replier);

    assert.equal(querierBalanceAfter.toNumber() + price, querierBalanceBefore.toNumber());
    assert.equal(replierBalanceAfter.toNumber() - price, replierBalanceBefore.toNumber());
  });

  it("Deploying an answer with refferal", async () => {
    let queryHash = web3.sha3("a1");
    let replier = accounts[1];
    let referrer = accounts[2];
    let disputeTime = 100;
    let price = 1000;
    let encryptedAnswerHash = web3.sha3("d4");
    let answerID = "dd4";

    let querierBalanceBefore = await tokenInst.balanceOf(accounts[0]);
    let replierBalanceBefore = await tokenInst.balanceOf(replier);
    let referrerBalanceBefore = await tokenInst.balanceOf(referrer);

    let answerInst = await deployAnswer(queryManagerInst, tokenInst, queryHash, replier, referrer, disputeTime, price, encryptedAnswerHash, answerID);

    let retrievedDisputeTime = await answerInst.disputeTime();
    assert.equal(retrievedDisputeTime, disputeTime);

    let retrivedAnswerHash = await answerInst.encryptedAnswerHash();
    assert.equal(retrivedAnswerHash, encryptedAnswerHash);

    let retrievedPrice = await answerInst.price();
    assert.equal(retrievedPrice, price);

    let retrievedAnswerAddress = await queryManagerInst.getQueryAnswerAddress(queryHash, answerID);
    assert.equal(retrievedAnswerAddress, answerInst.address);

    //Test the answer fee can be redeemed with refferer
    await answerInst.startDispute();
    await answerInst.declineDispute();

    let querierBalanceAfter = await tokenInst.balanceOf(accounts[0]);
    let replierBalanceAfter = await tokenInst.balanceOf(replier);
    let referrerBalanceAfter = await tokenInst.balanceOf(referrer);

    assert.equal(querierBalanceAfter.toNumber() + price, querierBalanceBefore.toNumber());
    assert.equal(replierBalanceAfter.toNumber() - price*0.9, replierBalanceBefore.toNumber());
    assert.equal(referrerBalanceAfter.toNumber() - price*0.1, referrerBalanceBefore.toNumber());
  });

});
