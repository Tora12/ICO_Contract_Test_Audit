/* LOCK COMPILER VERSION */
pragma solidity ^0.5.8;

contract cappediCrowdsale {
/* PRIVATE MODIFIER DOES NOT MAKE VARIABLE INVISIBLE */
  uint256 private _maxCap;

  event maxCapChange(uint256 oldCap, uint256 newCap);                           // RECORDS: change of old max cap to new max cap

  constructor(uint256 raisedAmount, uint256 maxCap) public {
    require(maxCap > raisedAmount, "cappediCrowdsale: raised amount already exceeds max cap");
    _maxCap = maxCap;
  }

  function _getMaxCap() internal view returns (uint256) {                       // Returns max cap of crowdsale
    return _maxCap;
  }

  function _checkCap(uint256 _raisedAmount) internal view returns (bool) {
    return _maxCap >= _raisedAmount;                                          // CHECKS: raisedAmount does not exceed maxCap
  }

  function _changeCap(uint256 _newCap) internal returns (bool success) {
    require(_newCap > _maxCap);
    emit maxCapChange(_maxCap, _newCap);
/* ASSIGNMENT SHOULD TAKE PLACE BEFORE EVENT UPDATE */
    _maxCap = _newCap;
    return true;
  }
}
