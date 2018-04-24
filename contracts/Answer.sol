
pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Token.sol";

contract Answer is Ownable {
  address replier;
  address referrer = address(0);
  address admin;
  address token;
  uint disputeTime;
  // potential security issue with this. needs checking
  uint256 disputeEndTimestamp = 2 ** 256 - 1;
  uint price;
  uint256 encryptedAnswerHash;
  bool isInDispute = false;

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
  event ANSWER_STARTED(uint disputeEndTimestamp);


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

      startAnswerProcess();
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

  function startAnswerProcess() internal {
      Token tokenInst = Token(token);
      tokenInst.transferFrom(owner, this, price);
      disputeEndTimestamp = block.timestamp + disputeTime;

      ANSWER_STARTED(disputeEndTimestamp);
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
