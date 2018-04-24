var Token = artifacts.require("../contracts/Token");
var QueryManager = artifacts.require("../contracts/QueryManager");

module.exports = function(deployer) {
  deployer.deploy(Token).then(
    () => deployer.deploy(QueryManager, Token.address)
  );
};
