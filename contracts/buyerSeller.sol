pragma solidity ^0.8.4;

// buyer contributes twice the price of the product
// seller contributes twice the amount of the product
// the money is locked until the buyer confirms the product has been received
// once received the seller can withdraw thrice the value
// and the buyer widthdraw the value
// if not confirmed the money is locked forever

contract Purchase {
    uint public value;
    address payable seller;
    address payable buyer;

    enum State { Created, Locked, Release, Inactive }
    State public state;

    modifier condition(bool condition_){
        require(condition_);
        _;
    }

    error OnlyBuyer();
    error OnlySeller();
    error InvalidState();
    error ValueNotEven();

    modifier onlyBuyer(){
        if(msg.sender != buyer)
            revert OnlyBuyer();
        _;
    }

    modifier onlySeller(){
        if(msg.sender != seller)
            revert OnlySeller();
        _;
    }

    modifier inState(State state_){
        if(state != state_)
            revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if((2 * value) != msg.value)
            revert ValueNotEven();
    }

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.

    function abort() external onlySeller inState(State.Created){
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * value` ether.
    /// The ether will be locked until confirmReceived
    /// is called.
    function confirmPurchase() 
    external 
    inState(State.Created) 
    condition(msg.value == (2 * value))
    payable 
    {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    function confirmReceived()
    external
    onlyBuyer
    inState(State.Locked)
    {
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);
    }

    // pays back the seller
    function refundSeller()
    external 
    onlySeller
    inState(State.Release)
    {
        emit SellerRefunded();
        state = State.Inactive;
        seller.transfer(3 * value);
    }
}

