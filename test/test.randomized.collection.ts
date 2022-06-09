import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("Randomized Collection Tests", () => {
  let silkRandom: Contract;
  let silkRoad: Contract;
  const _maxTokens = 20;
  let signers: SignerWithAddress[];
  const address0 = "0x0000000000000000000000000000000000000000";

  before(async () => {
    const SilkRandom = await ethers.getContractFactory("SilkRandom");
    signers = await ethers.getSigners();
    // silkRandom = await upgrades.deployProxy(SilkRandom, [new Date().getTime()]);
    silkRandom = await SilkRandom.deploy(new Date().getTime());

    console.log("Silk Random Deployed: ", silkRandom.address);

    const SilkRoad = await ethers.getContractFactory("SilkRoad");
    signers = await ethers.getSigners();
    // silkRoad = await upgrades.deployProxy(SilkRoad, ["SilkRandom", silkRandom.address]);
    silkRoad = await SilkRoad.deploy("SilkRandom", silkRandom.address);

    console.log("Silk Road Deployed: ", silkRoad.address);
  });

  it("should have a random contract called silk random", async () => {
    const randomContractAddress = await silkRoad.randomContract("SilkRandom");
    expect(randomContractAddress).to.be.equal(silkRandom.address);
  });

  it("should create an nft collection", async () => {
    const _name = "Segun's Collection";
    const _id = signers[0].address + _name;
    const _symbol = "SSC";
    const _randomContractName = "SilkRandom";
    const tx = await silkRoad.createCollection(
      _maxTokens,
      ethers.utils.parseUnits("1", "ether"),
      _id,
      _name,
      _symbol,
      _randomContractName
    );
    const txReceipt = await tx.wait(1);
    const relevantTransferEvent = txReceipt.events.find(
      (e: any) => e.event === "CollectionCreated"
    );
    const collectionAddress = relevantTransferEvent.args.collection;
    const collection = await ethers.getContractAt("RandomizedCollection", collectionAddress);
    const collectionAddress2 = await silkRoad.registry(_id);
    expect(collectionAddress).to.be.equal(collectionAddress2);
    expect(collectionAddress).to.be.equal(collection.address);
  });

  it("should mint", async () => {
    const overrides = {
      value: ethers.utils.parseEther("1"),
    };
    const _name = "Segun's Collection";
    const _id = signers[0].address + _name;
    const collectionAddress = await silkRoad.registry(_id);
    const collection: Contract = await ethers.getContractAt(
      "RandomizedCollection",
      collectionAddress
    );
    for (let i = 0; i < _maxTokens; i++) {
      await expect(collection.mint(overrides)).to.emit(collection, "Minted");
    }

    const minted: Array<Number> = [];
    for (let i = 0; i < _maxTokens; i++) {
      const tokenId = await collection.tokens(i);
      expect(minted).to.not.include(tokenId.toNumber());
      minted.push(tokenId.toNumber());
    }
  });

  it("should batch mint", async () => {
    const overrides = {
      value: ethers.utils.parseEther("20"),
    };

    const _name = "Segun's Collection 2";
    const _id = signers[0].address + _name;
    const _symbol = "SSC";
    const _randomContractName = "SilkRandom";

    await expect(
      silkRoad.createCollection(
        _maxTokens,
        ethers.utils.parseUnits("1", "ether"),
        _id,
        _name,
        _symbol,
        _randomContractName
      )
    ).to.emit(silkRoad, "CollectionCreated");

    const collectionAddress = await silkRoad.registry(_id);
    const collection: Contract = await ethers.getContractAt(
      "RandomizedCollection",
      collectionAddress
    );

    await collection.batchMint(20);

    const minted: Array<Number> = [];
    for (let i = 0; i < _maxTokens; i++) {
      const tokenId = await collection.tokens(i);
      expect(minted).to.not.include(tokenId.toNumber());
      minted.push(tokenId.toNumber());
    }
  });

  it("shold not mint after max tokens reached", async () => {
    const overrides = {
      value: ethers.utils.parseEther("1"),
    };
    let _name = "Segun's Collection";
    let _id = signers[0].address + _name;
    let collectionAddress = await silkRoad.registry(_id);
    let collection: Contract = await ethers.getContractAt(
      "RandomizedCollection",
      collectionAddress
    );
    await expect(collection.mint(overrides)).to.be.revertedWith(
      "Can not mint. All tokens already minted"
    );

    _name = "Segun's Collection 2";
    _id = signers[0].address + _name;
    collectionAddress = await silkRoad.registry(_id);
    collection = await ethers.getContractAt("RandomizedCollection", collectionAddress);
    await expect(collection.mint(overrides)).to.be.revertedWith(
      "Can not mint. All tokens already minted"
    );
  });
});
