//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./tokens/ERC721BridgableUserMinting.sol";

/**
 * @dev ERC-721 Contract with support for Xenum Bridge, 
 * and allows contract owner to give users permission to mint their own items 
 */
contract ERC721BridgableUserMintingTest is ERC721BridgableUserMinting {
   constructor(uint256 networkId) initializer {
      __ERC721BridgableUserMinting_init(networkId, "Test", "TST", 5000);
   }

	function mint(address _recipient, uint256 _amount) external {
		_safeMint(_recipient, _amount, "");
	}
}
