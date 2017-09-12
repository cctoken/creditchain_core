pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import './CreditContractTemplate.sol';

contract ContractFactory is Destructible {

  mapping(address => address[]) public creditSizeContracts;
  mapping(address => address[]) public debitSizeContracts;


  event CreditContractCreated(address indexed creator,address contractAddress);

  function ContractFactory(){}

  function creditSizeCreateContract() returns(CreditContractTemplate) {
    CreditContractTemplate target = new CreditContractTemplate();
    target.changeCreditSize(msg.sender);

    address[] storage contracts = creditSizeContracts[msg.sender];
    contracts.push(target);

    CreditContractCreated(msg.sender,target);
    return target;
  }

}

