pragma solidity ^0.4.13;

contract CreditContractInterface{
    event CreditSideSendedCRC(address indexed _contractAddress,address _creditSideAddress);
    event CreditSideReceiveCRC(address indexed _contractAddress,address _creditSideAddress);
    event DebitSidePledge(address indexed _contractAddress,address _debitSideAddress ,uint256 _pledgeType);
    event CreditSideClosePosition(address indexed _contractAddress,address _creditSideAddress);
    event DebitSidePayback(address indexed _contractAddress,address _debitSideAddress);
    event DebitSideRedeemPledge(address indexed _contractAddress,address _debitSideAddress);
    event ChangeCreditSide(address indexed _contractAddress,address _oldCreditSideAddress,address _newCreditSideAddress);
    event ChangeDebitSide(address indexed _contractAddress,address _oldDebitSideAddress,address _newDebitSideAddress);

    function creditSideSendedCRC() external ;
    function creditSideReceiveCRC() external ;
    function creditClosePosition() external;
    function debitSideReceiveCRC() external;
    function debitSidePledgeWithERC20() external ;
    function debitSidePledgeWithETH() internal ;
    function debitSidePayback() external ;
    function debitSideRedeemPledge() external ;
    function changeCreditSide(address newCreditSide) external ;
    function changeDebitSide(address newDebitSide) external ;
    function setCreditSide(address newCreditSide) public ;
    function setDebitSide(address newDebitSide) public ;
    


    function getPledgeSymbolIndex() constant returns(uint256);
    function getInterestRate() constant returns(uint256);
    function getDebitSide() constant returns(address);
    function getCreditSide() constant returns(address);
    function getTargetPledgeAmount() constant returns(uint256);
    function getPledgeAmount() constant returns(uint256);
    function getTargetCrcAmount() constant returns(uint256);
    function getCrcAmount() constant returns(uint256);
    function getStartTime() constant returns(uint256);
    function getEndTime() constant returns(uint256);
    function getWaitRedeemTime() constant returns(uint256);
    function getClosePositionRate() constant returns(uint256);
    function getPaybackAmount() constant returns(uint256);
    function isFinish() constant returns(bool);

}