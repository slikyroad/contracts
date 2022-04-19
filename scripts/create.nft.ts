import { ethers, upgrades } from "hardhat";

async function main() {
    const randomAura = "0x5452c62412E12B87e29D8E5ef72783ADE4de93a4";
    const accounts = await ethers.getSigners();
    console.log(accounts[0].address);
    
    const SilkRoad = await ethers.getContractFactory("SilkRoad");
    const srContract = await upgrades.deployProxy(SilkRoad, [randomAura]);
    console.log(srContract.address);
    const result = await srContract.createNft(100, "IDD", "100110", "Olu's Test NFT", "RandomAuRa");
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