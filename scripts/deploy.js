// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
require("@nomicfoundation/hardhat-toolbox")
async function main() {

  const medicineToken = await hre.ethers.deployContract("MedicineToken");
  const medicineSupplyChain = await hre.ethers.deployContract("MedicineSupplyChain",[medicineToken.target]);
  const manufacturer = await hre.ethers.deployContract("Manufacturer",[medicineSupplyChain.target]);
  const distributor = await hre.ethers.deployContract("Distributor",[medicineSupplyChain.target]);
  const pharmacy = await hre.ethers.deployContract("Pharmacy",[medicineSupplyChain.target]);
  const consumer = await hre.ethers.deployContract("Consumer",[medicineSupplyChain.target]);

  await medicineToken.waitForDeployment();
//Contract Address
  console.log(`MedicineToken deployed to ${medicineToken.target}`);
  console.log(`MedicineSupplyChain deployed to ${medicineSupplyChain.target}`);
  console.log(`Manufacturer deployed to ${manufacturer.target}`);
  console.log(`Distributor deployed to ${distributor.target}`);
  console.log(`Pharmacy to deployed ${pharmacy.target}`);
  console.log(`Consumer to deployed ${consumer.target}`);


  const WAIT_BLOCK_CONFIRMATION = 4;
  await medicineToken.deployTransaction.wait(WAIT_BLOCK_CONFIRMATION);
  await run("verify:verify", {
    address:medicineToken.target,
  });
  await run("verify:verify", {
    address:medicineSupplyChain.target,
    constructorArguments: [medicineToken.target],
  });
  await run("verify:verify", {
    address:manufacturer.target,
    constructorArguments: [medicineSupplyChain.target],
  });
  await run("verify:verify", {
    address:distributor.target,
    constructorArguments: [medicineSupplyChain.target],
  });
  await run("verify:verify", {
    address:pharmacy.target,
    constructorArguments: [medicineSupplyChain.target],
  });
  await run("verify:verify", {
    address:consumer.target,
    constructorArguments: [medicineSupplyChain.target],
  });
  console.log("Contract Verified:");


}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
