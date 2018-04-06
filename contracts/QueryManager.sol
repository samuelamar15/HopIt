pragma solidity ^0.4.17;

import "./Answer.sol";

contract QueryManager {
  address owner = msg.sender;
  address token;

  //query ID to QueryObject
  mapping(uint => Query) queries;

  struct Query {
    address querier;
    uint256 queryHash;
    uint requestedPrice;
    mapping(uint => address) answers;
  }

  function QueryManager(address _token) public {
    token = _token;
  }

  function addQuery(uint _queryID, uint256 _queryHash, uint _requestedPrice) public
    isOwner(msg.sender) {
      require(queries[_queryID].querier == address(0x0));
      queries[_queryID] = Query({
          querier: msg.sender,
          queryHash: _queryHash,
          requestedPrice: _requestedPrice
      });
  }

  function getQueryData(uint _queryID) public view returns(address, uint256, uint) {
      require(queries[_queryID].querier != address(0x0));

      return (queries[_queryID].querier, queries[_queryID].queryHash, queries[_queryID].requestedPrice);
  }

  function getQueryAnswerAddress(uint _queryID, uint _answerID)  public view returns(address) {
      require(queries[_queryID].querier != address(0x0));

      return (queries[_queryID].answers[_answerID]);
  }

  //this will create a new answer for the query
  function answerQuery(
      address _replier,
      address _querier,
      uint _disputeTime,
      uint _price,
      uint256 _encryptedAnswerHash,
      uint _answerID,
      uint _queryID)
      public
      isOwner(msg.sender)
  {
      require(queries[_queryID].answers[_answerID] == address(0x0));

      Answer newAnswer = new Answer(_replier, _querier, _disputeTime, _price, _encryptedAnswerHash);
      queries[_queryID].answers[_answerID] = newAnswer;
  }

  modifier isOwner(address _account){
      require(owner == _account);
      _;
  }
}
