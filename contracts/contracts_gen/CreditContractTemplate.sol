pragma solidity ^0.4.13;

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
    bool public hasPledge;


    bool public baseInfoHasSet;
	string public _eth="ETH";
	function CreditContractTemplate(){
		crcToken = CRCToken(getCRCTokenDeployAddress());
		baseInfoHasSet=false;
		finish=false;
		hasPledge=false;
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
	modifier reachClosePosition(){
		assert(queryPledgePriceForUsdt(pledgeSymbolIndex,targetPledgeUsdtAmount)<targetClosePositionUsdtAmount);
		_;
	}

    modifier creditSideNotSet(){
		assert(getCreditSize()==0x0);
		_;
    }

    modifier debitSizeNotSet(){
		assert(getDebitSize()==0x0);
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
    function proveCreditSizeSendedCRC() external onlyCreditSide notReachStartTime {
       uint256 hasReceiveCRC = crcToken.allowance(msg.sender,this);
       require(hasReceiveCRC>=targetCrcAmount);
       if(hasReceiveCRC>targetCrcAmount){
        uint256 refundAmount = hasReceiveCRC.sub(targetCrcAmount);
        assert(crcToken.transferFrom(msg.sender,msg.sender,refundAmount));
       }
	   assert(crcToken.transferFrom(msg.sender,this,targetCrcAmount));
       crcAmount = targetCrcAmount;
    }

    //借出方接收报酬
    function creditSizeReceiveCRC() external onlyCreditSide reachEndTime reachPaybackAmount {
        crcToken.transfer(msg.sender,getPaybackAmount());
    }


    //借出方平仓
    function creditClosePosition() external onlyCreditSide notReachWaitRedeemTime reachClosePosition {


    }

    //借入方接收款项
    function debitSizeReceiveCRC() external onlyDebitSide reachStartTime notReachEndTime reachTargetPledgeAmount reachTargetCrcAmount{
        crcToken.transfer(msg.sender,getCrcAmount());
    }


    function debitSizePledgeWithERC20(uint256 _vaule) external onlyDebitSide notReachStartTime {
		require(pledgeSymbolIndex!=1);


    }


    function debitSizePledgeWithETH() external onlyDebitSide notReachStartTime {}
	function debitSizePayback(uint256 _crcVaule) external reachTargetPledgeAmount reachTargetCrcAmount reachEndTime notReachWaitRedeemTime {}
	function debitSizeRedeemPledge() external reachTargetPledgeAmount reachTargetCrcAmount reachEndTime notReachWaitRedeemTime reachPaybackAmount {}
    function changeCreditSize(address newCreditSize) external onlyCreditSide{}
    function changeDebitSize(address newDebitSize) external onlyDebitSide{}
    function setCreditSize(address newCreditSize) public creditSideNotSet{}
    function setDebitSize(address newDebitSize) public debitSizeNotSet{}



    function getPledgeSymbolIndex() constant returns(uint256){return pledgeSymbolIndex;}
    function getInterestRate() constant returns(uint256){return interestRate;}
    function getDebitSize() constant returns(address){return debitSide;}
    function getCreditSize() constant returns(address){return creditSide;}
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


    function getCRCTokenDeployAddress() returns(address){
        return 0x0;
    }

}
