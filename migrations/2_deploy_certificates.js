const Certificate = artifacts.require("Certificates");

module.exports = function (deployer) {
  deployer.deploy(Certificate);
};
