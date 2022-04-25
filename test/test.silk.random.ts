import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("SilkRandom Tests", () => {
  let silkRandom: Contract;
  let signers: SignerWithAddress[];
  let seed = "";

  before(async () => {
    const SilkRandom = await ethers.getContractFactory("SilkRandom");
    signers = await ethers.getSigners();
    silkRandom = await SilkRandom.deploy(new Date().getTime());

    console.log("Silk Random Deployed: ", silkRandom.address);
  });

  it("should be deployed with an initial seed", async () => {
    seed = await silkRandom.seed();
    expect(seed).to.not.be.undefined;
    expect(seed).not.equal("");
  });

  it("should update batch size", async () => {
    const bs = silkRandom.batchSize();
    await expect(silkRandom.updateBatchSize(50)).to.emit(silkRandom, "BatchSizeUpdated");
    const bs2 = silkRandom.batchSize();
    expect(bs).to.not.equal(bs2);
  });

  it("should not update batch size if not admin", async () => {
    const sr7 = silkRandom.connect(signers[13]);
    await expect(sr7.updateBatchSize(5)).to.be.revertedWith(
      `AccessControl: account ${signers[13].address.toLowerCase()} is missing role 0x0000000000000000000000000000000000000000000000000000000000000000`
    );
  });

  it("should get a random number", async () => {
    const tx = await silkRandom.random();
    const txReceipt = await tx.wait(1);
    let relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "SeedUpdated");
    const who = relevantTransferEvent.args.who;
    let oldSeed = relevantTransferEvent.args.oldSeed;
    seed = relevantTransferEvent.args.newSeed;

    relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "RandomNumber");
    let oldSeed2 = relevantTransferEvent.args.seed;
    const rnd = relevantTransferEvent.args.randomNumber;

    expect(oldSeed2).to.equal(oldSeed);
    console.log(Number(rnd));
  });

  it("should get a random number with salt", async () => {
    const tx = await silkRandom.randomWithSalt(new Date().getTime());
    const txReceipt = await tx.wait(1);
    let relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "SeedUpdated");
    const who = relevantTransferEvent.args.who;
    let oldSeed = relevantTransferEvent.args.oldSeed;
    expect(seed).to.equal(oldSeed);
    seed = relevantTransferEvent.args.newSeed;

    relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "RandomNumber");
    let oldSeed2 = relevantTransferEvent.args.seed;
    const rnd = relevantTransferEvent.args.randomNumber;

    expect(oldSeed2).to.equal(oldSeed);
    console.log(Number(rnd));
  });

  it("should get batch random number", async () => {
    const tx = await silkRandom.batchRandom();
    const txReceipt = await tx.wait(1);
    let relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "SeedUpdated");
    const who = relevantTransferEvent.args.who;
    let oldSeed = relevantTransferEvent.args.oldSeed;
    expect(seed).to.equal(oldSeed);
    seed = relevantTransferEvent.args.newSeed;

    relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "RandomNumber");
    let oldSeed2 = relevantTransferEvent.args.seed;
    const rnd = relevantTransferEvent.args.randomNumber;

    expect(oldSeed2).to.equal(oldSeed);
    console.log(rnd);
  });

  it("should get batch random number with salt", async () => {
    const tx = await silkRandom.batchRandomWithSalt(new Date().getTime());
    const txReceipt = await tx.wait(1);
    let relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "SeedUpdated");
    const who = relevantTransferEvent.args.who;
    let oldSeed = relevantTransferEvent.args.oldSeed;
    seed = relevantTransferEvent.args.newSeed;

    relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "RandomNumber");
    let oldSeed2 = relevantTransferEvent.args.seed;
    const rnd = relevantTransferEvent.args.randomNumber;

    expect(oldSeed2).to.equal(oldSeed);
    console.log(Number(rnd));
  });
});
