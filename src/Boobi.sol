// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Boobi is ERC20, Ownable, ReentrancyGuard {
    constructor() ERC20("BOOBI", "BOOBI") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY);

        _transfer(msg.sender, address(this), AIRDROP_AMOUNT); //adresi degistir
        _transfer(msg.sender, LIQUIDITY_ADDRESS, LIQUIDITY_AMOUNT); //adresi degistir
        _transfer(
            msg.sender,
            DEVELOPMENT_FUND_ADDRESS,
            DEVELOPMENT_FUND_AMOUNT
        ); //adresi degistir
    }

    address LIQUIDITY_ADDRESS = 0x8E4cD318B2ccDD320aB290ebb6850F3721e106ee;
    address DEVELOPMENT_FUND_ADDRESS = 0xEF7df01c2B3eA36dD08BC26513A02847378C100D;

    uint256 private constant TOTAL_SUPPLY = 420 * 10 ** 9 * 10 ** 18; // 420 milyar
    uint256 private constant AIRDROP_AMOUNT = (TOTAL_SUPPLY * 70) / 100; // %70
    uint256 private constant LIQUIDITY_AMOUNT = (TOTAL_SUPPLY * 20) / 100; // %20
    uint256 private constant DEVELOPMENT_FUND_AMOUNT = (TOTAL_SUPPLY * 10) / 100; // %10

    uint256 private constant AIRDROP_LOCK_DURATION = 365 days;

    struct Airdrop {
        // bool unlocked;
        bool beneficary;
        uint256 unlockDate;
    }

    mapping(address => Airdrop) airdropInfo;
 //   mapping(address => bool) gotAirdrop;

    event AirdropClaimed(address indexed beneficary, uint256 amount);

    function transfer(
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        require(
            airdropInfo[msg.sender].beneficary == false ||
                block.timestamp > airdropInfo[msg.sender].unlockDate,
            "not unlocked yet"
        );

        super.transfer(to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        require(
            airdropInfo[from].beneficary == false ||
                block.timestamp > airdropInfo[from].unlockDate,
            "not unlocked yet"
        );

        super.transferFrom(from, to, value);
        return true;
    }

    function claimAirdrop() external payable nonReentrant {
        uint256 amount = 1e15 wei; // 0.001 Ether'in Wei cinsinden karşılığı

        require(msg.value >= amount, "Not enough fee");
        require(airdropInfo[msg.sender].beneficary==false, "Already Claimed");

        uint256 airdropAmount = AIRDROP_AMOUNT / 1000000;

        bool sent = ERC20(address(this)).transfer(msg.sender, airdropAmount);
        require(sent, "Failed to send Airdrop");

        airdropInfo[msg.sender].beneficary = true;
        airdropInfo[msg.sender].unlockDate = block.timestamp + AIRDROP_LOCK_DURATION ;

        emit AirdropClaimed(msg.sender, airdropAmount);
    }

    function didMyTokensUnlocked() public view returns (bool) {
        if (airdropInfo[msg.sender].unlockDate < block.timestamp) return true;
        else return false;
    }
}
