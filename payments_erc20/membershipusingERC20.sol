//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract MemberShipUsingERC20 {
    IERC20 public token;

    //// lets say if there are multiple partners in the project
    address public owner1; //receiving 33% of tokens
    address public owner2; //receiving 66% of tokens

    //types of membership :
    uint256 constant public FULL_TIME_PRICE = 50 * 10**18; // 50 tokens
    uint256 constant public MONTHLY_TIME_PRICE = 1 * 10**18; // 1 token

    // days 
    uint256 constant public PERIOD = 30 days; // 30 days

    mapping (address => bool) public paid; // if the user paid for the membership
    mapping (address => uint256) public timestampClosePeriod; // when the membership will end
    mapping (address => uint256) public amountToReceive; // amount of tokens to receive, this here is for the owner1 and owner2

    constructor(address _token, address _owner1, address _owner2) {
        token = IERC20(_token);
        owner1 = _owner1;
        owner2 = _owner2;
    }

    string constant MSG_PAID_ERROR = "amount paid is not correct";
    string constant MSG_FAIL_AUTH = "not authorized";


    // function to pay for the membership, the user will pay 50 tokens, for full time membership
    function singlePay(uint256 _amount) public {
        require(_amount >= FULL_TIME_PRICE, MSG_PAID_ERROR);
        require(paid[msg.sender] == false, MSG_FAIL_AUTH); // if the user already paid

        uint256 amountToReceiveDev1 = _amount / 3; // 33% how? 
        token.transferFrom(msg.sender, address(this), amountToReceiveDev1); // transfer to contract

        uint256 amountToReceiveDev2 = _amount - amountToReceiveDev1; // 66%

        paid [msg.sender] = true;

        amountToReceive[dev1] += amountToReceiveDev1;
        amountToReceive[dev2] += amountToReceiveDev2;

    }

    // function to pay for the membership, the user will pay 1 token, for monthly membership
    function monthlyPay(uint256 _amount) public {
        require(_amount >= MONTHLY_TIME_PRICE, MSG_PAID_ERROR);
        require(paid[msg.sender] == false, MSG_FAIL_AUTH); // if the user already paid

        uint256 amountToReceiveDev1 = _amount / 3; // 33%
        token.transferFrom(msg.sender, address(this), amountToReceiveDev1); // transfer to contract

        uint256 amountToReceiveDev2 = _amount - amountToReceiveDev1; // 66%

        paid [msg.sender] = true;

        amountToReceive[dev1] += amountToReceiveDev1;
        amountToReceive[dev2] += amountToReceiveDev2;

        timestampClosePeriod[msg.sender] = block.timestamp + PERIOD; // set the timestamp when the membership will end
    }

    function withdraw() public {
        require(msg.sender == owner1 || msg.sender == owner2, MSG_FAIL_AUTH); // if the user is the owner
        require(timestampClosePeriod[msg.sender] <= block.timestamp, MSG_FAIL_AUTH); // if the membership is still active

        uint256 amountToReceiveDev1 = amountToReceive[dev1];
        uint256 amountToReceiveDev2 = amountToReceive[dev2];

        amountToReceive[dev1] = 0;
        amountToReceive[dev2] = 0;

        token.transfer(owner1, amountToReceiveDev1); // transfer to owner1
        token.transfer(owner2, amountToReceiveDev2); // transfer to owner2
    }

    // function to check the if the address is active
    function isActive() public view returns(bool) {
        return timestampClosePeriod[msg.sender] > block.timestamp; // if the membership is still active
    }
}