pragma solidity ^0.4.8;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


/*
  HopIt ERC20 Token.
*/

contract Token is StandardToken, Ownable {

    string public name = "KOIN";
    string public symbol = "KOIN";
    uint public decimals = 18;
    uint256 public totalSupply = 756*(10**6) * (10**18) ; //756,000,000;

    constructor() public {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    /*
        Standard Token functional
    */
    function transfer(address _to, uint _value) public returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        return super.approve(_spender, _value);
    }
}
