import { ethers } from "hardhat";

// @ts-ignore
export async function generateHashedMessage(args: Array, signer) {
  const abi = new ethers.utils.AbiCoder();
  const types = ["address", "uint256", "uint256", "bytes", "uint256"];

  const abiEncoded = abi.encode(types, args);

  const message = ethers.utils.keccak256(abiEncoded);

  const messageBuffer = Buffer.from(message.substring(2), "hex");
  const prefix = Buffer.from(
    `\u0019Ethereum Signed Message:\n${messageBuffer.length}`
  );
  const hash = ethers.utils.keccak256(Buffer.concat([prefix, messageBuffer]));

  const messageHash = ethers.utils.arrayify(message);

  const signature /* flatSig */ = await signer.signMessage(messageHash);
  // const signature = ethers.utils.splitSignature(flatSig);

  return abi.encode(["bytes32", "bytes"], [hash, signature]);
}

// @ts-ignore
export async function generateHashedMessageERC721(args: Array, signer) {
  const abi = new ethers.utils.AbiCoder();
  const types = ["address", "uint256", "uint256"];

  const abiEncoded = abi.encode(types, args);

  const message = ethers.utils.keccak256(abiEncoded);

  const messageBuffer = Buffer.from(message.substring(2), "hex");
  const prefix = Buffer.from(
    `\u0019Ethereum Signed Message:\n${messageBuffer.length}`
  );
  const hash = ethers.utils.keccak256(Buffer.concat([prefix, messageBuffer]));

  const messageHash = ethers.utils.arrayify(message);

  const signature /* flatSig */ = await signer.signMessage(messageHash);
  // const signature = ethers.utils.splitSignature(flatSig);

  return abi.encode(["bytes32", "bytes"], [hash, signature]);
}
