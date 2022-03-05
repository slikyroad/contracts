import { ethers, upgrades } from "hardhat";

async function main() {
    const accounts = await ethers.getSigners();
    console.log(accounts[0].address);
    
    const SilkRoad = await ethers.getContractFactory("SilkRoad");
    const srContract = await upgrades.deployProxy(SilkRoad, []);
    console.log(srContract.address);
    const result = await srContract.createNft("100110", "Olu's Test NFT", "OLU");
    const nft = await getCreatedAddress(await result.wait(1));
    console.log(nft);
}

const getCreatedAddress = async (txReceipt: any) => {
    const event = await txReceipt.events.find(
        (e: any) => e.event === 'NFTCreated',
    );

    return event.args.nft;
};

main().then(() => {
    console.log("Done");
})