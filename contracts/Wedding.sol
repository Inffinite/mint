pragma solidity ^0.8.4;

// both parties can deposit funds
// for one party to withdraw money the other party has to approve
// Hence for one party to get funds the other party has to send it to them
// on divorce all the money is split in half and sent to both parties

contract Wedding {
    uint public value;
    address payable husband;
    address payable wife;
    bool husbandDivorceRequest = false;
    bool wifeDivorceRequest = false;

    enum State { Together, Pending, Divorced }
    State public state;

    modifier condition(bool condition_){
        require(condition_);
        _;
    }

    error OnlyHusband();
    error OnlyWife();
    error InvalidState();
    error InsufficientFunds(uint requested, uint available);

    event SentToHusband(uint amount, uint time);
    event SentToWife(uint amount, uint time);
    event Divorced();
    event DepositSuccess(uint amount, uint time, address sender);
    event WifeWithdraw(uint amount, uint time);
    event HusbandWithdraw(uint amount, uint time);

    modifier onlyHusband(){
        if(msg.sender != husband)
            revert OnlyHusband();
        _;
    }

    modifier onlyWife(){
        if(msg.sender != wife)
            revert OnlyWife();
        _;
    }

    modifier inState(State state_){
        if(state != state_)
            revert InvalidState();
        _;
    }

    constructor(
        address payable huby,
        address payable wify
    ) payable {
        husband = huby;
        wife = wify;
    }

    function deposit() 
    external 
    inState(State.Together) 
    payable 
    {
        emit DepositSuccess(msg.value, block.timestamp, msg.sender);
        value = value + msg.value;
    }

    function balance() external view returns(uint ethBalance) {
        ethBalance = address(this).balance;
    }

    function payWife(uint amount) 
    external 
    onlyHusband
    inState(State.Together)
    {
        if(amount > address(this).balance)
            revert InsufficientFunds({
                requested: amount,
                available: address(this).balance
            });

        emit SentToWife({
            amount: amount,
            time: block.timestamp
        });
        value = value - amount;
        wife.transfer(amount);
    }

    function payHusband(uint amount) 
    external 
    onlyWife
    inState(State.Together)
    {
        if(amount > address(this).balance)
            revert InsufficientFunds({
                requested: amount,
                available: address(this).balance
            });

        emit SentToHusband({
            amount: amount,
            time: block.timestamp
        });
        value = value - amount;
        husband.transfer(amount);
    }

    function divorceWife()
    external
    onlyHusband
    condition(husbandDivorceRequest != true)
    condition(state != State.Divorced)
    {
        state = State.Pending;
        husbandDivorceRequest = true;

        if(husbandDivorceRequest == true && wifeDivorceRequest == true)
            state = State.Divorced;
            emit Divorced();
    }

    function husbandUndoDivorce()
    external 
    onlyHusband
    inState(State.Pending)
    condition(husbandDivorceRequest == true)
    {
        husbandDivorceRequest = false;
        state = State.Together;
    }

    function wifeUndoDivorce()
    external 
    onlyWife
    inState(State.Pending)
    condition(wifeDivorceRequest == true)
    {
        wifeDivorceRequest = false;
        state = State.Together;
    }

    function divorceHusband()
    external
    onlyWife
    condition(wifeDivorceRequest != true)
    condition(state != State.Divorced)
    {
        state = State.Pending;
        wifeDivorceRequest = true;

        if(husbandDivorceRequest == true && wifeDivorceRequest == true)
            state = State.Divorced;
            emit Divorced();
    }

    function wifeWithdraw()
    external
    onlyWife
    inState(State.Divorced)
    {   
        emit WifeWithdraw(value / 2, block.timestamp);
        wife.transfer(value / 2);
    }

    function husbandWithdraw()
    external
    onlyHusband
    inState(State.Divorced)
    {   
        emit HusbandWithdraw(value / 2, block.timestamp);
        husband.transfer(value / 2);
    }
}