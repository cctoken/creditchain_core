pragma solidity ^0.4.13;

contract CreditContractInterface{

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
	function setBaseInfo(address _creditSide,address _debitSide,uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate)  public ;


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