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

    // This section was used for testing the wallet daemon. We print the outputs to ensure they match
    /*
    const abi = new ethers.utils.AbiCoder();
    console.log(verification);
    const { hash, signature } = abi.decode(["bytes32 hash", "bytes signature"], verification);
    console.log(`Hash: ${hash}`);
    console.log(`Sig: ${signature}`);
    const data = abi.decode(["address", "uint256", "uint256", "bytes", "uint256", "bytes"], "0x000000000000000000000000439a4a9c8e789915a7f2854de50f72f09a179240000000000000000000000000000000000000000000000000000000000000cc40000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000062f5581800000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c070e7719f4c12f3911fd4784da8a902a5261d39a6726bd4a773769cf048f48db900000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000041709e3327937ef4a9d0c38dc190b1f8e2afdd28d0c14ffbba6e5661ee96fab88f195f2d42f9b2c7ec117c5081b82c30bee8718c1cb856d5b26dd12cab8bea871d1b00000000000000000000000000000000000000000000000000000000000000");
    console.log(data);
    // */

    // @ts-ignore
    const mintTx = await token.userMint(...passedArgs, verification);
    /* const tx = */ await mintTx.wait();

    const postBalance = await token.balanceOf(addr1.address, 1);

    // @ts-ignore
    expect(postBalance - preBalance).to.equal(1);
  });
});
