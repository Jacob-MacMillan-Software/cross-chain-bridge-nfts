//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IERC721Bridgable.sol";
import "../utils/BridgeMinters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

/**
 * @dev This contract can be deployed without modification, but it is intended as a template
 * to add more advanced bridge interaction to a custom ERC-721 contract
 */
contract ERC721Bridgable is IERC721Bridgable, BridgeMinters, ERC721Upgradeable {
	using ECDSAUpgradeable for bytes32;
	using ECDSAUpgradeable for bytes;

	function __ERC721Bridgable_init(string memory _name, string memory _symbol) internal /* onlyInitializing */ {
		__ERC721_init(_name, _symbol);
		__BridgeMinters_init();
	}

	/**
	 * @dev See {IERC165-supportsInterface}.
	 */
	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(ERC721Upgradeable, IERC165Upgradeable) returns (bool) {
		return super.supportsInterface(interfaceId) ||
			interfaceId == type(IERC721Bridgable).interfaceId;
	}

	/**
	 * @dev Create a new token, of a given ID
	 * SHOULD only be callable by the bridge network
	 * MUST revert if the token already exists
	 * @param _recipient Recipient of newly minted item
	 * @param _id ID of item to mint
	 * @param _verification ABI encoded package containing a hash of a message described below, and a signature of the message, signed by contract owner
	 * @dev Description of verification package: abi.encode(keccak256(abi.encode(_recipient, _id).toEthSignedMessageHash(), <signature of previous param>))
	 */
	function bridgeMint(
		address _recipient,
		uint256 _id,
		bytes calldata _verification
	) external virtual override onlyBridge {
		// Verify _verification
		_verifyMintSignature(_recipient, _id,  _verification, owner());

		_mint(_recipient, _id);
	}

	function _verifyMintSignature(
		address _recipient,
		uint256 _id,
		bytes calldata _verification,
		address _expectedSigner
	) internal pure {
		// Verify _verification
		bytes32 params;
		bytes memory signature;
		(params, signature) = abi.decode(_verification, (bytes32, bytes));

		// Verification data matches given data
		require(keccak256(abi.encode(
			_recipient,
			_id
		)).toEthSignedMessageHash() == params, "ERC1155Bridgable: Invalid verification");

		// Verify signer is owner
		require(params.recover(signature) == _expectedSigner, "ERC1155Bridgeable: Invalid signature");
	}
}
