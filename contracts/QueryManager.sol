pragma solidity ^0.4.17;

import "./Answer.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/// @dev Main Hopit Contract.
contract QueryManager is Ownable {

    struct Query {
        // The Address of the querys querier
        address querier;

        // The amount of koin the querier bids
        uint requestedPrice;

        // A map between the calculated query hash and the address of the deployed answer contract
        mapping(bytes => address) answers;
    }

    // The address of the Koin Token
    address token;

    // query hash to QueryObject
    // the query hash is constructed by a hash on the queriers address and the query text itself
    mapping(bytes32 => Query) queries;


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

    constructor(address _token) public {
        owner = msg.sender;
        token = _token;
    }

    /*
        @dev returns the token address
    */
    function getTokenAddress() public view returns(address) {
        return token;
    }

    /*
        @dev adds a query to the system
        @param _queryHash is the calculated query hash as is saved in the DB
        @param _requestedPrice is the bid the querier makes for an answer
    */
    function addQuery(bytes32 _queryHash, uint _requestedPrice)
        queryDoesnotExist(_queryHash)
        public
    {
        queries[_queryHash] = Query({
            querier: msg.sender,
            requestedPrice: _requestedPrice
        });

        emit NewQuery(msg.sender, _queryHash, _requestedPrice);
    }

    /*
        @dev returns the requested price and the address of the querier
        @param _queryHash is the calculated query hash as is saved in the DB and mapping
    */
    function getQueryData(bytes32 _queryHash)
        public
        view
        returns(address, uint)
    {
        return (queries[_queryHash].querier, queries[_queryHash].requestedPrice);
    }

    /*
        @dev returns for a query representerd by the queryHash and the according
             answer represented by answerID, the answers contract address
        @param _queryHash is the calculated query hash as is saved in the DB and mapping
        @param _answerID is the answer ID as saved in the HopIt DB
    */
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


    /*
        @dev deployes a new answer contract to the system for the specified query
             and transfers the funds to it. This functions assumes the querier has
             has granted an allowes the size of _price for koin tokens to this contract
        @param _queryHash is the calculated query hash as is saved in the DB and mapping
        @param _replier the address of the creator of the answer
        @param _referrer the last referre of this query if there is one
        @param _disputeTime The amount of time the querier has to opn a dispute
        @param _price The amount of tokens the question costs
        @param _encryptedAnswerHash The hash of the answers body after encryption
        @param _answerID The ID of this answer as represented in HopIt DB
    */
    function deployAnswer(
        bytes32 _queryHash,
        address _replier,
        address _referrer,
        uint _disputeTime,
        uint _price,
        bytes32 _encryptedAnswerHash,
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

        emit NewAnswer(_answerID, _queryHash, _encryptedAnswerHash);
    }
}
