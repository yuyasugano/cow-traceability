var CowBreeding = artifacts.require("./CowBreeding.sol");
var CowOwnership = artifacts.require("./CowOwnership.sol");

module.exports = function(deployer) {
  deployer.deploy(CowBreeding);
  deployer.deploy(CowOwnership);
};
