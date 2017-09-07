var PledgeManager = artifacts.require("./PledgeManager.sol");
var CreditContractTemplate = artifacts.require("./CreditContractTemplate.sol");

module.exports = function(deployer) {
  deployer.deploy(PledgeManager);
  deployer.deploy(CreditContractTemplate);
};
