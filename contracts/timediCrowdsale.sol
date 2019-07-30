/* LOCK COMPILER VERSION */
pragma solidity ^0.5.8;

contract timediCrowdsale {
/* PRIVATE MODIFIER DOES NOT MAKE VARIABLE INVISIBLE */
  uint256 private _open;
  uint256 private _close;

  event closeTimeChange(uint256 prevEndTime, uint256 newEndTime);                     // RECORDS: change of old closing time to new closing time

  constructor(uint256 open, uint256 close) public {
    require(close > open, "timediCrowdsale: open time is set to after close time");
    _open = open;
    _close = close;
  }

  function _checkOpen() internal view returns (bool isOpen) {
    return block.timestamp >= _open && block.timestamp <= _close;
  }

  function _changeEndTime(uint256 newEndTime) internal returns (bool success) {
    require(newEndTime > _close, "timediCrowdsale: new end time is set before current end time");
    emit closeTimeChange(_close, newEndTime);
/* ASSIGNMENT SHOULD TAKE PLACE BEFORE EVENT UPDATE */
    _close = newEndTime;
    return true;
  }
}
