//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Bridgable.sol";

/**
 * @dev ERC-721 Contract with support for Xenum Bridge, 
 * and allows contract owner to give users permission to mint their own items 
 */
contract ERC721BridgableUserMinting is ERC721Bridgable {
	using ECDSAUpgradeable for bytes32;
	using ECDSAUpgradeable for bytes;

	// Stores which nonces have been used in user item mints
	mapping (uint256 => bool) public userMintNonce;

	function __ERC721BridgableUserMinting_init(
		string memory _name,
		string memory _symbol,
		uint256 _maxBatch
	) internal onlyInitializing {
		__ERC721Bridgable_init(_name, _symbol, _maxBatch);
	}

	/**
	 * @dev Lets users mint new token, of a given ID, with permission from contract owner
	 * SHOULD only be callable by the bridge network
	 * MUST revert if the token already exists
	 * @param _recipient Recipient of newly minted item
	 * @param _id ID of item to mint
	 * @param _nonce Uniqe ID for this transaction to prevent multiplu use of the signed message
	 * @param _verification ABI encoded package containing a hash of a message described below, and a signature of the message, signed by contract owner
	 * @dev Description of verification package: abi.encode(keccak256(abi.encode(_recipient, _id, _nonce).toEthSignedMessageHash(), <signature of previous param>))
	 */
	function userMint(
		address _recipient,
		uint256 _id,
		uint256 _nonce,
		bytes calldata _verification
	) external {
		// Verify nonce is valid
		require(!userMintNonce[_nonce], "ERC721BridgableUserMinting: Nonce already used");
		userMintNonce[_nonce] = true;

		// Verify _verification
		_verifyMintSignature(_recipient, _id, _nonce, _verification, owner());

		_mint(_recipient, _id);
	}

	function _verifyMintSignature(
		address _recipient,
		uint256 _id,
		uint256 _nonce,
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
			_nonce
		)).toEthSignedMessageHash() == params, "ERC721BridgableUserMinting: Invalid verification");

		// Verify signer is owner
		require(params.recover(signature) == _expectedSigner, "ERC721BridgeableUserMinting: Invalid signature");
	}
}
