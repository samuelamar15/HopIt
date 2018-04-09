
pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Token.sol";

contract Answer is Ownable {
  address replier;
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

  // an event that tells the server the answer was payed and it should send the querier the encrypted Answer.
  event ANSWER_STARTED(uint disputeEndTimestamp);


  function Answer(address _replier, address _querier, address _token, uint _disputeTime,
                  uint _price, uint256 _encryptedAnswerHash) public {
      owner = _querier;
      replier = _replier;
      token = _token;
      disputeTime = _disputeTime;
      price = _price;
      encryptedAnswerHash = _encryptedAnswerHash;
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

  function redeemAnswerFee() answerWasPaid() disputeIsOver() public {
      Token tokenObj = Token(token);
      tokenObj.transfer(replier, tokenObj.balanceOf(this));
  }


  function startAnswerProcess() public {
      Token tokenObj = Token(token);
      tokenObj.transferFrom(owner, this, price);
      disputeEndTimestamp = block.timestamp + disputeTime;

      ANSWER_STARTED(disputeEndTimestamp);
  }
}
