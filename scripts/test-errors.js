const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Script para probar específicamente los errores personalizados
 * en el contrato T-REX Diamond desplegado
 */
async function main() {
  console.log("🧪 Testing Custom Errors in T-REX Diamond\n");

  // Get network and diamond address
  const networkName = network.name;
  console.log("🌐 Network:", networkName);
  
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  const deploymentFile = path.join(deploymentsDir, `${networkName}-deployment.json`);
  
  if (!fs.existsSync(deploymentFile)) {
    throw new Error(`❌ No deployment file found for ${networkName}`);
  }

  const deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
  const diamondAddress = deploymentInfo.contracts.Diamond;
  
  console.log("🏛️  Diamond Address:", diamondAddress);

  // Get signer
  const [signer] = await ethers.getSigners();
  console.log("👤 Signer:", signer.address);
  console.log("");

  // Get contract interface
  const token = await ethers.getContractAt("TokenFacet", diamondAddress);

  // Test 1: Mint to zero address (should revert with ZeroAddress error)
  console.log("🧪 Test 1: Mint to zero address");
  try {
    const tx = await token.mint(ethers.ZeroAddress, ethers.parseUnits("1000", 18));
    await tx.wait();
    console.log("❌ ERROR: Should have reverted with ZeroAddress error");
  } catch (error) {
    console.log("✅ Expected error caught:", error.reason || error.message);
  }

  // Test 2: Mint zero amount (should revert with ZeroAmount error)
  console.log("\n🧪 Test 2: Mint zero amount");
  try {
    const validAddress = "0x1234567890123456789012345678901234567890";
    const tx = await token.mint(validAddress, 0);
    await tx.wait();
    console.log("❌ ERROR: Should have reverted with ZeroAmount error");
  } catch (error) {
    console.log("✅ Expected error caught:", error.reason || error.message);
  }

  // Test 3: Check current total supply (should be zero)
  console.log("\n📊 Test 3: Check total supply");
  try {
    const totalSupply = await token.totalSupply();
    console.log("✅ Current total supply:", ethers.formatUnits(totalSupply, 18), "tokens");
  } catch (error) {
    console.log("❌ Error checking total supply:", error.message);
  }

  // Test 4: Try to transfer from account with zero balance
  console.log("\n🧪 Test 4: Transfer from zero balance");
  try {
    const validAddress = "0x1234567890123456789012345678901234567890";
    const tx = await token.transfer(validAddress, ethers.parseUnits("100", 18));
    await tx.wait();
    console.log("❌ ERROR: Should have reverted with InsufficientBalance error");
  } catch (error) {
    console.log("✅ Expected error caught:", error.reason || error.message);
  }

  // Test 5: Check system info
  console.log("\n📋 Test 5: System information");
  try {
    const name = await token.name();
    const symbol = await token.symbol();
    const decimals = await token.decimals();
    const totalSupply = await token.totalSupply();
    
    console.log("✅ Token Name:", name);
    console.log("✅ Token Symbol:", symbol);
    console.log("✅ Decimals:", decimals);
    console.log("✅ Total Supply:", ethers.formatUnits(totalSupply, 18), "tokens");
  } catch (error) {
    console.log("❌ Error getting system info:", error.message);
  }

  console.log("\n🎉 Custom error tests completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Error in tests:", error);
    process.exit(1);
  });
