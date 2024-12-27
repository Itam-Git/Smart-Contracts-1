import { ethers, run } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contract with the account:", deployer.address);

    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.formatEther(balance), "ETH");

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy();

    console.log("Waiting for deployment...");
    await lottery.waitForDeployment();

    const contractAddress = await lottery.getAddress();
    console.log("Lottery contract deployed to:", contractAddress);

    console.log("Verifying contract on BaseScan...");
    await run("verify:verify", {
        address: contractAddress,
        constructorArguments: [], // Dodaj argumenty konstruktora, jeśli są
    });
    console.log("Contract verified on BaseScan!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error deploying or verifying contract:", error);
        process.exit(1);
    });
