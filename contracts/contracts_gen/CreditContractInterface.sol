pragama solidity ^0.4.13;

constract CreditContractInterface{

    function creditSizeSendCRC(uint256 _vaule) ;
    function creditSizeReceiveCRC() ;
    function creditClosePosition();

    function debitSizeReceiveCRC();

    function debitSizePledgeWithERC20(uint256 _vaule) ;
    function debitSizePledgeWithETH();
    function debitSizeRedeemPledge(uint256 _crcVaule) ;

    function changeCreditSize(address newCreditSize);
    function changeDebitSize(address newDebitSize);

    function changeInterestRate(uint256 _interestRate);


    function getPledgeSymbol() constant returns(string);
    function getInterestRate() constant returns(uint256);
    function getDebitSize() constant returns(address);
    function getCreditSize() constant returns(address);
    function getPledgeAmount() constant returns(uint256);
    function getCRCAmount() constant returns(uint256);
    function getStartTime() constant returns(uint256);
    function getEndTime() constant returns(uint256);
    function getWaitRedeemTime() constant returns(uint256);
    function getClosePositionRate() constant returns(uint256);
    function isFinish() constant returns(bool);
}