// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
import "@oasisprotocol/sapphire-contracts/contracts/Sapphire.sol";


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    //Token Name, Symbol and Total Supply before Deployment
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, initialSupply);
    }

    //Token Name
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    //Token Name
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    //Token Decimals
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    //Token Total Supply
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    //Balance of a particular account
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    //Transfer Function
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        require(to != msg.sender, "You cannot transfer token to your self");
        require(amount <= _balances[owner], "You do not have sufficient tokens");
        _balances[owner] -= amount;
        _balances[to] += amount;
        _transfer(owner, to, amount);
        _totalSupply -= amount;
        return true;
    }

    //Give allowance to particular user to transfer token on your behalf
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    //Approve tokens to a particular account
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        require(_balances[owner] >= amount, "You do not have sufficient tokens");
        require(spender != msg.sender, "You cannot approve yourself");
        
        _approve(owner, spender, amount);
        return true;
    }

    //Transfer from a given account
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _balances[from] -= amount;
        _balances[to] += amount;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    //Increase the allowance given to a particular account
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        require(_balances[owner] >= addedValue);
        _balances[owner] -= addedValue;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    //Decrease the allowance given to a particular account
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _balances[owner] += subtractedValue;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    //Transfer function for Token owner only
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    //Mint Token Function for the deployer of the contract
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    //Burn Token Function for the deployer of the contract
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    //Approve function for the deployer of the contract
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //Spend allowance given for the deployer of the contract
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    //Balance before transfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    //Balance after transfer
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
