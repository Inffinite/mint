// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Wife {
  address public minter;
  mapping (address => uint) public balances;
  address public wifesAddress;

  // Events allow clients to react to specific
  // contract changes in this case the sending of
  // money to my wife
  event Sent(address from, address to, uint amount);

  // runs once when the contract 
  // is created only
  constructor(){
    // set the address
    // of the one who uploaded contract as the minter
    // in this case the husband
    minter = msg.sender;
    // set wife's address
    wifesAddress = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
  }

  // can only be called by the minter(husband)
  // mint and send to any address

  function mint(address receiver, uint amount) public {
    require(msg.sender == minter);
    balances[receiver] += amount;
  }

  error InsufficientBalance(uint requested, uint available);
  
  // can be used by anyone to send money
  // can only send money to the wife
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
