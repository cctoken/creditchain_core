
var OraclizeManager = artifacts.require("./support/OraclizeManager.sol");
var TokenPriceManager = artifacts.require("./support/TokenPriceManager.sol");


var ContractFactory = artifacts.require("./contracts_gen/ContractFactory.sol");

module.exports = function(deployer) {
  deployer.deploy(OraclizeManager);
  deployer.deploy(TokenPriceManager);



  deployer.deploy(ContractFactory);
};
