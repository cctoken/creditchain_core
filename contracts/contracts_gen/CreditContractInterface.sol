pragma solidity ^0.4.13;

contract CreditContractInterface{

    function creditSizeSendCRC(uint256 _vaule) external ;
    function creditSizeReceiveCRC() external ;
    function creditClosePosition() external;
    function   () external ;
    function debitSizePledgeWithERC20(uint256 _vaule) external ;
    function debitSizePledgeWithETH() external ;
	function debitSizePayback(uint256 _crcVaule) external ;
	function debitSizeRedeemPledge() external ;
    function changeCreditSize(address newCreditSize) external ;
    function changeDebitSize(address newDebitSize) external ;

    function setCreditSize(address newCreditSize) public ;
    function setDebitSize(address newDebitSize) public ;
	function setBaseInfo(address _creditSize,address _debitSize,string _pledgeSymbol,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate)  public ;


    function getPledgeSymbol() constant returns(string);
    function getInterestRate() constant returns(uint256);
    function getDebitSize() constant returns(address);
    function getCreditSize() constant returns(address);
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