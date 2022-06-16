import { expect } from "chai";
import { ethers } from "hardhat";
import { generateHashedMessage } from "./helpers/messageSigning";

describe("ERC1155BridgableUserMinting", function () {
  it("Mint an item with owner verification", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const Token = await ethers.getContractFactory(
      "ERC1155BridgableUserMintingTest"
    );
    const token = await Token.deploy(100);
    await token.deployed();

    // Get balance of tokenID 1 as base-line
    const preBalance = await token.balanceOf(addr1.address, 1);

    // Sign tx data
    const args = [
      addr1.address, // _recipient
      1, // _id
      1, // _amount
      100,
      "0x", // _data
      1, // _nonce
    ];

    const types = [
      "address",
      "uint256",
      "uint256",
      "uint256",
      "bytes",
      "uint256",
    ];

    const passedArgs = [
      addr1.address, // _recipient
      1, // _id
      1, // _amount
      "0x", // _data
      1, // _nonce
    ];

    const verification = await generateHashedMessage(args, types, owner);

    // @ts-ignore
    const mintTx = await token.userMint(...passedArgs, verification);
    /* const tx = */ await mintTx.wait();

    const postBalance = await token.balanceOf(addr1.address, 1);

    // @ts-ignore
    expect(postBalance - preBalance).to.equal(1);
  });
});
