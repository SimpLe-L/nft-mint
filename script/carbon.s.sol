pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "../src/CarbonTrader.sol";
import "../src/ERC20Mock.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        uint256 initialSupply = 1_000_000 * 10 ** 6;

        ERC20Mock erc20Token = new ERC20Mock(
            "Mock USDT",
            "USDT",
            address(this),
            initialSupply
        );

        CarbonTrader carbonTrader = new CarbonTrader(address(erc20Token));

        vm.stopBroadcast();

        console.log("Contract one deployed to address:", address(erc20Token));
        console.log("Contract two deployed to address:", address(carbonTrader));
    }
}
