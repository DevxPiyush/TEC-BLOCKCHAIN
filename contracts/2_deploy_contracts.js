const MyNFT = artifacts.require("MyNFT");
const Marketplace = artifacts.require("Marketplace");

module.exports = async function (deployer) {
  await deployer.deploy(MyNFT);
  const nftContract = await MyNFT.deployed();

  await deployer.deploy(Marketplace);
  const marketplaceContract = await Marketplace.deployed();
};