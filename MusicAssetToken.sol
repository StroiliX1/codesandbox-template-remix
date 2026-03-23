// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProjectIdentifier {

    address public owner;

    string public name = "MusicAssetToken";
    string public symbol = "MAT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // 🔥 Dividend tracking
    uint256 public accEarningsPerToken;
    uint256 constant PRECISION = 1e18;

    mapping(address => uint256) public rewardDebt;
    mapping(address => uint256) public pendingRewards;

    // 🎵 Music asset with multiple artists
    struct ArtistShare {
        address artist;
        uint256 share; // percentage in basis points (10000 = 100%)
    }

    struct MusicAsset {
        string platform;
        string link;
        uint256 earnings;
        ArtistShare[] artists;
    }

    mapping(uint256 => MusicAsset) public musicAssets;

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event EarningsDeposited(uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event MusicAssetRegistered(uint256 indexed id);
    event EarningsAddedToAsset(uint256 indexed id, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[owner] = totalSupply;
    }

    // =========================
    // ERC20 LOGIC (IMPROVED)
    // =========================

    function _updateRewards(address _user) internal {
        uint256 accumulated = (balanceOf[_user] * accEarningsPerToken) / PRECISION;
        uint256 pending = accumulated - rewardDebt[_user];
        if (pending > 0) {
            pendingRewards[_user] += pending;
        }
        rewardDebt[_user] = accumulated;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Zero address");
        require(balanceOf[msg.sender] >= _value, "Balance too low");

        _updateRewards(msg.sender);
        _updateRewards(_to);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "Balance too low");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");

        _updateRewards(_from);
        _updateRewards(_to);

        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // =========================
    // 💰 EARNINGS LOGIC
    // =========================

    function depositEarnings() external payable onlyOwner {
        require(totalSupply > 0, "No tokens exist");

        accEarningsPerToken += (msg.value * PRECISION) / totalSupply;

        emit EarningsDeposited(msg.value);
    }

    function claim() public {
        _updateRewards(msg.sender);

        uint256 reward = pendingRewards[msg.sender];
        require(reward > 0, "No rewards");

        pendingRewards[msg.sender] = 0;

        payable(msg.sender).transfer(reward);

        emit Claimed(msg.sender, reward);
    }

    // =========================
    // 🎵 MUSIC ASSETS
    // =========================

    function registerMusicAsset(
        uint256 _id,
        string memory _platform,
        string memory _link,
        address[] memory _artists,
        uint256[] memory _shares
    ) public onlyOwner {

        require(_artists.length == _shares.length, "Mismatch");

        uint256 totalShares;
        for (uint256 i = 0; i < _shares.length; i++) {
            totalShares += _shares[i];
        }

        require(totalShares == 10000, "Shares must equal 100%");

        MusicAsset storage asset = musicAssets[_id];
        asset.platform = _platform;
        asset.link = _link;

        for (uint256 i = 0; i < _artists.length; i++) {
            asset.artists.push(ArtistShare({
                artist: _artists[i],
                share: _shares[i]
            }));
        }

        emit MusicAssetRegistered(_id);
    }

    function addEarningsToAsset(uint256 _id) public payable onlyOwner {
        MusicAsset storage asset = musicAssets[_id];
        require(bytes(asset.platform).length != 0, "Asset not found");

        asset.earnings += msg.value;

        // distribute to artists
        for (uint256 i = 0; i < asset.artists.length; i++) {
            uint256 artistAmount = (msg.value * asset.artists[i].share) / 10000;
            pendingRewards[asset.artists[i].artist] += artistAmount;
        }

        emit EarningsAddedToAsset(_id, msg.value);
    }

    // =========================
    // 🔍 VIEW HELPERS
    // =========================

    function pending(address _user) external view returns (uint256) {
        uint256 accumulated = (balanceOf[_user] * accEarningsPerToken) / PRECISION;
        return pendingRewards[_user] + (accumulated - rewardDebt[_user]);
    }
}