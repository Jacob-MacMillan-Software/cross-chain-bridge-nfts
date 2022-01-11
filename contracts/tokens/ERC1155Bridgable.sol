//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IERC1155Bridgable.sol";
import "../utils/BridgeMinters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

/**
 * @dev This contract can be deployed without modification, but it is intended as a template
 * to add more advanced bridge interaction to a custom ERC-1155 contract
 */
contract ERC1155Bridgable is IERC1155Bridgable, BridgeMinters, ERC1155Upgradeable {
	using ECDSAUpgradeable for bytes32;
	using ECDSAUpgradeable for bytes;

	function __ERC1155Bridgable_init(string memory _uri) internal onlyInitializing {
		__ERC1155_init(_uri);
		__BridgeMinters_init();
	}

	/**
	 * @dev See {IERC165-supportsInterface}.
	 */
	function supportsInterface(
		bytes4 interfaceId
	) public view virtual override(ERC1155Upgradeable, IERC165Upgradeable) returns (bool) {
		return super.supportsInterface(interfaceId) ||
			interfaceId == type(IERC1155Bridgable).interfaceId;
	}


	/**
	 * @dev Create a new token, of a given ID
	 * SHOULD only be callable by the bridge network
	 * MUST revert if the token already exists
	 * @param _recipient Recipient of newly minted item
	 * @param _id ID of item to mint
	 * @param _amount amount of items to mint
	 * @param _data Arbitrary data passde to mint function
	 * @param _verification ABI encoded package containing a hash of a message described below, and a signature of the message, signed by contract owner
	 * @dev Description of verification package: abi.encode(keccak256(abi.encode(_recipient, _id, _amount, _data).toEthSignedMessageHash(), <signature of previous param>))
	 */
	function bridgeMint(
		address _recipient,
		uint256 _id,
		uint256 _amount,
		bytes calldata _data,
		bytes calldata _verification
	) external virtual override onlyBridge {
		// Verify _verification
		_verifyMintSignature(_recipient, _id, _amount, _data, _verification, owner());

		_mint(_recipient, _id, _amount, _data);
	}

	function _verifyMintSignature(
		address _recipient,
		uint256 _id,
		uint256 _amount,
		bytes calldata _data,
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
			_id,
			_amount,
			_data
		)).toEthSignedMessageHash() == params, "ERC1155Bridgable: Invalid verification");

		// Verify signer is owner
		require(params.recover(signature) == _expectedSigner, "ERC1155Bridgeable: Invalid signature");
	}
}
