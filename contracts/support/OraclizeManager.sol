pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
//简易版预言机
contract OraclizeManager is Ownable  {

    struct priceRate {
        uint256 lastUpdateTime;
        uint256 rate;
    }
    uint256 public cacheExpireTime;
    uint256 public fee;
    uint256 public nonce;
    mapping(bytes32=>priceRate) priceRates;
    address public withdrawFeeAccount;

    event TriggerRefreshPriceRate(string indexed symbol,uint256 nonce);
    event PriceRateRefreshed(string indexed symbol,uint256 rate,uint256 updateTime);

    function OraclizeManager(){
        cacheExpireTime=1 hours;
        nonce=0;
        fee=0.01 ether;
        withdrawFeeAccount=0xbe62B2978bC887f0600A3Ffc78b043b549e41e33;
    }

    modifier reachFeeLimit(uint256 value){
        assert(value>=fee);
        _;
    }
    modifier onlyWithdrawFeeAccount(){
        assert(msg.sender==withdrawFeeAccount);
        _;
    }

    //用户触发更新价格，这里只收取手续费，并触发一个事件，真正update由中心化服务去做
    function triggerRefreshPriceRate(string symbol) payable external
        reachFeeLimit(msg.value)
    {
        //中心化服务根据nonce去重，避免重复更新造成资金损失
        nonce=nonce+1;
        TriggerRefreshPriceRate(symbol,nonce);
    }


    //用户触发了更新之后，中心化服务做update
    function updatePriceRateForSymbol(string symbol,uint256 rate) external
        onlyOwner
    {
        priceRate storage pr = priceRates[bytes32(sha3(symbol))];
        pr.lastUpdateTime=now;
        pr.rate=rate;
        PriceRateRefreshed(symbol,rate,now);
    }


    function getPriceRateForSymbol(string symbol) constant returns(uint256 price){
         priceRate storage pr = priceRates[bytes32(sha3(symbol))];
         assert(pr.lastUpdateTime>0&&(now-pr.lastUpdateTime < cacheExpireTime));
         return pr.rate;
    }

    function withdrawFee() external
        onlyWithdrawFeeAccount
    {
        if(!msg.sender.send(this.balance)) revert();
    }


    function setCacheExpireTime(uint256 _cacheExpireTime) external
        onlyOwner
     {
        cacheExpireTime=_cacheExpireTime;
     }

    function setFee(uint256 _fee) external
        onlyOwner
     {
        fee=_fee;
     }

    function setWithdrawFeeAccount(address newWithdrawFeeAccount) external
        onlyOwner
    {
        withdrawFeeAccount=newWithdrawFeeAccount;
    }
}