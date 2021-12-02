//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IERC721Bridgable.sol";
import "./BridgeMinters.sol";

abstract contract ERC721Bridgable is IERC721Bridgable, BridgeMinters {
	/**
	  * @dev Create a new token, of a given ID
	  * SHOULD only be callable by the bridge network
	  * MUST revert if the token already exists
	  */
	 function bridgeMint(address recipient, uint256 id) external virtual override;
}
