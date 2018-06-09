
pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Token.sol";

contract Answer is Ownable {
    // The replier to the answer
    address public replier;

    // The last referrer of the address if he exists
    address public referrer;

    // HopIt Admin
    address public admin;

    // The address of the Koin token
    address public token;

    // The amount of time the querier has to opn a dispute
    uint public disputeTime;

    // A timestemp for the end of the dispute period
    uint256 public disputeEndTimestamp;

    // The amount of tokens the question costs
    uint public price;

    // The encrypted answer hash
    bytes32 public encryptedAnswerHash;

    // A flag for the dispute mode
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

    // Tells the server the answer was payed and it should send the querier the encrypted Answer.
    event AnswerStarted(uint disputeEndTimestamp);

    // Tells the server a dispute has been started.
    event DisputeStarted();

    // Tells the server a dispute has been approved.
    event DisputeApproved();

    // Tells the server a dispute has been declined.
    event DisputeDecliend();

    // Tells the server answer fees were sent to the replier and refferer.
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

    /*
        @dev starts a dispute by the querier, only during a valid dispute time
    */
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

    /*
        @dev transfers funds to the replier and the reffer (if he exists) for a valid reply.
    */
    function redeemAnswerFee() answerWasPaid disputeIsOver public {
      redeemAnswerFeeInternal();

      emit AnswerFeeRedeemed();
  }
    /*
        @dev Admin aproves a dispute and returns the funds to the querier
    */
    function approveDispute() currentlyInDispute onlyAdmin public {
        Token tokenInst = Token(token);
        uint balance = tokenInst.balanceOf(this);
        tokenInst.transfer(owner, balance);

        emit DisputeApproved();
    }

    /*
        @dev Admin declines a dispute and returns the funds to the replier and refferer
    */
    function declineDispute() currentlyInDispute onlyAdmin public {
        redeemAnswerFeeInternal();

        emit DisputeDecliend();
    }
}
