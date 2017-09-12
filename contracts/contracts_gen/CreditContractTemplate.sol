pragma solidity ^0.4.13;

import '../support/PledgeManager.sol';
import 'cctoken/contracts/CRCToken.sol';
import './CreditContractInterface.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract CreditContractTemplate is CreditContractInterface{

    using SafeMath for uint256;
	address public creditSide;
	address public debitSide;
	PledgeManager public pledgeManager;
	CRCToken public crcToken;

    string public pledgeSymbol;
	uint256 public interestRate;

    uint256 public pledgeAmount;
    uint256 public targetPledgeAmount;
    uint256 public crcAmount;
    uint256 public targetCrcAmount;

	uint256 public startTime;
	uint256 public endTime;

    uint256 public waitRedeemTime;

    uint256 public closePositionRate;


    bool public finish;
    uint256 public paybackAmount;
    bool public hasPledge;


    bool public baseInfoHasSet;




	function CreditContractTemplate(){
		pledgeManager = PledgeManager(0x0);
		crcToken = CRCToken(0x0);
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
		assert(getPaybackAmount()>=(interestRate.add(100)).mul(crcAmount.div(100)));
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


    function creditSizeSendCRC(uint256 _vaule) external onlyCreditSide notReachStartTime {}
    function creditSizeReceiveCRC() external onlyCreditSide reachEndTime {}
    function creditClosePosition() external onlyCreditSide notReachWaitRedeemTime {}
    function debitSizeReceiveCRC() external reachStartTime notReachEndTime reachTargetPledgeAmount{}
    function debitSizePledgeWithERC20(uint256 _vaule) external onlyDebitSide notReachStartTime {}
    function debitSizePledgeWithETH() external onlyDebitSide notReachStartTime {}
	function debitSizePayback(uint256 _crcVaule) external reachTargetPledgeAmount reachTargetCrcAmount reachEndTime notReachWaitRedeemTime {}
	function debitSizeRedeemPledge() external reachTargetPledgeAmount reachTargetCrcAmount reachEndTime notReachWaitRedeemTime reachPaybackAmount {}
    function changeCreditSize(address newCreditSize) external onlyCreditSide{}
    function changeDebitSize(address newDebitSize) external onlyDebitSide{}

    function setCreditSize(address newCreditSize) public creditSideNotSet{}
    function setDebitSize(address newDebitSize) public debitSizeNotSet{}
	function setBaseInfo(address _creditSize,address _debitSize,string _pledgeSymbol,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate)  public baseInfoNotSet{}


    function getPledgeSymbol() constant returns(string){return pledgeSymbol;}
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

}
