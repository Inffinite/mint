// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Wife {
  uint public wifeMoney;

  constructor(){
    wifeMoney = 23;
  }

  function set(uint x) public {
    wifeMoney = x;
  }

  function get() public view returns (uint){
    return wifeMoney;
  }
}
