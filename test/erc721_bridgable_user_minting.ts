import { expect } from "chai";
import { ethers } from "hardhat";
import { generateHashedMessage } from "./helpers/messageSigning";

describe("ERC721BridgableUserMinting", function () {
  it("Mint an item with owner verification", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const Token = await ethers.getContractFactory(
      "ERC721BridgableUserMintingTest"
    );
    const token = await Token.deploy(100);
    await token.deployed();

    // Sign tx data
    const args = [
      addr1.address, // _recipient
      1, // _id
      100,
      1, // _nonce
    ];

    const types = ["address", "uint256", "uint256", "uint256"];

    const passedArgs = [
      addr1.address, // _recipient
      1, // _id
      1, // _nonce
    ];

    const verification = await generateHashedMessage(args, types, owner);

    // @ts-ignore
    const mintTx = await token.userMint(...passedArgs, verification);
    const tx = await mintTx.wait();

    const postOwner = await token.ownerOf(1);

    // @ts-ignore
    expect(postOwner).to.equal(addr1.address);
  });
});
