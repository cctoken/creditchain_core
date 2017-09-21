pragma solidity ^0.4.13;
contract OraclizeManager {
    mapping(uint256=>uint256) rate;

    function OraclizeManager(){

    }

    function getPriceRateForUrl(string url) constant returns(uint256 price){
        return 2;
    }
}