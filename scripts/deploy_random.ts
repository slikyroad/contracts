import { ethers, upgrades } from "hardhat";

const log = (...args: any) => console.log(args);

async function main() {
  const accounts = await ethers.getSigners();
  log(accounts[0].address);

  let randomAddress = "0x71Be53a537cde9aa08078138cf7DB8EAcBB322bB";
  const deployRandom = true;
  if (deployRandom) {
    const SilkRandom = await ethers.getContractFactory("SilkRandom");
    const silkRandom = await SilkRandom.deploy(new Date().getTime());
    await silkRandom.deployed();
    randomAddress = silkRandom.address;
    log("SilkRandom deployed to: ", silkRandom.address);
  }

  const SilkRoad = await ethers.getContractFactory("SilkRoad");
  const srContract = await SilkRoad.deploy("SilkRandom", randomAddress);
  log("SilkRoad deployed to", srContract.address);
}

main().then(() => {
  log(new Date());
  log("Done");
});

//0xfe45F9D3401F1266c158D6e2764785A806E430AB
