
pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Token.sol";

contract Answer is Ownable {
    address public replier;
    address public referrer = address(0);
    address public admin;
    address public token;
    uint public disputeTime;
    uint256 public disputeEndTimestamp;
    uint public price;
    bytes32 public encryptedAnswerHash;
    bool public isInDispute;

    modifier answerWasPaid() {
        Token tokenObj = Token(token);
        require(tokenObj.balanceOf(this) >= price);
        _;
    }

    modifier currentlyInDispute() {
        require(isInDispute);
        _;
    }

    modifier isInDisputePeriod() {
        require(block.timestamp < disputeEndTimestamp);
        _;
    }

    modifier disputeIsOver() {
        require(block.timestamp > disputeEndTimestamp && !isInDispute);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    // an event that tells the server the answer was payed and it should send the querier the encrypted Answer.
    event AnswerStarted(uint disputeEndTimestamp);

    event DisputeStarted();

    event DisputeApproved();

    event DisputeDecliend();

    event AnswerFeeRedeemed();


    constructor(
        address _replier,
        address _querier,
        address _referrer,
        address _admin,
        address _token,
        uint _disputeTime,
        uint _price,
        bytes32 _encryptedAnswerHash
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
        isInDispute = false;

        emit AnswerStarted(disputeEndTimestamp);
    }

    function startDispute() isInDisputePeriod onlyOwner public {
        isInDispute = true;
        
        emit DisputeStarted();
    }

    function redeemAnswerFeeInternal() internal {
        Token tokenObj = Token(token);
        uint balance = tokenObj.balanceOf(this);
        if (referrer != address(0)){
            tokenObj.transfer(replier, (9*balance)/10);
            tokenObj.transfer(referrer, balance/10);
        } else {
            tokenObj.transfer(replier, balance);
        }
    }

    function redeemAnswerFee() answerWasPaid disputeIsOver public {
      redeemAnswerFeeInternal();
      emit AnswerFeeRedeemed();
  }

    function approveDispute() currentlyInDispute onlyAdmin public {
        Token tokenInst = Token(token);
        uint balance = tokenInst.balanceOf(this);
        tokenInst.transfer(owner, balance);

        emit DisputeApproved();
    }

    function declineDispute() currentlyInDispute onlyAdmin public {
        redeemAnswerFeeInternal();
        emit DisputeDecliend();
    }
}
