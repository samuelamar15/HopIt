pragma solidity ^0.4.8;

import "./StandartToken.sol";
import "./Ownable.sol";


/*
  HopIt ERC20 Token.
*/

contract Token is StandardToken, Ownable {

  string public name = "KOIN";
  string public symbol = "KOIN";
  uint public decimals = 18;
  uint256 public totalSupply = 756*10**6; //756,000,000;

  function Token() public {
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
