const iToken = artifacts.require("./iToken.sol");
const cappediCrowdsale = artifacts.require("./cappediCrowdsale.sol");
const iCrowdsale = artifacts.require("./iCrowdsale.sol");


var tokenName = "iToken";
var tokenSymbol = "iTKN";
var tokenDecimals = 18;
var totalTokenSupply = 0;
var tokenRate = 1000000000000000000;    // wei (1 eth) per full token
var tokenWallet = 1;                    // Crowdsale Admin Address;
var maxCap = 10000000000000000000       // wei (10 eth, 10 full tokens)
var raisedAmount = 0;

var temp = (new Date).getTime();
var open = 1;   // ? HOW TO IMPLIMENT ?
var close = 100;    // ? HOW TO IMPLIMENT ?

module.exports = function(deployer) {
  deployer.deploy(iToken, tokenName, tokenSymbol, tokenDecimals, totalTokenSupply).then(function() {
    return deployer.deploy(iCrowdsale, iToken.address, tokenWallet, tokenRate, raisedAmount, maxCap, open, close);
  });
};
