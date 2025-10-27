const hre = require("hardhat");

async function main() {
  const TrustOrb = await hre.ethers.getContractFactory("TrustOrb");
  const trustOrb = await TrustOrb.deploy();

  await trustOrb.waitForDeployment();
  console.log("✅ TrustOrb deployed to:", await trustOrb.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
