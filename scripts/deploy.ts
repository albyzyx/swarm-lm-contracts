import { ethers } from "hardhat";

async function main() {
  const initialSupply = ethers.parseEther("1000000"); // Example supply: 1,000,000 tokens
  console.log(initialSupply);
  const swarmLM = await ethers.deployContract("SwarmLM", [initialSupply]);

  await swarmLM.waitForDeployment();
  console.log("SwarmLM deployed to:", swarmLM.target);

  const bondingManager = await ethers.deployContract("BondingManager", [
    swarmLM.target,
  ]);

  await bondingManager.waitForDeployment();
  console.log("BondingManager deployed to:", bondingManager.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
