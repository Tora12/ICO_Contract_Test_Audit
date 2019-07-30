/* LOCK COMPILER VERSION */
pragma solidity ^0.5.8;

import "./cappediCrowdsale.sol";
import "./timediCrowdsale.sol";
import "./iToken.sol";

contract iCrowdsale is cappediCrowdsale, timediCrowdsale, iToken {
/* PRIVATE MODIFIER DOES NOT MAKE VARIABLE INVISIBLE */
  iToken private _iTokenContract;
/* SHOULD DECLARE VISIBILITY */
  address _admin;
  address _minter;
  address payable private _wallet;
  uint256 private _rate;
  uint256 private _raisedAmount;

  event iTokensSold(address indexed buyer, address indexed recipient, uint256 value, uint256 amount);    // RECORDS: address paying for tokens, address receiving tokens, # of wei payed for tokens, # of tokens purchased

/* PRIVATE MODIFIER DOES NOT MAKE MAPPING VARIABLE INVISIBLE */
  mapping(address => uint256) private _contribution;                            // TRACKS: total amount of wei contributed by ? address

  modifier onlyAdmin() {
    require(_admin == msg.sender, "iCrowdsale: onlyAdmin access denied");    // Should be set to specific address?
    _;
  }

  modifier onlyMinter() {
    require(_minter == address(this), "iCrowdsale: onlyMinter access denied");
    _;
  }

  constructor(iToken iTokenAddress, address payable walletAddress, uint256 rate, uint256 raisedAmount, uint256 maxCap, uint256 open, uint256 close) public
  cappediCrowdsale(raisedAmount, maxCap)
  timediCrowdsale(open, close) {

    require(address(iTokenAddress) != address(0), "iCrowdsale: iToken cannot be address 0");
    require(walletAddress != address(0), "iCrowdsale: wallet cannot be address 0");
    require(rate > 0, "iCrowdsale: rate cannot be less than 0");

    _admin = msg.sender;    // Should be set to specific address?
    _minter = address(this);
    _iTokenContract = iTokenAddress;
    _wallet = walletAddress;
    _rate = rate;
    _raisedAmount = raisedAmount;
  }

  function token() public view returns (iToken) {                               // Returns token being sold
    return _iTokenContract;
  }

  function wallet() public view returns (address payable) {                     // Returns _wallet address
    return _wallet;
  }

  function rate() public view returns (uint256) {                               // Returns _rate (wei per full token)
    return _rate;
  }

  function raisedAmount() public view returns (uint256) {                       // Returns # of wei raised
    return _raisedAmount;
  }

  function contributionAmount() public view returns (uint256) {                 // Returns contribution amount made by msg.sender address
    return _contribution[msg.sender];
  }

/* buyToken FUNCTION COULD BE CLEANER */
  function buyToken(address recipient) public payable {
    uint256 weiValue = msg.value;
    uint256 iTokenAmount = (weiValue / _rate);
    require((_preCheck(recipient, weiValue)) == true);                          // CHECKS: time limit has not been reached and max amount raised has not been reached
/* USE SAFEMATH TO AVOID OVERFLOW/UNDERFLOW */
    _raisedAmount += weiValue;                                                  // Update amount of wei raised
    require((_callMint(address(this), iTokenAmount)) == true, "iCrowdsale, failure with mint process");
    require(_iTokenContract.balanceOf(address(this)) >=  iTokenAmount, "iCrowdsale: insufficient token funds in contract");   // CHECKS: iCrowdsale contract has enough tokens to tranfer
    iToken._transfer(address(this), recipient, iTokenAmount);                   // Transfer wei value amount of tokens to recipient address
    emit iTokensSold(msg.sender, recipient, weiValue, iTokenAmount);
    _wallet.transfer(msg.value);                                                // Transfer wei funds to _wallet
/* USE SAFEMATH TO AVOID OVERFLOW/UNDERFLOW */
/* SHOULD OCCUR BEFORE EXTERNAL CALLS */
    _contribution[msg.sender] += weiValue;                                      // Update contribution wei amount of account msg.sender
  }

  function _preCheck(address _recipient, uint256 _weiValue) private view returns (bool success) {
    require(_weiValue != 0, "iCrowdsale: weiValue is 0");                       // CHECKS: amount of wei to purchase tokens is not 0
    require(_recipient != address(0), "iCrowdsale: recipient address cannot be 0");   // CHECKS: Tokens cannot be sent to address 0
    require((timediCrowdsale._checkOpen()) == true, "iCrowdsale: crowdsale past end date");    // CHECKS: time is still valid
    require((cappediCrowdsale._checkCap(_raisedAmount + _weiValue)) == true, "iCorwdsale: funding exceeds max cap");   // CHECKS: raised amount does not exceed max cap
    return true;
  }

  function _callMint(address _account, uint256 _amount) private onlyMinter returns (bool success) {   // Mint desired amount of iTokens (iCrowdsale contract address only)
    _mint(_account, _amount);
    return true;
  }

  function getMaxCap() public view returns (uint256) {                          // Returns max cap of crowdsale
    return cappediCrowdsale._getMaxCap();
  }

  function changeMaxCap(uint256 newMaxCap) public onlyAdmin returns (bool success) {    // Change max cap of crowdsale (only admin address)
    return cappediCrowdsale._changeCap(newMaxCap);
  }

  function changeEndTime(uint256 newEndTime) public onlyAdmin returns (bool success) {    // Change close time of crowdsale (only admin address)
    return timediCrowdsale._changeEndTime(newEndTime);
  }

  function endSale() public onlyAdmin {
    selfdestruct(_wallet);                                                      // End crowdsale and transfer remaining tokens (if any) in contract to _waller account
  }
}
