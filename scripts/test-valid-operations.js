const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Script para hacer pruebas válidas y mostrar que el sistema funciona
 */
async function main() {
  console.log("✅ Testing Valid Operations in T-REX Diamond\n");

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

  // Get contract interfaces
  const token = await ethers.getContractAt("TokenFacet", diamondAddress);
  const roles = await ethers.getContractAt("RolesFacet", diamondAddress);

  // Test 1: Check if signer is authorized agent
  console.log("🔍 Test 1: Check authorization status");
  try {
    const isAgent = await roles.isAgent(signer.address);
    console.log("✅ Signer is authorized agent:", isAgent);
    
    if (!isAgent) {
      console.log("⚠️  Signer is not an agent, some operations may fail");
    }
  } catch (error) {
    console.log("❌ Error checking agent status:", error.message);
  }

  // Test 2: Valid mint operation to signer address
  console.log("\n💰 Test 2: Valid mint operation");
  try {
    const mintAmount = ethers.parseUnits("5000", 18); // 5000 tokens
    console.log("🔄 Minting", ethers.formatUnits(mintAmount, 18), "tokens to", signer.address);
    
    const tx = await token.mint(signer.address, mintAmount);
    const receipt = await tx.wait();
    
    console.log("✅ Mint successful! Transaction hash:", receipt.hash);
    
    // Check new balance
    const balance = await token.balanceOf(signer.address);
    console.log("✅ New balance:", ethers.formatUnits(balance, 18), "tokens");
    
    // Check new total supply
    const totalSupply = await token.totalSupply();
    console.log("✅ New total supply:", ethers.formatUnits(totalSupply, 18), "tokens");
    
  } catch (error) {
    console.log("❌ Error in mint operation:", error.message);
  }

  // Test 3: Valid transfer operation
  console.log("\n💸 Test 3: Valid transfer operation");
  try {
    const transferAmount = ethers.parseUnits("1000", 18); // 1000 tokens
    const recipientAddress = "0x1234567890123456789012345678901234567890";
    
    console.log("🔄 Transferring", ethers.formatUnits(transferAmount, 18), "tokens to", recipientAddress);
    
    const tx = await token.transfer(recipientAddress, transferAmount);
    const receipt = await tx.wait();
    
    console.log("✅ Transfer successful! Transaction hash:", receipt.hash);
    
    // Check balances
    const senderBalance = await token.balanceOf(signer.address);
    const recipientBalance = await token.balanceOf(recipientAddress);
    
    console.log("✅ Sender balance:", ethers.formatUnits(senderBalance, 18), "tokens");
    console.log("✅ Recipient balance:", ethers.formatUnits(recipientBalance, 18), "tokens");
    
  } catch (error) {
    console.log("❌ Error in transfer operation:", error.message);
  }

  // Test 4: Final system status
  console.log("\n📊 Test 4: Final system status");
  try {
    const name = await token.name();
    const symbol = await token.symbol();
    const totalSupply = await token.totalSupply();
    
    console.log("✅ Token Name:", name);
    console.log("✅ Token Symbol:", symbol);
    console.log("✅ Total Supply:", ethers.formatUnits(totalSupply, 18), "tokens");
    console.log("✅ Implementation: Core ERC-20 + ERC-3643 basic functionality");
    
  } catch (error) {
    console.log("❌ Error getting final status:", error.message);
  }

  console.log("\n🎉 Valid operations test completed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Error in tests:", error);
    process.exit(1);
  });
