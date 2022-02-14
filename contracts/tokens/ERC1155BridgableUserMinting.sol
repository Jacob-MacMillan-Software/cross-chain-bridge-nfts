//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Bridgable.sol";

/**
 * @dev ERC-1155 Contract with support for Xenum Bridge, 
 * and allows contract owner to give users permission to mint their own items 
 */
contract ERC1155BridgableUserMinting is ERC1155Bridgable {
	using ECDSAUpgradeable for bytes32;
	using ECDSAUpgradeable for bytes;

	// Stores which nonces have been used in user item mints
	mapping (uint256 => bool) public userMintNonce;

	function __ERC1155BridgableUserMinting_init(string memory _uri) internal onlyInitializing {
		__ERC1155Bridgable_init(_uri);
	}

	/**
	 * @dev Lets users mint new tokens, of a given ID, with permission from contract owner
	 * SHOULD only be callable by the bridge network
	 * MUST revert if the token already exists
	 * @param _recipient Recipient of newly minted item
	 * @param _id ID of item to mint
	 * @param _amount amount of items to mint
	 * @param _nonce Uniqe ID for this transaction to prevent multiplu use of the signed message
	 * @param _data Arbitrary data passde to mint function
	 * @param _verification ABI encoded package containing a hash of a message described below, and a signature of the message, signed by contract owner
	 * @dev Description of verification package: abi.encode(keccak256(abi.encode(_recipient, _id, _amount, _nonce, _data).toEthSignedMessageHash(), <signature of previous param>))
	 */
	function userMint(
		address _recipient,
		uint256 _id,
		uint256 _amount,
		bytes calldata _data,
		uint256 _nonce,
		bytes calldata _verification
	) external {
		// Verify nonce is valid
		require(!userMintNonce[_nonce], "ERC1155BridgableUserMinting: Nonce already used");
		userMintNonce[_nonce] = true;

		// Verify hash and signature are valid
		_verifyMintSignature(_recipient, _id, _amount, _data, _nonce, _verification, owner());

		_mint(_recipient, _id, _amount, _data);
	}

	function _verifyMintSignature(
		address _recipient,
		uint256 _id,
		uint256 _amount,
		bytes calldata _data,
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
			_amount,
			_data,
			_nonce
		)).toEthSignedMessageHash() == params, "ERC1155BridgableUserMinting: Invalid verification");

		// Verify signer is owner
		require(params.recover(signature) == _expectedSigner, "ERC1155BridgeableUserMinting: Invalid signature");
	}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
