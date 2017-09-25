pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './OraclizeManager.sol';
import './PledgeManager.sol';

//这里使用继承而不是组合PledgeManager,是因为solidity不支持合约间调用返回值为string的函数
contract TokenPriceManager is PledgeManager{
    address public oraclizeManagerAddress=0x0;
    using SafeMath for uint256;

    function TokenPriceManager(){

    }

    function getOraclizeManagerDeployAddress() constant returns(address){
        return oraclizeManagerAddress;
    }

    function changeOraclizeManager(address _oraclizeAddress) external onlyOwner{
        oraclizeManagerAddress=_oraclizeAddress;
    }


    function queryUsdtPriceForPledge(uint256 _pledgeSymbolIndex,uint256 _value) constant returns (uint256){
        pledge storage p=pledges[_pledgeSymbolIndex];
        uint256 priceRate= OraclizeManager(oraclizeManagerAddress).getPriceRateForSymbol(p.symbol);
        return _value.mul(priceRate);
    }

    function queryPledgePriceForUsdt(uint256 _pledgeSymbolIndex,uint256 _value) constant returns (uint256){
        pledge storage p=pledges[_pledgeSymbolIndex];
        uint256 priceRate= OraclizeManager(oraclizeManagerAddress).getPriceRateForSymbol(p.symbol);
        return _value.div(priceRate);
    }
}