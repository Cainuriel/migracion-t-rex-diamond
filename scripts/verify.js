const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Verification script for T-REX Diamond deployment
 * This script verifies that all facets are properly deployed and configured
 */
async function main() {
  console.log("🔍 Starting T-REX Diamond Verification...\n");

  // Load deployment information
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  const deploymentFile = path.join(deploymentsDir, `${network.name}-deployment.json`);
  
  if (!fs.existsSync(deploymentFile)) {
    throw new Error(`Deployment file not found: ${deploymentFile}`);
  }

  const deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
  const diamondAddress = deploymentInfo.contracts.Diamond;

  console.log("📋 Verifying deployment on network:", network.name);
  console.log("🏠 Diamond address:", diamondAddress);
  console.log("");

  // Get contract interfaces
  const diamond = await ethers.getContractAt("Diamond", diamondAddress);
  const roles = await ethers.getContractAt("RolesFacet", diamondAddress);
  const token = await ethers.getContractAt("TokenFacet", diamondAddress);
  const identity = await ethers.getContractAt("IdentityFacet", diamondAddress);
  const compliance = await ethers.getContractAt("ComplianceFacet", diamondAddress);
  const claimTopics = await ethers.getContractAt("ClaimTopicsFacet", diamondAddress);
  const trustedIssuers = await ethers.getContractAt("TrustedIssuersFacet", diamondAddress);

  let allChecks = [];
  let passedChecks = 0;

  // Helper function to verify a check
  function verify(description, condition, value = null) {
    const status = condition ? "✅" : "❌";
    const valueStr = value !== null ? ` (${value})` : "";
    console.log(`${status} ${description}${valueStr}`);
    allChecks.push({ description, passed: condition, value });
    if (condition) passedChecks++;
    return condition;
  }

  console.log("🔧 BASIC CONTRACT VERIFICATION");
  console.log("=".repeat(50));

  try {
    // 1. Verify Diamond contract exists and is deployed
    const diamondCode = await ethers.provider.getCode(diamondAddress);
    verify("Diamond contract deployed", diamondCode !== "0x");

    // 2. Verify ownership
    const owner = await roles.owner();
    verify("Owner is set", owner !== ethers.ZeroAddress, owner);
    verify("Owner matches deployer", owner === deploymentInfo.deployer);

    // 3. Verify token metadata
    const tokenName = await token.name();
    const tokenSymbol = await token.symbol();
    const decimals = await token.decimals();
    const totalSupply = await token.totalSupply();

    verify("Token name is set", tokenName.length > 0, tokenName);
    verify("Token symbol is set", tokenSymbol.length > 0, tokenSymbol);
    verify("Decimals is 18", decimals === 18n);
    verify("Initial total supply is 0", totalSupply === 0n);

  } catch (error) {
    console.log("❌ Basic verification failed:", error.message);
  }

  console.log("\n⚖️  COMPLIANCE VERIFICATION");
  console.log("=".repeat(50));

  try {
    // 4. Verify compliance rules
    const complianceRules = await compliance.complianceRules();
    const expectedMaxBalance = deploymentInfo.configuration.complianceRules.maxBalance;
    const expectedMinBalance = deploymentInfo.configuration.complianceRules.minBalance;
    const expectedMaxInvestors = deploymentInfo.configuration.complianceRules.maxInvestors;

    verify("Max balance rule set", 
      complianceRules.maxBalance.toString() === expectedMaxBalance.toString(),
      ethers.formatEther(complianceRules.maxBalance) + " tokens"
    );
    verify("Min balance rule set", 
      complianceRules.minBalance.toString() === expectedMinBalance.toString(),
      ethers.formatEther(complianceRules.minBalance) + " tokens"
    );
    verify("Max investors rule set", 
      complianceRules.maxInvestors.toString() === expectedMaxInvestors.toString(),
      complianceRules.maxInvestors.toString()
    );

  } catch (error) {
    console.log("❌ Compliance verification failed:", error.message);
  }

  console.log("\n📋 IDENTITY SYSTEM VERIFICATION");
  console.log("=".repeat(50));

  try {
    // 5. Verify claim topics
    const currentClaimTopics = await claimTopics.getClaimTopics();
    verify("Claim topics are set", currentClaimTopics.length > 0, `${currentClaimTopics.length} topics`);
    verify("KYC claim topic exists", currentClaimTopics.includes(1n), "Topic 1 (KYC)");
    verify("AML claim topic exists", currentClaimTopics.includes(2n), "Topic 2 (AML)");

    // 6. Verify trusted issuers setup
    const kycIssuers = await trustedIssuers.getTrustedIssuers(1);
    const amlIssuers = await trustedIssuers.getTrustedIssuers(2);
    verify("Trusted issuers structure exists", true); // If no error, structure exists

  } catch (error) {
    console.log("❌ Identity system verification failed:", error.message);
  }

  console.log("\n🔐 ACCESS CONTROL VERIFICATION");
  console.log("=".repeat(50));

  try {
    // 7. Verify agent system
    const isOwnerAgent = await roles.isAgent(owner);
    verify("Owner can act as agent", isOwnerAgent);

    // Test agent functionality (if initial agents were set)
    if (deploymentInfo.configuration.initialAgents.length > 0) {
      for (const agentAddress of deploymentInfo.configuration.initialAgents) {
        const isAgent = await roles.isAgent(agentAddress);
        verify(`Agent ${agentAddress} is registered`, isAgent, agentAddress);
      }
    }

  } catch (error) {
    console.log("❌ Access control verification failed:", error.message);
  }

  console.log("\n🧪 FUNCTIONAL TESTING");
  console.log("=".repeat(50));

  try {
    // 8. Test view functions (should not revert)
    await token.balanceOf(ethers.ZeroAddress);
    verify("Token view functions work", true);

    await compliance.canTransfer(ethers.ZeroAddress, ethers.ZeroAddress, 0);
    verify("Compliance view functions work", true);

    await identity.getIdentity(ethers.ZeroAddress);
    verify("Identity view functions work", true);

  } catch (error) {
    console.log("❌ Functional testing failed:", error.message);
  }

  console.log("\n📊 FACET VERIFICATION");
  console.log("=".repeat(50));

  try {
    // 9. Verify all facets are properly registered
    const facets = [
      { name: "TokenFacet", address: deploymentInfo.contracts.TokenFacet },
      { name: "RolesFacet", address: deploymentInfo.contracts.RolesFacet },
      { name: "IdentityFacet", address: deploymentInfo.contracts.IdentityFacet },
      { name: "ComplianceFacet", address: deploymentInfo.contracts.ComplianceFacet },
      { name: "ClaimTopicsFacet", address: deploymentInfo.contracts.ClaimTopicsFacet },
      { name: "TrustedIssuersFacet", address: deploymentInfo.contracts.TrustedIssuersFacet },
      { name: "DiamondCutFacet", address: deploymentInfo.contracts.DiamondCutFacet }
    ];

    for (const facet of facets) {
      const code = await ethers.provider.getCode(facet.address);
      verify(`${facet.name} deployed`, code !== "0x", facet.address);
    }

  } catch (error) {
    console.log("❌ Facet verification failed:", error.message);
  }

  // ========================================
  // VERIFICATION SUMMARY
  // ========================================
  console.log("\n📈 VERIFICATION SUMMARY");
  console.log("=".repeat(50));
  
  const totalChecks = allChecks.length;
  const failedChecks = totalChecks - passedChecks;
  const successRate = ((passedChecks / totalChecks) * 100).toFixed(1);

  console.log(`✅ Passed: ${passedChecks}/${totalChecks} checks (${successRate}%)`);
  
  if (failedChecks > 0) {
    console.log(`❌ Failed: ${failedChecks} checks`);
    console.log("\n❌ FAILED CHECKS:");
    allChecks.filter(check => !check.passed).forEach(check => {
      console.log(`   • ${check.description}`);
    });
  }

  console.log("\n🔗 CONTRACT ADDRESSES:");
  console.log(`   Diamond (Main): ${diamondAddress}`);
  console.log(`   Network: ${network.name}`);
  console.log(`   Deployer: ${deploymentInfo.deployer}`);
  console.log(`   Deployment Time: ${deploymentInfo.timestamp}`);

  if (passedChecks === totalChecks) {
    console.log("\n🎉 ALL VERIFICATIONS PASSED!");
    console.log("✨ Your T-REX Diamond is fully deployed and functional!");
    
    console.log("\n📚 USAGE EXAMPLES:");
    console.log("   // Connect to your diamond");
    console.log(`   const diamond = await ethers.getContractAt("TokenFacet", "${diamondAddress}");`);
    console.log("   ");
    console.log("   // Check token info");
    console.log("   const name = await diamond.name();");
    console.log("   const symbol = await diamond.symbol();");
    console.log("   ");
    console.log("   // Mint tokens (as owner/agent)");
    console.log("   await diamond.mint(recipientAddress, ethers.parseEther('1000'));");
    
  } else {
    console.log("\n⚠️  SOME VERIFICATIONS FAILED!");
    console.log("🔧 Please review the failed checks and fix any issues.");
    
    if (failedChecks < 3) {
      console.log("💡 The deployment appears mostly successful with minor issues.");
    } else {
      console.log("🚨 There are significant issues that need to be addressed.");
    }
  }

  // Save verification results
  const verificationResults = {
    network: network.name,
    diamondAddress: diamondAddress,
    timestamp: new Date().toISOString(),
    totalChecks: totalChecks,
    passedChecks: passedChecks,
    failedChecks: failedChecks,
    successRate: successRate,
    checks: allChecks,
    deploymentInfo: deploymentInfo
  };

  const verificationFile = path.join(deploymentsDir, `${network.name}-verification.json`);
  fs.writeFileSync(verificationFile, JSON.stringify(verificationResults, null, 2));
  console.log(`\n💾 Verification results saved to: ${verificationFile}`);

  return verificationResults;
}

// Execute verification
main()
  .then((results) => {
    const success = results.passedChecks === results.totalChecks;
    console.log(`\n${success ? '🎊' : '⚠️'} Verification script completed!`);
    process.exit(success ? 0 : 1);
  })
  .catch((error) => {
    console.error("\n❌ Verification failed:");
    console.error(error);
    process.exit(1);
  });
