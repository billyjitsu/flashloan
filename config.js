// Mainnet DAI Address
const DAI = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063";
// const DAI = "0x9A753f0F7886C9fbF63cF59D0D4423C5eFaCE95B"; //mumbai

// Random user's address that happens to have a lot of DAI on Polygon Mainnet
const DAI_WHALE = "0xD92B63D0E9F2CE9F77c32BfeB2C6fACd20989eB3";
// const DAI_WHALE = ""; //mumbai

// Mainnet Pool contract address

//const POOL_ADDRESS_PROVIDER = "0xa97684ead0e402dc232d5a977953df7ecbab3cdb"; //polygon mainnet
//const POOL_ADDRESS_PROVIDER = "0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6"; //mumbai
const POOL_ADDRESS_PROVIDER = '0xBA6378f1c1D046e9EB0F538560BA7558546edF3C'; //  rinkeby
module.exports = {
  DAI,
  DAI_WHALE,
  POOL_ADDRESS_PROVIDER,
};