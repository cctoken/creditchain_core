pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract PledgeManager is Ownable {
	struct pledge{
	    string  symbol;
		address tokenAddress;
		string anchoringRestApi;
	}

	mapping(string=>pledge) pledges;

	function addPledge(string _symbol,address _tokenAddress,string _anchoringRestApi) external
		onlyOwner
	{
		pledge storage p = pledges[_symbol];
		p.symbol=_symbol;
		p.tokenAddress=_tokenAddress;
		p.anchoringRestApi=_anchoringRestApi;
	}

    function getPledge(string _symbol) public constant returns (string,address,string)
    {
        pledge storage p=pledges[_symbol];
        return (p.symbol,p.tokenAddress,p.anchoringRestApi);
    }
}