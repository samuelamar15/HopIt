pragma solidity ^0.4.17;

import "./Answer.sol";
import "./Ownable.sol";


contract QueryManager is Ownable {
  address token;

  //query hash to QueryObject
  //the query hash is constructed by a hash on the queriers address and the query text itself,
  //perhaps will add a nonce too later.
  mapping(uint256 => Query) queries;

  struct Query {
    address querier;
    uint requestedPrice;
    mapping(uint => address) answers;
  }


  modifier answerDoesnotExists(uint256 _queryHash, uint _answerID) {
      require(queries[_queryHash].answers[_answerID] == address(0x0));
      _;
  }

  modifier queryDoesnotExist(uint256 _queryHash) {
      require(queries[_queryHash].querier == address(0x0));
      _;
  }

  modifier queryExists(uint256 _queryHash) {
      require(queries[_queryHash].querier != address(0x0));
      _;
  }

  modifier isQueryOwner(uint256 _queryHash) {
      require(msg.sender == queries[_queryHash].querier);
      _;
  }

  // an event that signals to the server a new answer contract has been deployed.
  // if all data checks out, the querier will receive the answer.
  event NEW_ANSWER(
      address contractAddress,
      address replier,
      address querier,
      address token,
      uint disputeTime,
      uint price,
      uint256 encryptedAnswerHash
  );

  function QueryManager(address _token) public {
    token = _token;
  }

  function addQuery(
      uint256 _queryHash,
      uint _requestedPrice)
      public
      queryDoesnotExist(_queryHash)
  {
      queries[_queryHash] = Query({
          querier: msg.sender,
          requestedPrice: _requestedPrice
      });
  }

  function getQueryData(uint256 _queryHash) public view returns(address, uint) {
      return (queries[_queryHash].querier, queries[_queryHash].requestedPrice);
  }

  function getQueryAnswerAddress(
      uint256 _queryHash,
      uint _answerID)
      public
      view
      queryExists(_queryHash)
      returns(address)
  {
      return (queries[_queryHash].answers[_answerID]);
  }

  //this will create a new answer for the query
  function deployAnswer(
      uint256 _queryHash,
      address _replier,
      uint _disputeTime,
      uint _price,
      uint256 _encryptedAnswerHash,

      // the ID received from the server the way it is logged on it
      uint _answerID)
      public
      isQueryOwner(_queryHash)
      answerDoesnotExists(_queryHash, _answerID)
  {
      address newAnswer = new Answer(_replier, msg.sender, token, _disputeTime, _price, _encryptedAnswerHash);
      queries[_queryHash].answers[_answerID] = newAnswer;

      emit NEW_ANSWER(newAnswer, _replier, msg.sender, token, _disputeTime, _price, _encryptedAnswerHash);
  }
}
