pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract PledgeManager is Owner{
	struct pledge{
		string symbol;
		address tokenAddress;
		string anchoringRestApi;
	}

	mapping(sting=>pledge) pledges;

	function addPledge(string _symbol,address tokenAddress,string anchoringRestApi) external
		ownerOnly
	{
		pledge storage p = pledges[_symbol];
		if(p.symbol!=null){

		}else{

		}

	}
}