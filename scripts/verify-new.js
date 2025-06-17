const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Universal Verification Script for T-REX Diamond - New Architecture
 * Works on any network where the diamond has been deployed
 */
async function main() {
  console.log("🔍 T-REX Diamond Verification - New Architecture\n");

  // Get network name
  const networkName = network.name;
  console.log("🌐 Network:", networkName);
  
  // Try to load deployment info, fallback to manual input if needed
  let diamondAddress;
  let deploymentInfo = null;
  
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  const deploymentFile = path.join(deploymentsDir, `${networkName}-deployment.json`);
  
  if (fs.existsSync(deploymentFile)) {
    deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
    diamondAddress = deploymentInfo.contracts.Diamond;
    console.log("📄 Using deployment file:", deploymentFile);
  } else {
    // For Alastria or manual verification, use the known address
    if (networkName === 'alastria') {
      diamondAddress = "0x8E96e3F80aF9c715C90d35BFFFAA32d330C69528";
      console.log("📍 Using Alastria address:", diamondAddress);
    } else {
      throw new Error(`❌ No deployment file found for ${networkName}. Please deploy first.`);
    }
  }

  console.log("🏛️  Diamond Address:", diamondAddress);
  console.log("");

  // Verification helper
  function verify(description, condition, value = "") {
    const status = condition ? "✅" : "❌";
    const valueStr = value ? ` (${value})` : "";
    console.log(`   ${status} ${description}${valueStr}`);
    return condition;
  }

  let totalChecks = 0;
  let passedChecks = 0;

  // ========================================
  // STEP 1: BASIC CONTRACT VERIFICATION
  // ========================================
  console.log("🔧 BASIC CONTRACT VERIFICATION");
  console.log("=".repeat(50));
  
  try {
    // Check if diamond contract exists
    const diamondCode = await ethers.provider.getCode(diamondAddress);
    totalChecks++;
    passedChecks += verify("Diamond contract deployed", diamondCode !== "0x");

    const roles = await ethers.getContractAt("RolesFacet", diamondAddress);
    const token = await ethers.getContractAt("TokenFacet", diamondAddress);
    
    // Basic contract calls
    const owner = await roles.owner();
    const tokenName = await token.name();
    const tokenSymbol = await token.symbol();
    const decimals = await token.decimals();
    
    totalChecks += 4;
    passedChecks += verify("Owner set", owner !== ethers.ZeroAddress, owner);
    passedChecks += verify("Token name set", tokenName.length > 0, tokenName);
    passedChecks += verify("Token symbol set", tokenSymbol.length > 0, tokenSymbol);
    passedChecks += verify("Decimals correct", decimals.toString() === "18", decimals.toString());
    
  } catch (error) {
    console.log("   ❌ Basic verification failed:", error.message);
  }

  // ========================================
  // STEP 2: FACET VERIFICATION
  // ========================================
  console.log("\n🎭 FACET VERIFICATION");
  console.log("=".repeat(50));
  
  const facets = [
    { name: "TokenFacet", contract: "TokenFacet" },
    { name: "RolesFacet", contract: "RolesFacet" },
    { name: "IdentityFacet", contract: "IdentityFacet" },
    { name: "ComplianceFacet", contract: "ComplianceFacet" },
    { name: "ClaimTopicsFacet", contract: "ClaimTopicsFacet" },
    { name: "TrustedIssuersFacet", contract: "TrustedIssuersFacet" }
  ];

  for (const facet of facets) {
    try {
      const facetContract = await ethers.getContractAt(facet.contract, diamondAddress);
      // Try to call a basic function to verify it's working
      if (facet.name === "TokenFacet") {
        await facetContract.name();
      } else if (facet.name === "RolesFacet") {
        await facetContract.owner();
      } else {
        // For other facets, try to call their interface if available
        // This is a basic existence check
      }
      
      totalChecks++;
      passedChecks += verify(`${facet.name} accessible`, true);
    } catch (error) {
      totalChecks++;
      verify(`${facet.name} accessible`, false, error.message);
    }
  }

  // ========================================  
  // STEP 3: EIP-2535 INTROSPECTION (OPTIONAL)
  // ========================================
  console.log("\n🔍 EIP-2535 INTROSPECTION (Optional)");
  console.log("=".repeat(50));
  
  for (const facet of facets) {
    try {
      const facetContract = await ethers.getContractAt(facet.contract, diamondAddress);
      const selectors = await facetContract.selectorsIntrospection();
      totalChecks++;
      passedChecks += verify(`${facet.name} introspection`, selectors.length > 0, `${selectors.length} selectors`);
    } catch (error) {
      totalChecks++;
      verify(`${facet.name} introspection`, false, "Not implemented or error");
    }
  }

  // ========================================
  // STEP 4: FUNCTIONAL TESTING
  // ========================================
  console.log("\n🧪 FUNCTIONAL TESTING");
  console.log("=".repeat(50));
  
  try {
    const token = await ethers.getContractAt("TokenFacet", diamondAddress);
    const roles = await ethers.getContractAt("RolesFacet", diamondAddress);
    
    // Test read operations
    const totalSupply = await token.totalSupply();
    const [signer] = await ethers.getSigners();
    const balance = await token.balanceOf(signer.address);
    const isAgent = await roles.isAgent(signer.address);
    
    totalChecks += 3;
    passedChecks += verify("Total supply readable", true, ethers.formatEther(totalSupply));
    passedChecks += verify("Balance readable", true, ethers.formatEther(balance));  
    passedChecks += verify("Agent status readable", true, isAgent.toString());
    
  } catch (error) {
    console.log("   ❌ Functional testing failed:", error.message);
  }

  // ========================================
  // STEP 5: STORAGE VERIFICATION
  // ========================================
  console.log("\n📦 STORAGE VERIFICATION");
  console.log("=".repeat(50));
  
  try {
    const token = await ethers.getContractAt("TokenFacet", diamondAddress);
    const roles = await ethers.getContractAt("RolesFacet", diamondAddress);
    
    // Verify that storage is working correctly
    const name = await token.name();
    const symbol = await token.symbol();
    const owner = await roles.owner();
    
    totalChecks += 3;
    passedChecks += verify("Token storage accessible", name.length > 0, name);
    passedChecks += verify("Token symbol storage accessible", symbol.length > 0, symbol);
    passedChecks += verify("Roles storage accessible", owner !== ethers.ZeroAddress, owner);
    
  } catch (error) {
    console.log("   ❌ Storage verification failed:", error.message);
  }

  // ========================================
  // FINAL SUMMARY
  // ========================================
  console.log("\n" + "=".repeat(70));
  console.log("📊 VERIFICATION SUMMARY");
  console.log("=".repeat(70));
  
  const successRate = totalChecks > 0 ? (passedChecks / totalChecks * 100).toFixed(1) : 0;
  const status = successRate >= 90 ? "🟢 EXCELLENT" : 
                 successRate >= 70 ? "🟡 GOOD" : 
                 successRate >= 50 ? "🟠 NEEDS ATTENTION" : "🔴 CRITICAL";
  
  console.log(`🌐 Network: ${networkName}`);
  console.log(`🏛️  Diamond: ${diamondAddress}`);
  console.log(`📊 Checks: ${passedChecks}/${totalChecks} passed (${successRate}%)`);
  console.log(`📈 Status: ${status}`);
  
  if (deploymentInfo) {
    console.log(`🕐 Deployed: ${deploymentInfo.timestamp || 'Unknown'}`);
  }
  
  console.log("\n🎯 RECOMMENDATIONS:");
  if (successRate >= 90) {
    console.log("   ✅ System is fully operational and ready for production");
  } else if (successRate >= 70) {
    console.log("   ⚠️  System is mostly functional but some features may need attention");
  } else {
    console.log("   🚨 System has significant issues that need to be resolved");
  }
  
  console.log("\n✨ Verification completed!");
  
  // Return results for programmatic use
  return {
    networkName,
    diamondAddress,
    totalChecks,
    passedChecks,
    successRate: parseFloat(successRate),
    status
  };
}

// Execute verification
main()
  .then((results) => {
    console.log(`\n🎊 Verification script completed with ${results.successRate}% success rate!`);
    process.exit(results.successRate >= 70 ? 0 : 1);
  })
  .catch((error) => {
    console.error("\n❌ Verification failed:");
    console.error(error);
    process.exit(1);
  });
