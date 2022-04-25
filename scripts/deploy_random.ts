import { ethers, upgrades } from "hardhat";

const log = (...args: any) => console.log(args);

async function main() {    
    const accounts = await ethers.getSigners();
    log(accounts[0].address);
    
    const SilkRandom = await ethers.getContractFactory("SilkRandom");
    const silkRandom = await SilkRandom.deploy(new Date().getTime());
    // const silkRandom = await upgrades.deployProxy(SilkRandom, [new Date().getTime()]);
    log("SilkRandom deployed to: ", silkRandom.address);

    const SilkRoad = await ethers.getContractFactory("SilkRoad");
    const srContract = await SilkRoad.deploy("SilkRandom", silkRandom.address);
    // const srContract = await upgrades.deployProxy(SilkRoad, ["SilkRandom", silkRandom.address]);
    log("SilkRoad deployed to", srContract.address);
}


main().then(() => {
    log(new Date());
    log("Done");
})

//0xfe45F9D3401F1266c158D6e2764785A806E430AB