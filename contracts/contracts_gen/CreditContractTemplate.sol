pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/ERC20.sol';
import '../support/PledgeManager.sol';
import '../support/TokenPriceManager.sol';
import 'cctoken/contracts/CRCToken.sol';
import './CreditContractInterface.sol';

contract CreditContractTemplate is CreditContractInterface,TokenPriceManager{
    using SafeMath for uint256;
    //借出方
    address public creditSide;
    //借入方
    address public debitSide;
    //ccoken地址
    CRCToken public crcToken;
    //抵押物标识
    uint256 public pledgeSymbolIndex;

    //目标投入usdt
    uint256 public targetUsdtAmount;

    //目标投入的usdt对应的crc金额
    uint256 public targetCrcAmount;
    //已投入crc
    uint256 public crcAmount;

    //利率
    uint256 public interestRate;

    //目标抵押金额
    uint256 public targetPledgeAmount;
    //目标抵押对应usdt金额
    uint256 public targetPledgeUsdtAmount;
    //已抵押金额
    uint256 public pledgeAmount;

    //开始时间
    uint256 public startTime;
    //结束时间
    uint256 public endTime;
    //等待赎回时间
    uint256 public waitRedeemTime;
    //平仓阀值
    uint256 public closePositionRate;
    //usdt平仓线
    uint256 public targetClosePositionUsdtAmount;

    //是否已经结束
    bool public finish;
    //已经回款crc金额
    uint256 public paybackAmount;
    //目标回款usdt金额
    uint256 public targetPaybackUsdtAmount;
    bool public baseInfoHasSet;

    function CreditContractTemplate(){
        crcToken = CRCToken(getCRCTokenDeployAddress());
        baseInfoHasSet=false;
        finish=false;
    }

    modifier onlyCreditSide(){
        assert(msg.sender==creditSide);
        _;
    }

    modifier onlyDebitSide(){
        assert(msg.sender==debitSide);
        _;
    }
    modifier notReachStartTime(){
        assert(now < startTime);
        _;
    }
    modifier reachStartTime(){
        assert(now >= startTime);
        _;
    }

    modifier notReachEndTime(){
        assert(now < endTime);
        _;
    }

    modifier reachEndTime(){
        assert(now >= endTime);
        _;
    }

    modifier notReachWaitRedeemTime(){
        assert(now < waitRedeemTime);
        _;
    }

    modifier reachTargetCrcAmount(){
        assert(getCrcAmount()>=getTargetCrcAmount());
        _;
    }

    modifier reachTargetPledgeAmount(){
        assert(getPledgeAmount()>=getTargetPledgeAmount());
        _;
    }

    modifier reachPaybackAmount(){
        assert(getPaybackAmount()>=queryPledgePriceForUsdt(2,targetPaybackUsdtAmount));
        _;
    }
    modifier notReachPaybackAmount(){
        assert(getPaybackAmount()<queryPledgePriceForUsdt(2,targetPaybackUsdtAmount));
        _;
    }
    modifier reachClosePosition(){
        assert(queryPledgePriceForUsdt(pledgeSymbolIndex,targetPledgeUsdtAmount)<targetClosePositionUsdtAmount);
        _;
    }

    modifier creditSideNotSet(){
        assert(getCreditSide()==0x0);
        _;
    }

    modifier debitSideNotSet(){
        assert(getDebitSide()==0x0);
        _;
    }

    modifier baseInfoNotSet(){
        assert(!baseInfoHasSet);
        _;
    }


    function setBaseInfo(address _creditSide,address _debitSide,uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate)  public baseInfoNotSet{
        creditSide=_creditSide;
        debitSide=_debitSide;
        pledgeSymbolIndex=_pledgeSymbolIndex;
        interestRate=_interestRate;

        targetPledgeAmount=_targetPledgeAmount;
        //计算抵押物usdt成本
        targetPledgeUsdtAmount=queryPledgePriceForUsdt(pledgeSymbolIndex,targetPledgeAmount);

        targetCrcAmount=_targetCrcAmount;
        //以借出方初始投入的crc计算usdt成本
        targetUsdtAmount=queryUsdtPriceForPledge(2,targetCrcAmount);

        //以usdt成本计算最终收益usdt标准
        uint256 basePercentage=100;
        targetPaybackUsdtAmount=(interestRate.add(basePercentage)).mul(targetUsdtAmount.div(100));

        startTime=_startTime;
        endTime=_endTime;
        waitRedeemTime=_waitRedeemTime;
        closePositionRate=_closePositionRate;

        //以usdt计算平仓线
        targetClosePositionUsdtAmount=(basePercentage.sub(closePositionRate)).mul(targetPledgeUsdtAmount.div(100));
    }

    //借出方提供打款凭证(线下需要调用approve)
    function creditSideSendedCRC() external onlyCreditSide notReachStartTime {
        uint256 hasReceiveCRC = crcToken.allowance(msg.sender,this);
        require(hasReceiveCRC>=getTargetCrcAmount());
        if(hasReceiveCRC>getTargetCrcAmount()){
            uint256 refundAmount = hasReceiveCRC.sub(getTargetCrcAmount());
            assert(crcToken.transferFrom(msg.sender,msg.sender,refundAmount));
        }
        assert(crcToken.transferFrom(msg.sender,this,getTargetCrcAmount()));
        crcAmount = getTargetCrcAmount();
        CreditSideSendedCRC(this,msg.sender);
    }

    //借出方接收报酬
    function creditSideReceiveCRC() external onlyCreditSide reachEndTime reachPaybackAmount {
        crcToken.transfer(msg.sender,getPaybackAmount());
        CreditSideReceiveCRC(this,msg.sender);
    }


    //借出方平仓
    function creditClosePosition() external onlyCreditSide notReachWaitRedeemTime notReachPaybackAmount reachClosePosition {
        if(pledgeSymbolIndex==1){
            //eth
            if(!msg.sender.send(this.balance)) revert();
        }else{
            //erc20
            ERC20 erc20=ERC20(getPledgeAddress(pledgeSymbolIndex));
            if(!(erc20.transfer(msg.sender,getTargetPledgeAmount()))) revert();
        }
        CreditSideClosePosition(this,msg.sender);
    }

    //借入方接收款项
    function debitSideReceiveCRC() external onlyDebitSide reachStartTime notReachEndTime reachTargetPledgeAmount reachTargetCrcAmount{
        crcToken.transfer(msg.sender,getCrcAmount());
    }

    //调用之前先调用对应erc20的aprove
    function debitSidePledgeWithERC20() external onlyDebitSide notReachStartTime {
        require(pledgeSymbolIndex!=1);
        address pledgeAddress=getPledgeAddress(pledgeSymbolIndex);
        ERC20 erc20=ERC20(pledgeAddress);
        uint256 hasReceiveERC20 = erc20.allowance(msg.sender,this);
        require(hasReceiveERC20>=getTargetPledgeAmount());
        if(hasReceiveERC20>getTargetPledgeAmount()){
            uint256 refundAmount = hasReceiveERC20.sub(getTargetPledgeAmount());
            assert(erc20.transferFrom(msg.sender,msg.sender,refundAmount));
        }
        assert(erc20.transferFrom(msg.sender,this,getTargetPledgeAmount()));
        pledgeAmount = getTargetPledgeAmount();
        DebitSidePledge(this,msg.sender,pledgeSymbolIndex);
    }

    function () payable external{
        debitSidePledgeWithETH();
    }

    function debitSidePledgeWithETH() internal onlyDebitSide notReachStartTime {
        require(pledgeSymbolIndex==1);
        assert(pledgeAmount.add(msg.value)<=getTargetPledgeAmount());
        pledgeAmount = pledgeAmount.add(msg.value);
    }

    //调用之前需要调用approve
    function debitSidePayback() external onlyDebitSide reachTargetPledgeAmount reachTargetCrcAmount reachEndTime notReachWaitRedeemTime {
        uint256 hasReceiveCRC = crcToken.allowance(msg.sender,this);
        uint256 targetCrcPaybackAmount=queryPledgePriceForUsdt(2,targetPaybackUsdtAmount);
        require(hasReceiveCRC>=targetCrcPaybackAmount);
        if(hasReceiveCRC>targetCrcPaybackAmount){
            uint256 refundAmount = hasReceiveCRC.sub(targetCrcPaybackAmount);
            assert(crcToken.transferFrom(msg.sender,msg.sender,refundAmount));
        }
        assert(crcToken.transferFrom(msg.sender,this,targetCrcPaybackAmount));
        paybackAmount = targetCrcPaybackAmount;
        DebitSidePayback(this,msg.sender);
    }

    function debitSideRedeemPledge() external onlyDebitSide reachTargetPledgeAmount reachTargetCrcAmount reachEndTime notReachWaitRedeemTime reachPaybackAmount {
        if(pledgeSymbolIndex==1){
            //eth
            if(!msg.sender.send(this.balance)) revert();
        }else{
            //erc20
            ERC20 erc20=ERC20(getPledgeAddress(pledgeSymbolIndex));
            if(!(erc20.transfer(msg.sender,getTargetPledgeAmount()))) revert();
        }
        DebitSideRedeemPledge(this,msg.sender);
	}


    function changeCreditSide(address newCreditSide) external onlyCreditSide{
        creditSide=newCreditSide;
        ChangeCreditSide(this,msg.sender,newCreditSide);
    }
    function changeDebitSide(address newDebitSide) external onlyDebitSide{
        debitSide=newDebitSide;
        ChangeDebitSide(this,msg.sender,newDebitSide);
    }

    function setCreditSide(address newCreditSide) public creditSideNotSet{
        creditSide=newCreditSide;
    }
    function setDebitSide(address newDebitSide) public debitSideNotSet{
        debitSide=newDebitSide;
    }



    function getPledgeSymbolIndex() constant returns(uint256){return pledgeSymbolIndex;}
    function getInterestRate() constant returns(uint256){return interestRate;}
    function getDebitSide() constant returns(address){return debitSide;}
    function getCreditSide() constant returns(address){return creditSide;}
    function getTargetPledgeAmount() constant returns(uint256){return targetPledgeAmount;}
    function getPledgeAmount() constant returns(uint256){return pledgeAmount;}
    function getTargetCrcAmount() constant returns(uint256){return targetCrcAmount;}
    function getCrcAmount() constant returns(uint256){return crcAmount;}
    function getStartTime() constant returns(uint256){return startTime;}
    function getEndTime() constant returns(uint256){return endTime;}
    function getWaitRedeemTime() constant returns(uint256){return waitRedeemTime;}
    function getClosePositionRate() constant returns(uint256){return closePositionRate;}
    function getPaybackAmount() constant returns(uint256){return paybackAmount;}
    function isFinish() constant returns(bool){return finish;}
    function getCRCTokenDeployAddress() returns(address){return 0x0;}
}
