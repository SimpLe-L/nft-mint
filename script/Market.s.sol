// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "../src/Market.sol";
import "../src/CombineNFT.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        CombineNFT combineNFT = new CombineNFT();

        Markets marketPlace = new Markets(combineNFT);

        vm.stopBroadcast();

        console.log("Contract deployed to address:", address(combineNFT));
        console.log("Contract deployed to address:", address(marketPlace));
    }
}
