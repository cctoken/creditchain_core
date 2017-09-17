pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './OraclizeManager.sol';
import './PledgeManager.sol';

//这里使用继承而不是组合PledgeManager,是因为solidity不支持合约间调用返回值为string的函数
contract TokenPriceManager is PledgeManager{

	OraclizeManager public oraclizeManager;
	address public oraclizeAddress=0x0;
    using SafeMath for uint256;

	function TokenPriceManager(){

		oraclizeManager= OraclizeManager(getOraclizeManagerDeployAddress());
	}

    function getOraclizeManagerDeployAddress() returns(address){
        return oraclizeAddress;
    }

	function changeOraclizeManager(address _oraclizeAddress) external onlyOwner{
		oraclizeAddress=_oraclizeAddress;
		oraclizeManager= OraclizeManager(oraclizeAddress);
	}


    function queryUsdtPriceForPledge(uint256 _pledgeSymbolIndex,uint256 _value) public returns (uint256){

		pledge storage p=pledges[_pledgeSymbolIndex];
 		uint256 priceRate= oraclizeManager.getPriceRateForUrl(p.anchoringRestApi);
 		return _value.mul(priceRate);
    }

    function queryPledgePriceForUsdt(uint256 _pledgeSymbolIndex,uint256 _value) public returns (uint256){
		pledge storage p=pledges[_pledgeSymbolIndex];
 		uint256 priceRate= oraclizeManager.getPriceRateForUrl(p.anchoringRestApi);
 		return _value.div(priceRate);
    }
}