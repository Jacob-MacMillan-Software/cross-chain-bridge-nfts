// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract BridgeMinters is OwnableUpgradeable {
	mapping (address => bool) public isBridge;

	function __BridgeMinters_init() internal /* onlyInitializing */ {
		__Ownable_init();
	}

	modifier onlyBridge() {
		require(isBridge[_msgSender()], "BridgeMinters: caller is not bridge");
		_;
	}

	function addBridgeAddress(address _bridge) external {
		isBridge[_bridge] = true;
	}

	function removeBridgeAddress(address _bridge) external {
		isBridge[_bridge] = false;
	}
}
