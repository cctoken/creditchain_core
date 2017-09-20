pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './CreditContractTemplate.sol';

contract ContractFactory is Destructible {

    mapping(address => address[]) public creditSideContracts;
    mapping(address => address[]) public debitSideContracts;

    address[]  public testAddress;
    address public targetAddress;


    event CreditContractCreated(uint256 indexed contractType ,address indexed creator,address contractAddress);

    function ContractFactory(){}

    function creditSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        CreditContractTemplate target = new CreditContractTemplate();
        target.setBaseInfo(msg.sender,0x0,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate);
        address[] storage contracts = creditSideContracts[msg.sender];
        contracts.push(target);
        CreditContractCreated(1,msg.sender,target);
        return target;
    }


    function debitSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        CreditContractTemplate target = new CreditContractTemplate();
        target.setBaseInfo(0x0,msg.sender,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate);
        address[] storage contracts = debitSideContracts[msg.sender];
        contracts.push(target);
        CreditContractCreated(2,msg.sender,target);
        return target;
    }

    function testCreditSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        address target = new CreditContractTemplate();
        CreditContractTemplate(target).setBaseInfo(msg.sender,0x0,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate);
        address[] storage contracts = creditSideContracts[msg.sender];
        contracts[0]=0x404BE2e67612542E05f1b685c544454d28516e59;
        contracts[1]=target;

        testAddress[0]=0x404BE2e67612542E05f1b685c544454d28516e59;
        testAddress[1]=target;
        targetAddress=0x404BE2e67612542E05f1b685c544454d28516e59;
        CreditContractCreated(1,msg.sender,target);
        return CreditContractTemplate(target);
    }

    function queryTestAddress1()  constant public returns(address){
        return testAddress[0];
    }

    function queryTestAddress2()  constant public returns(address[]){
        return testAddress;
    }

    function queryTargetAddress()  constant public returns(address){
        return targetAddress;
    }

    function queryCreditSideContract(address _creditSide)  constant public returns(address[]){
        return creditSideContracts[_creditSide];
    }

    function queryDebitSideContract(address _debitSide)  constant public returns(address[]){
        return debitSideContracts[_debitSide];
    }

}

