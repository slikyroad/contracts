import { ethers, upgrades } from "hardhat";

async function main() {
    const randomAura = "0x5452c62412E12B87e29D8E5ef72783ADE4de93a4";
    const accounts = await ethers.getSigners();
    console.log(accounts[0].address);
    
    const SilkRoad = await ethers.getContractFactory("SilkRoad");
    const srContract = await upgrades.deployProxy(SilkRoad, [randomAura]);
    console.log(srContract.address);
}


main().then(() => {
    console.log("Done");
})

//0xfe45F9D3401F1266c158D6e2764785A806E430AB