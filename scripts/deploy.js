const hre = require("hardhat");

async function main() {
 
  const Flash = await hre.ethers.getContractFactory("FlashLoanExample");
  const flash = await Flash.deploy("0xBA6378f1c1D046e9EB0F538560BA7558546edF3C"); //pool addres provider rinkeby

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
