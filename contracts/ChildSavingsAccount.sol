pragma solidity ^0.8.4;

// deposit money that will be held unti a certain date
// when it can be withdrawn

contract Savings {
    address payable beneficiary;
    uint public payDate;
    uint public value;

    event DepositSuccess();
    event SavingsWithdrawn(uint amount, block.timestamp);

    error TooEarly();

    modifier condition(bool condition_){
        require(condition_);
        _;
    }

    modifier tooEarly(){
        if(block.timestamp > payDate)
            revert TooEarly();
        _;
    }
    
    constructor(uint payTime) payable {
        beneficiary = payable(msg.sender);
        payDate = payTime;
        value = msg.value
    }

    function deposit() external payable {
        emit DepositSuccess(msg.value, block.timestamp);
    }

    function withdraw() 
    external 
    condition(msg.sender == beneficiary)
    tooEarly()
    {
        emit SavingsWithdrawn(address(this).balance, block.timestamp);
        beneficiary.transfer();
    }
}