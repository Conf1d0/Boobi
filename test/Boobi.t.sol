// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Boobi} from "../src/Boobi.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BoobiTest is Test {
    Boobi public boobi;
    address owner = makeAddr("owner");
    address random = makeAddr("random");
    address random2 = makeAddr("random2");
    address LIQUIDITY_ADDRESS = makeAddr("LIQUIDITY_ADDRESS");
    address DEVELOPMENT_FUND_ADDRESS = makeAddr("DEVELOPMENT_FUND_ADDRESS");

    function setUp() public {
        vm.prank(owner);
        boobi = new Boobi();
    }

    function test_balance() public {
        uint256 balance = boobi.balanceOf(owner);
        uint256 balanceLIQ = boobi.balanceOf(
            0x8E4cD318B2ccDD320aB290ebb6850F3721e106ee
        );
        uint256 balanceDEV = boobi.balanceOf(
            0xEF7df01c2B3eA36dD08BC26513A02847378C100D
        );

        uint256 balance2 = boobi.balanceOf(
            0x88F59F8826af5e695B13cA934d6c7999875A9EeA
        );
        uint bolen = 10 ** 9 * 10 ** 18;
        console2.log("LIQUIDITY_ADDRESS Balance :", balanceLIQ / bolen);
        console2.log("Owner Balance :", balance / bolen);
        console2.log("DEVELOPMENT_FUND_ADDRESS Balance :", balanceDEV / bolen);

        console2.log("Boobi  contract Balance :", balance2 / bolen);
        assertEq(balanceLIQ / bolen, 84);
        assertEq(balance / bolen, 0);
        assertEq(balanceDEV / bolen, 42);
        assertEq(balance2 / bolen, 294);
    }

    function test_claim() public {
        uint256 fee = 1e15 wei;
        vm.deal(random, 1 ether);
        vm.prank(random);
        boobi.claimAirdrop{value: fee}();
        uint256 balance = boobi.balanceOf(random);
        console2.log("RANDOM BALANCE :", balance);
    }

    function test_doubleClaim() public {
        uint256 fee = 1e15 wei;
        vm.deal(random, 1 ether);
        uint256 balance = boobi.balanceOf(random);

        vm.startPrank(random);
        boobi.claimAirdrop{value: fee}();
        vm.expectRevert();
        boobi.claimAirdrop{value: fee}();

        console2.log("RANDOM BALANCE DOUBLE :", balance);
    }

    function test_earlyTransfer() public {
        uint256 fee = 1e15 wei;
        vm.deal(random, 1 ether);
        vm.prank(random);
        boobi.claimAirdrop{value: fee}();

        //beneficary is trying to his tokens to somewhere else
        vm.startPrank(random);
        vm.expectRevert();
        boobi.transfer(random2, 1000);

        //beneficary is trying to delegate some address to sned  his tokens to somewhere else

        boobi.approve(random2, 1000);
        vm.stopPrank();

        //random2 trying to transfer token from random to somewhere else
        vm.startPrank(random2);
        vm.expectRevert();
        boobi.transferFrom(random, owner, 500);
        vm.stopPrank();
    }

    function test_lateTransfer() public {
        uint256 fee = 1e15 wei;
        vm.deal(random, 1 ether);
        vm.prank(random);
        boobi.claimAirdrop{value: fee}();

        uint256 time = 60 * 60 * 24 * 366; //365 + 1 days
        skip(time);

        //beneficary is trying to his tokens to somewhere else
        vm.startPrank(random);
        boobi.transfer(random2, 1000);

        //beneficary is trying to delegate some address to sned  his tokens to somewhere else

        boobi.approve(random2, 1000);
        vm.stopPrank();

        //random2 trying to late ransfer token from random to somewhere else
        vm.startPrank(random2);
        boobi.transferFrom(random, owner, 500);
        vm.stopPrank();
    }

    function test_transferDexTokens() public {
        vm.deal(DEVELOPMENT_FUND_ADDRESS, 1 ether);

        vm.prank(DEVELOPMENT_FUND_ADDRESS);
        boobi.transfer(address(1), 500);
        uint256 balance = boobi.balanceOf(address(1));

        assertEq(balance, 500);
    }

    function test_transferFromDexTokens() public {
        vm.deal(DEVELOPMENT_FUND_ADDRESS, 1 ether);

        vm.prank(DEVELOPMENT_FUND_ADDRESS);
        boobi.approve(random, 1000);

        vm.prank(random);

        boobi.transferFrom(DEVELOPMENT_FUND_ADDRESS, address(2), 555);
        uint256 balance = boobi.balanceOf(address(2));

        assertEq(balance, 555);
    }

    function test_didMyTokensUnlocked() public {
        uint256 fee = 1e15 wei;
        vm.deal(random, 1 ether);
        uint256 time = 60 * 60 * 24 * 366; //365 + 1 days
        vm.prank(random);
        boobi.claimAirdrop{value: fee}();

        vm.prank(random);

        assertEq(boobi.didMyTokensUnlocked(), false);

        skip(time);
        vm.prank(random);

        assertEq(boobi.didMyTokensUnlocked(), true);

        uint256 balance = boobi.balanceOf(random);
        console2.log("RANDOM BALANCE :", balance);
    }
}
