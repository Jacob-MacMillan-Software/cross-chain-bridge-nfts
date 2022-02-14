//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IERC721Bridgable.sol";
import "../utils/BridgeMinters.sol";
import "../../ERC721A/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

/**
 * @dev This contract can be deployed without modification, but it is intended as a template
 * to add more advanced bridge interaction to a custom ERC-721 contract
 */
contract ERC721Bridgable is IERC721Bridgable, BridgeMinters, ERC721AUpgradeable {
	using ECDSAUpgradeable for bytes32;
	using ECDSAUpgradeable for bytes;

	function __ERC721Bridgable_init(
		string memory _name,
		string memory _symbol,
		uint256 _maxBatch
	) internal onlyInitializing {
		__ERC721A_init(_name, _symbol, _maxBatch);
		__BridgeMinters_init();
	}

	/**
	 * @dev See {IERC165-supportsInterface}.
	 */
	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(ERC721AUpgradeable, IERC165Upgradeable) returns (bool) {
		return super.supportsInterface(interfaceId) ||
			interfaceId == type(IERC721Bridgable).interfaceId;
	}

	/**
	 * @dev Create a new token, of a given ID
	 * SHOULD only be callable by the bridge network
	 * MUST revert if the token already exists
	 * @param _recipient Recipient of newly minted item
	 * @param _id ID of item to mint
	 */
	function bridgeMint(
		address _recipient,
		uint256 _id
	) external virtual override onlyBridge {
		_mint(_recipient, _id);
	}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
