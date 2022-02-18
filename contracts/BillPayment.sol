pragma solidity ^0.8.4;

// Pay recurring bills like rent, water, security in intervals
// Pay eth per month to landlord

contract Bills {
    // landlords address
    address payable public landlord;
    // date after which rent can be paid
    uint public payDate;
    // intervals of rent payment in seconds
    uint public payDuration;
    // contract owners address
    address payable myAddress;
    // amount of money in the contract
    uint public value;
    // amount to be paid to the landlord each month
    uint public payment;
    // is the contract active or dormant
    bool active;

    event Aborted();
    event PaymentSuccess(uint amount, uint time);
    event DepositSuccess(uint amount, uint time);

    error OnlyOwner();
    error OnlyLandlord();
    error TooEarly();

    modifier condition(bool condition_){
        require(condition_);
        _;
    }

    modifier onlyOwner(){
        if(msg.sender != myAddress)
            revert OnlyOwner();
        _;
    }

    modifier onlyLandlord(){
        if(msg.sender != landlord)
            revert OnlyLandlord();
        _;
    }

    constructor(
        address payable landlordAddress,
        uint payTime,
        uint amountToBePaid
    )
    payable
    {
        payDuration = payTime;
        payment = amountToBePaid;
        value = msg.value;
        myAddress = payable(msg.sender);
        landlord = landlordAddress;
        payDate = block.timestamp + payTime;
    }

    function abort() external onlyOwner {
        emit Aborted();
        active = false;
        myAddress.transfer(address(this).balance);
    }

    function deposit() external payable onlyOwner condition(msg.value > 0) {
        emit DepositSuccess(msg.value, block.timestamp);
    }

    function balance() external view onlyOwner returns(uint balanceEth) {
        balanceEth = address(this).balance;
    }

    function makePayment() external onlyLandlord condition(active = true) condition(block.timestamp > payDate) {
        emit PaymentSuccess(payment, block.timestamp);
        payDate = block.timestamp + payDuration;
        landlord.transfer(payment);
    }
}