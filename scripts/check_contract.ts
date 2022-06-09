import { Contract } from "ethers";
import { ethers } from "hardhat";

const log = (...args: any) => console.log(args);

const collectionAddress = "0x1a1bCc83e22f14a6769Ada962ae554342FE9eb16";

async function main() {
  const overrides = {
    value: ethers.utils.parseEther("0.001"),
  };
  const collection: Contract = await ethers.getContractAt(
    "RandomizedCollection",
    collectionAddress
  );
}

main().then(() => {
  log(new Date());
  log("Done");
});
