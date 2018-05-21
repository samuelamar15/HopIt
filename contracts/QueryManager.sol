pragma solidity ^0.4.17;

import "./Answer.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract QueryManager is Ownable {
  address token;

  //query hash to QueryObject
  //the query hash is constructed by a hash on the queriers address and the query text itself,
  //perhaps will add a nonce too later.
  mapping(bytes32 => Query) queries;

  struct Query {
    address querier;
    uint requestedPrice;
    mapping(bytes => address) answers;
  }


  modifier answerDoesnotExists(bytes32 _queryHash, bytes _answerID) {
      require(queries[_queryHash].answers[_answerID] == address(0));
      _;
  }

  modifier queryDoesnotExist(bytes32 _queryHash) {
      require(queries[_queryHash].querier == address(0));
      _;
  }

  modifier queryExists(bytes32 _queryHash) {
      require(queries[_queryHash].querier != address(0));
      _;
  }

  modifier isQueryOwner(bytes32 _queryHash) {
      require(msg.sender == queries[_queryHash].querier);
      _;
  }

  // an event that signals to the server a new query has been added
  event NewQuery(
      address querier,
      bytes32 queryHash,
      uint requestedPrice
  );

  // an event that signals to the server a new answer contract has been deployed.
  // if all data checks out, the querier will receive the answer.
  event NewAnswer(
      bytes answerID,
      bytes32 queryHash,
      bytes32 encryptedAnswerHash
  );

  function QueryManager(address _token) public {
    owner = msg.sender;
    token = _token;
  }

  function getTokenAddress() public view returns(address) {
    return token;
  }

  function addQuery(
      bytes32 _queryHash,
      uint _requestedPrice
  )
      public
      queryDoesnotExist(_queryHash)
  {
      queries[_queryHash] = Query({
          querier: msg.sender,
          requestedPrice: _requestedPrice
      });

      NewQuery(msg.sender, _queryHash, _requestedPrice);
  }

  function getQueryData(bytes32 _queryHash) public view returns(address, uint) {
      return (queries[_queryHash].querier, queries[_queryHash].requestedPrice);
  }

  function getQueryAnswerAddress(
      bytes32 _queryHash,
      bytes _answerID
  )
      public
      view
      queryExists(_queryHash)
      returns(address)
  {
      return (queries[_queryHash].answers[_answerID]);
  }

  //this will create a new answer for the query
  function deployAnswer(
      bytes32 _queryHash,
      address _replier,
      address _referrer,
      uint _disputeTime,
      uint _price,
      bytes32 _encryptedAnswerHash,

      // the ID received from the server the way it is logged on it
      bytes _answerID
  )
      public
      isQueryOwner(_queryHash)
      answerDoesnotExists(_queryHash, _answerID)
  {
      address newAnswer = new Answer(_replier, msg.sender, _referrer, owner, token, _disputeTime, _price, _encryptedAnswerHash);
      queries[_queryHash].answers[_answerID] = newAnswer;
      Token tokenInst = Token(token);
      tokenInst.transferFrom(msg.sender, newAnswer, _price);


      NewAnswer(_answerID, _queryHash, _encryptedAnswerHash);
  }
}
