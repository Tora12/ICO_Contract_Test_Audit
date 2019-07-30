/* LOCK COMPILER VERSION */
pragma solidity ^0.5.8;

contract iToken {
/* PRIVATE MODIFIER DOES NOT MAKE VARIABLE INVISIBLE */
  string private _tokenName;
  string private _tokenSymbol;
  uint8 private _tokenDecimals;
  uint256 private _tokenSupply;

  event Transfer(address indexed from, address indexed to, uint value);            // RECORDS: # of Tokens Transferred from Account A to Account B
  event Approval(address indexed owner, address indexed spender, uint256 value);   // RECORDS: # of Tokens Approved by Account A for Account B to use

/* PRIVATE MODIFIER DOES NOT MAKE MAPPING VARIABLE INVISIBLE */
  mapping(address => uint256) private _balance;                                 // TRACKS: Account A~? => w/ # of Tokens owned
  mapping(address => mapping (address => uint256)) private _allowance;          // TRACKS: Account A~? => approving Account B~? => w/ # of Tokens specified

  constructor(string memory name, string memory symbol, uint8 decimals, uint256 initSupply) public {
    _tokenName = name;
    _tokenSymbol = symbol;
    _tokenDecimals = decimals;
    _balance[msg.sender] = initSupply;                                         // initSupply = # specified in 2_deploy_contracts.js
    _tokenSupply = initSupply;
  }

  function tokenName() public view returns (string memory) {                    // Returns token name
    return _tokenName;
  }

  function tokenSymbol() public view returns (string memory) {                  // Returns token symbol
    return _tokenSymbol;
  }

  function tokenDecimals() public view returns (uint8) {                        // Returns token decimals
    return _tokenDecimals;
  }

  function totalSupply() public view returns (uint256) {                        // Returns total number of iTokens
    return _tokenSupply;
  }

  function balanceOf(address account) public view returns (uint256) {           // Returns balance of account ? address
    return _balance[account];
  }

  function allowance(address owner, address spender) public view returns (uint256) {    // Returns remaining allowance from the owner account for the spender account to use
    return _allowance[owner][spender];
  }

  function transfer(address recipient, uint256 amount) public returns (bool success) {    // If successful, transfers ? number of tokens from msg.sender to recipient address
    _transfer(msg.sender, recipient, amount);
    return true;
  }
/* THE APPROVE FUNCTION OF ERC-20 MIGHT LEAD TO VULNERABILITIES */
  function approve(address spender, uint256 value) public returns (bool success) {    // If successful, approves allowance of ? number of tokens from msg.sender to/for spender address to use
    _approve(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address owner, address recipient, uint256 amount) public returns (bool success) {               // If successful, transfers ? number of approved allowance tokens from msg.sender to/for recipient address to use
    require(_allowance[owner][msg.sender] <= amount, "iToken: inadequate allowance amount from msg.sender account");    // CHECKS: Account msg.sender has enough _allowance Tokens from Account owner to Transfer
    _transfer(owner, recipient, amount);
    _approve(owner, recipient, _allowance[owner][msg.sender] -= amount);
    return true;
  }


  function _transfer(address _sender, address _recipient, uint256 _amount) internal {
    require(_balance[_sender] >= _amount, "iToken: inadequate amount for transfer from sender account");    // CHECKS: Account _sender has enough tokens specified to transfer
/* USE SAFEMATH TO AVOID OVERFLOW/UNDERFLOW */
    _balance[_sender] -= _amount;
    _balance[_recipient] += _amount;
    emit Transfer(_sender, _recipient, _amount);
  }

  function _approve(address _owner, address _spender, uint256 _value) internal {
    require(_balance[_owner] >= _value, "iToken: inadequate amount for approval from owner account");   // CHECKS: Account _owner has enough tokens specified to approve allowance
    _allowance[_owner][_spender] = _value;
    emit Approval(_owner, _spender, _value);
  }

  function _mint(address _account, uint256 _amount) internal {
/* USE SAFEMATH TO AVOID OVERFLOW/UNDERFLOW */
    _tokenSupply += _amount;
    _balance[_account] += _amount;
    emit Transfer(address(0), _account, _amount);
  }
}
