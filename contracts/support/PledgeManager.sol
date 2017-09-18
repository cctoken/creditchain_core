pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
contract PledgeManager is Ownable {
    struct pledge{
        uint256 symIndex;
        string symbol;
        address tokenAddress;
        string  anchoringRestApi;
    }

    mapping(uint256=>pledge) pledges;

    function addPledge(uint256 _symIndex,string _symbol,address _tokenAddress,string _anchoringRestApi) external
        onlyOwner
    {
        pledge storage p = pledges[_symIndex];
        p.symIndex=_symIndex;
        p.symbol=_symbol;
        p.tokenAddress=_tokenAddress;
        p.anchoringRestApi=_anchoringRestApi;
    }

    function getPledgeAddress(uint256 _symbolIndex) public constant returns (address)
    {
        pledge storage p=pledges[_symbolIndex];
        assert(p.tokenAddress>0);
        return p.tokenAddress;
    }
}