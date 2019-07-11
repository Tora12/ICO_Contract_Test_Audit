const iToken = artifacts.require("./iToken.sol");
const iCrowdsale = artifacts.require("./iCrowdsale.sol");

contract('iCrowdsale', function(accounts) {
  var iCrowdsaleInstance;
  var iTokenInstance;
  var admin = accounts[0];
  var buyer = accounts[1];
  var iTokenPrice = 1000000000000000;    // wei
  var tokensAvailable = 750000;
  var numberOfTokens = 10;

  it('initializes the contract with the correct values', function() {
    return iCrowdsale.deployed().then(function(instance) {
      iCrowdsaleInstance = instance;
      return iCrowdsaleInstance.address
    }).then(function(address) {
      assert.notEqual(address, 0x0, 'has contract address');
      return iCrowdsaleInstance.iTokenContract();
    }).then(function(address) {
      assert.notEqual(address, 0x0, 'has a token contract address');
      return iCrowdsaleInstance.iTokenPrice();
    }).then(function(price) {
      assert.equal(price, iTokenPrice, 'token price is correct');
    });
  });

  it('facilitates token buying', function() {
      return iToken.deployed().then(function(instance) {
      iTokenInstance = instance;
      return iCrowdsale.deployed();
    }).then(function(instance) {
      iCrowdsaleInstance = instance;
      return iTokenInstance.transfer(iCrowdsaleInstance.address, tokensAvailable, { from: admin })
    }).then(function(receipt) {
      return iCrowdsaleInstance.buyToken(numberOfTokens, { from: buyer, value: numberOfTokens * iTokenPrice })
    }).then(function(receipt) {
      assert.equal(receipt.logs.length, 1, 'triggers one event');
      assert.equal(receipt.logs[0].event, 'Sell', 'should be the "Sell" event');
      assert.equal(receipt.logs[0].args._buyer, buyer, 'logs the account that purchased the tokens');
      assert.equal(receipt.logs[0].args._amount, numberOfTokens, 'logs the number of tokens purchased');
      return iCrowdsaleInstance.tokensSold();
    }).then(function(amount) {
      assert.equal(amount.toNumber(), numberOfTokens, 'increments the number of tokens sold');
      return iTokenInstance.balanceOf(buyer);
    }).then(function(balance) {
      assert.equal(balance.toNumber(), numberOfTokens);
      return iTokenInstance.balanceOf(iCrowdsaleInstance.address);
    }).then(function(balance) {
      assert.equal(balance.toNumber(), tokensAvailable - numberOfTokens);
      return iCrowdsaleInstance.buyToken(numberOfTokens, { from: buyer, value: 1 });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('revert') >= 0, 'msg.value must equal number of tokens in wei');
      return iCrowdsaleInstance.buyToken(800000, { from: buyer, value: numberOfTokens * iTokenPrice })
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('revert' >= 0, 'cannot purchase more tokens than available'));
    });
  });
/*
  it('ends token sale', function() {
    return iToken.deployed().then(function(instance) {
      iTokenInstance = instance;
      return iCrowdsale.deployed();
    }).then(function(instance) {
      iCrowdsaleInstance = instance;
      return iCrowdsaleInstance.endSale({ from: buyer });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('revert' >= 0, 'must be admin to end sale'));
      return iCrowdsaleInstance.endSale ({ from: admin });
    }).then(function(receipt) {
      return iTokenInstance.balanceOf(admin);
    }).then(function(balance) {
     assert.equal(balance.toNumber(), 999990, 'returns all unsold iTokens to admin');
     return iCrowdsaleInstance.address;
     web3.eth.getBalance(iCrowdsaleInstance.address)
     assert.equal(balance.toNumber(), 0);
    });
  });   */
});
