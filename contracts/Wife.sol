// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Wife {
  address public minter;
  mapping (address => uint) public balances;
  address public wifesAddress;
  event Sent(address from, address to, uint amount);

  constructor(){
    minter = msg.sender;
    wifesAddress = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
  }


  function mint(address receiver, uint amount) public {
    require(msg.sender == minter);
    balances[receiver] += amount;
  }

  error InsufficientBalance(uint requested, uint available);
  
  function sendToWife(address receiver, uint amount) public {
    require(receiver == wifesAddress);
    if(amount > balances[msg.sender])
      revert InsufficientBalance({
        requested: amount,
        available: balances[msg.sender]
      });

    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    emit Sent(msg.sender, receiver, amount);
  }
}
