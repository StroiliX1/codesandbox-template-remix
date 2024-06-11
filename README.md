# Project1dentifier

## Description
Project1dentifier is a smart contract written in Solidity designed to manage and monetize streaming music assets. It allows tracking earnings from various streaming platforms, aggregates the revenue, and deposits the funds into the project's account on a quarterly basis. The contract facilitates the issuance and management of tokens that represent the value of these music assets.

## Features
- **Token Management**: Issue and manage MusicAssetToken (MAT) tokens.
- **Earnings Tracking**: Aggregate earnings from multiple sources.
- **Revenue Distribution**: Distribute earnings to stakeholders on a quarterly basis.
- **Transfers and Allowances**: Transfer tokens and manage allowances.

## Contract Overview
```solidity
pragma solidity ^0.8.0;

contract Project1dentifier {
    // Contract owner
    address public owner;

    // Token information
    string public name = "MusicAssetToken";
    string public symbol = "MAT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Mapping to store token balances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Earnings information
    struct Earnings {
        uint256 totalEarnings;
        uint256 lastDistribution;
    }
    Earnings public earnings;

    // Mapping to store artist earnings
    mapping(address => uint256) public artistEarnings;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event EarningsDeposited(uint256 amount, uint256 timestamp);
    event EarningsDistributed(uint256 amount, uint256 timestamp);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Constructor
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[owner] = totalSupply;
    }

    // Transfer function
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[msg.sender], "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve function
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer from function
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Invalid address");
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // Deposit earnings
    function depositEarnings(uint256 _amount) public onlyOwner {
        earnings.totalEarnings += _amount;
        emit EarningsDeposited(_amount, block.timestamp);
    }

    // Distribute earnings
    function distributeEarnings() public onlyOwner {
        require(earnings.totalEarnings > 0, "No earnings to distribute");

        uint256 distributionAmount = earnings.totalEarnings;
        earnings.totalEarnings = 0;
        earnings.lastDistribution = block.timestamp;

        // Logic to distribute earnings to artist accounts
        // ...

        emit EarningsDistributed(distributionAmount, block.timestamp);
    }
}
```

## How to Use

1. **Deploy the Contract**: Deploy the `Project1dentifier` contract to the Ethereum blockchain.
2. **Initialize Supply**: The contract owner initializes the total supply of `MAT` tokens upon deployment.
3. **Transfer Tokens**: Users can transfer tokens using the `transfer` function.
4. **Approve Allowances**: Users can approve allowances using the `approve` function.
5. **Deposit Earnings**: The owner deposits earnings into the contract using `depositEarnings`.
6. **Distribute Earnings**: The owner distributes earnings to stakeholders using `distributeEarnings`.

## Installation

To work with the contract, you need to have:
- [Solidity](https://docs.soliditylang.org/en/v0.8.0/)
- [Remix IDE](https://remix.ethereum.org/) or a local development environment

1. Open Remix IDE or your local development environment.
2. Copy the contract code into a new Solidity file.
3. Compile the contract using Solidity version 0.8.0.
4. Deploy the contract to your preferred Ethereum network.

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.