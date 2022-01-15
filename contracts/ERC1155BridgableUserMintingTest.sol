//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./tokens/ERC1155BridgableUserMinting.sol";

/**
 * @dev ERC-1155 Contract with support for Xenum Bridge, 
 * and allows contract owner to give users permission to mint their own items 
 */
contract ERC1155BridgableUserMintingTest is ERC1155BridgableUserMinting {
   constructor() initializer {
      __ERC1155BridgableUserMinting_init("/testmetadata/");
   }
}
