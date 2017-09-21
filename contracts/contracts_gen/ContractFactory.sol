pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './CreditContractTemplate.sol';

contract ContractFactory is Destructible {

    address public crcTokenAddress;
    address public tokenPriceManagerAddress;

    mapping(address => address[]) public creditSideContracts;
    mapping(address => address[]) public debitSideContracts;

    event CreditContractCreated(uint256 indexed contractType ,address indexed creator,address contractAddress);

    function ContractFactory(){
    //测试环境
    crcTokenAddress=0x4298aa8d76cc5dac42a275e46fdea9769bae4e57;
    tokenPriceManagerAddress=0xa5fb5aa66b310b807cf75752a7db1c5e94424898;
    }

    function creditSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        CreditContractTemplate target = new CreditContractTemplate();
        target.setBaseInfo(msg.sender,0x0,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate,crcTokenAddress,tokenPriceManagerAddress);
        address[] storage contracts = creditSideContracts[msg.sender];
        contracts.push(target);
        CreditContractCreated(1,msg.sender,target);
        return target;
    }


    function debitSideCreateContract(uint256 _pledgeSymbolIndex,uint256 _interestRate,uint256 _targetPledgeAmount,uint256 _targetCrcAmount,uint256 _startTime,uint256 _endTime,uint256 _waitRedeemTime,uint256 _closePositionRate) returns(CreditContractTemplate) {
        CreditContractTemplate target = new CreditContractTemplate();
        target.setBaseInfo(0x0,msg.sender,_pledgeSymbolIndex,_interestRate,_targetPledgeAmount,_targetCrcAmount, _startTime, _endTime, _waitRedeemTime, _closePositionRate,crcTokenAddress,tokenPriceManagerAddress);
        address[] storage contracts = debitSideContracts[msg.sender];
        contracts.push(target);
        CreditContractCreated(2,msg.sender,target);
        return target;
    }


    function queryCreditSideContract(address _creditSide)  constant public returns(address[]){
        return creditSideContracts[_creditSide];
    }

    function queryDebitSideContract(address _debitSide)  constant public returns(address[]){
        return debitSideContracts[_debitSide];
    }

}

