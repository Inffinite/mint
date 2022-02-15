const Wife = artifacts.require('Wife')

module.exports = function(_deployer) {
  _deployer.deploy(Wife)
};
