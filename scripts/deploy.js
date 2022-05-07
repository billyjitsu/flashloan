const hre = require("hardhat");

async function main() {
 
  const Flash = await hre.ethers.getContractFactory("FlashLoanExample");
  const flash = await Flash.deploy("0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6"); //pool addres provider mumbai

  await flash.deployed();

  console.log("FlashLoan deployed to:", flash.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
