pragama solidity ^0.4.13;

constract CreditContractInterface{

    function creditSizeSendCRC(uint256 _vaule) ;
    function creditSizeReceiveCRC() ;
    function creditClosePosition();

    function debitSizeReceiveCRC();

    function debitSizePledgeWithERC20(uint256 _vaule) ;
    function debitSizePledgeWithETH();

    function debitSizePayback(uint256 _crcVaule);
    function debitSizeRedeemPledge() ;

    function changeCreditSize(address newCreditSize);
    function changeDebitSize(address newDebitSize);

    function setCreditSize(address newCreditSize);
    function setDebitSize(address newDebitSize);




	function setBaseInfo(address _creditSize,address _debitSize,string _pledgeSymbol,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) ;


    function getPledgeSymbol() constant returns(string);
    function getInterestRate() constant returns(uint256);
    function getDebitSize() constant returns(address);
    function getCreditSize() constant returns(address);
    function getPledgeAmount() constant returns(uint256);
    function getTargetPledgeAmount() constant returns(uint256);
    function getCRCAmount() constant returns(uint256);
    function getTargetCRCAmount() constant returns(uint256);

    function getStartTime() constant returns(uint256);
    function getEndTime() constant returns(uint256);
    function getWaitRedeemTime() constant returns(uint256);
    function getClosePositionRate() constant returns(uint256);
	function getPaybackAmount() constant returns(uint256);
    function isFinish() constant returns(bool);
}