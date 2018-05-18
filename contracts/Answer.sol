
pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Token.sol";

contract Answer is Ownable {
    address public replier;
    address public referrer = address(0);
    address public admin;
    address public token;
    uint public disputeTime;
    // potential security issue with this. needs checking
    uint256 public disputeEndTimestamp;
    uint public price;
    uint256 public encryptedAnswerHash;
    bool public isInDispute = true;

  modifier answerWasPaid() {
    Token tokenObj = Token(token);
    require(tokenObj.balanceOf(this) >= price);
    _;
  }

  modifier disputeIsOver() {
    require(block.timestamp > disputeEndTimestamp || !isInDispute);
    _;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  // an event that tells the server the answer was payed and it should send the querier the encrypted Answer.
  event AnswerStarted(uint disputeEndTimestamp);


  function Answer(
    address _replier,
    address _querier,
    address _referrer,
    address _admin,
    address _token,
    uint _disputeTime,
    uint _price,
    uint256 _encryptedAnswerHash
  )
    public
  {
      replier = _replier;
      owner = _querier;
      referrer = _referrer;
      admin = _admin;
      token = _token;
      disputeTime = _disputeTime;
      price = _price;
      encryptedAnswerHash = _encryptedAnswerHash;
      disputeEndTimestamp = block.timestamp + disputeTime;

      AnswerStarted(disputeEndTimestamp);
  }

  function getReplier() public view returns(address) {
      return replier;
  }

  function getReferrer() public view returns(address) {
      return referrer;
  }

  function getQuerier() public view returns(address) {
      return owner;
  }

  function getAdmin() public view returns(address) {
      return admin;
  }

  function getToken() public view returns(address) {
      return token;
  }

  function getDisputeTime() public view returns(uint) {
      return disputeTime;
  }

  function getPrice() public view returns(uint) {
      return price;
  }

  function getAnswerHash() public view returns(uint256){
      return encryptedAnswerHash;
  }

  function startDispute() onlyOwner() public {
      isInDispute = true;
  }

  function resolveDispute() onlyOwner() public {
      isInDispute = false;
  }

  function redeemAnswerFee()
    answerWasPaid()
    disputeIsOver()
    public
  {
      Token tokenObj = Token(token);
      uint balance = tokenObj.balanceOf(this);
      if (referrer != address(0)){
          tokenObj.transfer(replier, (9*balance)/10);
          tokenObj.transfer(referrer, balance/10);
      } else {
          tokenObj.transfer(replier, balance);
      }
  }

  function confiscateFunds()
    onlyAdmin()
    public
  {
    require(isInDispute);

    Token tokenInst = Token(token);
    uint balance = tokenInst.balanceOf(this);
    tokenInst.transfer(admin, balance);
  }
}
