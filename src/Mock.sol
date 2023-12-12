// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, 100);

        _mint(
            address(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f),
            1000
        );
    }
}