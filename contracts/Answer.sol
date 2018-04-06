
pragma solidity ^0.4.17;

contract Answer {
  address replier;
  address querier;
  uint disputeTime;
  uint price;
  uint256 encryptedAnswerHash;
  bool isInDispute = false;

  function Answer(address _replier, address _querier, uint _disputeTime,
                  uint _price, uint256 _encryptedAnswerHash) public {
      replier = _replier;
      querier = _querier;
      disputeTime = _disputeTime;
      price = _price;
      encryptedAnswerHash = _encryptedAnswerHash;

  }

  function getPrice() public {

  }
  function getAnswerHash() public{}
  function openDispute() public{}
  function redeemAnswerFee() public{}
  function startAnswerProcess() public payable{}
  //this is a function the server will call to make sure the user has sent the funds.
  //if the answer is yes, the contract will automaticaly start the dispute process
  //the server will be forced to send the encrypted data to the user
  function canUserRetrieveAnswer() public view returns(bool){
      return true;
  }
}
