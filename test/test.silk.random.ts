import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

describe("SilkRandom Tests", () => {
  let silkRandom: Contract;
  let initialSeeders: string[];
  let signers: SignerWithAddress[];
  let seed = "";

  before(async () => {
    const SilkRandom = await ethers.getContractFactory("SilkRandom");
    signers = await ethers.getSigners();
    initialSeeders = signers.map((signer) => signer.address);
    console.log("Initial Seeders: ", initialSeeders.slice(0, 10));
    silkRandom = await upgrades.deployProxy(SilkRandom, [
      initialSeeders.slice(0, 10),
      new Date().getTime(),
    ]);

    console.log("Silk Random Deployed: ", silkRandom.address);
  });

  it("should be deployed with an initial seed", async () => {
    seed = await silkRandom.seed();
    expect(seed).to.not.be.undefined;
    expect(seed).not.equal("");
  });

  it("should update seed if a seeder", async () => {
    const sr6 = silkRandom.connect(signers[6]);
    let tx = await sr6.updateSeed(new Date().getTime());
    let txReceipt = await tx.wait(1);
    let relevantTransferEvent = txReceipt.events.find((e: any) => e.event === "SeedUpdated");
    const who = relevantTransferEvent.args.who;
    const oldSeed = relevantTransferEvent.args.oldSeed;
    const newSeed = relevantTransferEvent.args.newSeed;

    expect(who).to.equal(initialSeeders[6]);
    expect(oldSeed).to.equal(seed);
    expect(newSeed).to.not.be.undefined;
    expect(newSeed).not.equal("");
    seed = await silkRandom.seed();
    expect(seed).to.equal(newSeed);
  });

  it("should emit an event on update", async () => {
    const sr7 = silkRandom.connect(signers[7]);
    await expect(sr7.updateSeed(new Date().getTime())).to.emit(sr7, "SeedUpdated");
    seed = await silkRandom.seed();
  });

  it("should update batch size", async () => {
    const bs = silkRandom.batchSize();
    await expect(silkRandom.updateBatchSize(5)).to.emit(silkRandom, "BatchSizeUpdated");
    const bs2 = silkRandom.batchSize();
    expect(bs).to.not.equal(bs2);
  });

  it("should not update seed if not an initial seeder", async () => {
    const sr7 = silkRandom.connect(signers[13]);
    await expect(sr7.updateSeed(new Date().getTime())).to.be.revertedWith(
      `AccessControl: account ${signers[13].address.toLowerCase()} is missing role 0x30b01f92fd30e82767333105c7f0dad50d24a6246c3eac4e7e61f4d9e43e7b8e`
    );
    seed = await silkRandom.seed();
  });

  it("should not update batch size if not admin", async () => {
    const sr7 = silkRandom.connect(signers[13]);
    await expect(sr7.updateBatchSize(5)).to.be.revertedWith(
      `AccessControl: account ${signers[13].address.toLowerCase()} is missing role 0x0000000000000000000000000000000000000000000000000000000000000000`
    );
  });

  it("should get a random number", async () => {
    const randomNumber = await silkRandom.random();
    console.log(Number(randomNumber[1]));
    expect(randomNumber[0]).to.equal(seed);
  });

  it("should get a random number with salt", async () => {
    const randomNumber = await silkRandom.randomWithSalt(new Date().getTime());
    console.log(Number(randomNumber[1]));
    expect(randomNumber[0]).to.equal(seed);
  });

  it("should get batch random number", async () => {
    const randomNumber = await silkRandom.batchRandom();
    console.log(randomNumber[1]);
    expect(randomNumber[0]).to.equal(seed);
  });

  it("should get batch random number with salt", async () => {
    const randomNumber = await silkRandom.batchRandomWithSalt(new Date().getTime());
    console.log(randomNumber[1]);
    expect(randomNumber[0]).to.equal(seed);
  });
});
