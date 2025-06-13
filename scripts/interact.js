const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Interaction script for T-REX Diamond
 * This script provides common administrative and operational tasks
 */
async function main() {
  console.log("🔧 T-REX Diamond Interaction Script\n");

  // Get command line arguments
  const args = process.argv.slice(2);
  const command = args[0];

  if (!command) {
    console.log("📚 AVAILABLE COMMANDS:");
    console.log("   setup-issuer <issuerAddress> <topicId>     - Add a trusted issuer");
    console.log("   register-investor <investorAddr> <idAddr>  - Register investor identity");
    console.log("   mint <recipientAddr> <amount>              - Mint tokens to recipient");
    console.log("   set-agent <agentAddr> <true/false>         - Set agent status");
    console.log("   freeze <investorAddr>                      - Freeze investor account");
    console.log("   unfreeze <investorAddr>                    - Unfreeze investor account");
    console.log("   compliance-rules                           - View compliance rules");
    console.log("   token-info                                 - View token information");
    console.log("   investor-info <investorAddr>               - View investor information");
    console.log("   transfer-ownership <newOwnerAddr>          - Transfer ownership");
    console.log("");
    console.log("📋 USAGE EXAMPLES:");
    console.log("   npm run interact setup-issuer 0x123... 1");
    console.log("   npm run interact mint 0x456... 1000");
    console.log("   npm run interact token-info");
    return;
  }

  // Load deployment information
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  const deploymentFile = path.join(deploymentsDir, `${network.name}-deployment.json`);
  
  if (!fs.existsSync(deploymentFile)) {
    throw new Error(`Deployment file not found: ${deploymentFile}. Please deploy first.`);
  }

  const deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
  const diamondAddress = deploymentInfo.contracts.Diamond;

  console.log("📍 Network:", network.name);
  console.log("🏠 Diamond:", diamondAddress);

  // Get signer
  const [signer] = await ethers.getSigners();
  console.log("👤 Signer:", signer.address);
  console.log("");

  // Get contract interfaces
  const roles = await ethers.getContractAt("RolesFacet", diamondAddress);
  const token = await ethers.getContractAt("TokenFacet", diamondAddress);
  const identity = await ethers.getContractAt("IdentityFacet", diamondAddress);
  const compliance = await ethers.getContractAt("ComplianceFacet", diamondAddress);
  const claimTopics = await ethers.getContractAt("ClaimTopicsFacet", diamondAddress);
  const trustedIssuers = await ethers.getContractAt("TrustedIssuersFacet", diamondAddress);

  // Execute command
  try {
    switch (command) {
      case "setup-issuer":
        await setupIssuer(trustedIssuers, args[1], args[2]);
        break;
      
      case "register-investor":
        await registerInvestor(identity, args[1], args[2]);
        break;
      
      case "mint":
        await mintTokens(token, args[1], args[2]);
        break;
      
      case "set-agent":
        await setAgent(roles, args[1], args[2]);
        break;
      
      case "freeze":
        await freezeAccount(token, args[1]);
        break;
      
      case "unfreeze":
        await unfreezeAccount(token, args[1]);
        break;
      
      case "compliance-rules":
        await viewComplianceRules(compliance);
        break;
      
      case "token-info":
        await viewTokenInfo(token);
        break;
      
      case "investor-info":
        await viewInvestorInfo(identity, token, args[1]);
        break;
      
      case "transfer-ownership":
        await transferOwnership(roles, args[1]);
        break;
      
      default:
        console.log("❌ Unknown command:", command);
        console.log("Use 'npm run interact' to see available commands");
    }
  } catch (error) {
    console.error("❌ Command failed:", error.message);
    process.exit(1);
  }
}

// Command implementations
async function setupIssuer(trustedIssuers, issuerAddress, topicId) {
  if (!issuerAddress || !topicId) {
    throw new Error("Usage: setup-issuer <issuerAddress> <topicId>");
  }

  console.log("🤝 Setting up trusted issuer...");
  console.log("   Issuer:", issuerAddress);
  console.log("   Topic ID:", topicId);

  const tx = await trustedIssuers.addTrustedIssuer(issuerAddress, [parseInt(topicId)]);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Trusted issuer added successfully!");

  // Verify
  const issuers = await trustedIssuers.getTrustedIssuers(parseInt(topicId));
  console.log("   🔍 Verified - Issuers for topic", topicId + ":", issuers.length);
}

async function registerInvestor(identity, investorAddress, identityAddress) {
  if (!investorAddress || !identityAddress) {
    throw new Error("Usage: register-investor <investorAddress> <identityAddress>");
  }

  console.log("🆔 Registering investor identity...");
  console.log("   Investor:", investorAddress);
  console.log("   Identity Contract:", identityAddress);

  // Default country code (840 = USA)
  const countryCode = 840;

  const tx = await identity.registerIdentity(investorAddress, identityAddress, countryCode);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Investor identity registered successfully!");

  // Verify
  const registeredIdentity = await identity.getIdentity(investorAddress);
  const country = await identity.getInvestorCountry(investorAddress);
  console.log("   🔍 Verified - Identity:", registeredIdentity);
  console.log("   🔍 Verified - Country:", country);
}

async function mintTokens(token, recipientAddress, amount) {
  if (!recipientAddress || !amount) {
    throw new Error("Usage: mint <recipientAddress> <amount>");
  }

  console.log("🪙 Minting tokens...");
  console.log("   Recipient:", recipientAddress);
  console.log("   Amount:", amount, "tokens");

  const amountWei = ethers.parseEther(amount);
  const tx = await token.mint(recipientAddress, amountWei);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Tokens minted successfully!");

  // Verify
  const balance = await token.balanceOf(recipientAddress);
  const totalSupply = await token.totalSupply();
  console.log("   🔍 Verified - New Balance:", ethers.formatEther(balance), "tokens");
  console.log("   🔍 Verified - Total Supply:", ethers.formatEther(totalSupply), "tokens");
}

async function setAgent(roles, agentAddress, status) {
  if (!agentAddress || !status) {
    throw new Error("Usage: set-agent <agentAddress> <true/false>");
  }

  const isAgent = status.toLowerCase() === 'true';
  
  console.log("👥 Setting agent status...");
  console.log("   Agent:", agentAddress);
  console.log("   Status:", isAgent ? "AUTHORIZED" : "REVOKED");

  const tx = await roles.setAgent(agentAddress, isAgent);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Agent status updated successfully!");

  // Verify
  const currentStatus = await roles.isAgent(agentAddress);
  console.log("   🔍 Verified - Current Status:", currentStatus ? "AUTHORIZED" : "NOT AUTHORIZED");
}

async function freezeAccount(token, investorAddress) {
  if (!investorAddress) {
    throw new Error("Usage: freeze <investorAddress>");
  }

  console.log("🧊 Freezing account...");
  console.log("   Investor:", investorAddress);

  const tx = await token.freezeAccount(investorAddress);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Account frozen successfully!");
}

async function unfreezeAccount(token, investorAddress) {
  if (!investorAddress) {
    throw new Error("Usage: unfreeze <investorAddress>");
  }

  console.log("🔥 Unfreezing account...");
  console.log("   Investor:", investorAddress);

  const tx = await token.unfreezeAccount(investorAddress);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Account unfrozen successfully!");
}

async function viewComplianceRules(compliance) {
  console.log("⚖️  Viewing compliance rules...");

  const rules = await compliance.complianceRules();
  
  console.log("   📊 COMPLIANCE RULES:");
  console.log("   ├─ Max Balance per Investor:", ethers.formatEther(rules.maxBalance), "tokens");
  console.log("   ├─ Min Investment Amount:", ethers.formatEther(rules.minBalance), "tokens");
  console.log("   └─ Max Number of Investors:", rules.maxInvestors.toString());
}

async function viewTokenInfo(token) {
  console.log("📄 Viewing token information...");

  const name = await token.name();
  const symbol = await token.symbol();
  const decimals = await token.decimals();
  const totalSupply = await token.totalSupply();

  console.log("   📊 TOKEN INFORMATION:");
  console.log("   ├─ Name:", name);
  console.log("   ├─ Symbol:", symbol);
  console.log("   ├─ Decimals:", decimals.toString());
  console.log("   └─ Total Supply:", ethers.formatEther(totalSupply), "tokens");
}

async function viewInvestorInfo(identity, token, investorAddress) {
  if (!investorAddress) {
    throw new Error("Usage: investor-info <investorAddress>");
  }

  console.log("👤 Viewing investor information...");
  console.log("   Address:", investorAddress);

  try {
    const identityContract = await identity.getIdentity(investorAddress);
    const country = await identity.getInvestorCountry(investorAddress);
    const balance = await token.balanceOf(investorAddress);
    const isVerified = await identity.isVerified(investorAddress);

    console.log("   📊 INVESTOR INFORMATION:");
    console.log("   ├─ Identity Contract:", identityContract);
    console.log("   ├─ Country Code:", country.toString());
    console.log("   ├─ Token Balance:", ethers.formatEther(balance), "tokens");
    console.log("   ├─ Is Verified:", isVerified ? "✅ YES" : "❌ NO");
    console.log("   └─ Registration Status:", identityContract !== ethers.ZeroAddress ? "✅ REGISTERED" : "❌ NOT REGISTERED");

  } catch (error) {
    console.log("   ❌ Error retrieving investor info:", error.message);
  }
}

async function transferOwnership(roles, newOwnerAddress) {
  if (!newOwnerAddress) {
    throw new Error("Usage: transfer-ownership <newOwnerAddress>");
  }

  console.log("👑 Transferring ownership...");
  console.log("   New Owner:", newOwnerAddress);

  const currentOwner = await roles.owner();
  console.log("   Current Owner:", currentOwner);

  // Confirmation prompt (in real scenario, you might want additional confirmation)
  console.log("   ⚠️  WARNING: This action is irreversible!");

  const tx = await roles.transferOwnership(newOwnerAddress);
  console.log("   📦 Transaction:", tx.hash);
  await tx.wait();

  console.log("   ✅ Ownership transferred successfully!");

  // Verify
  const verifyOwner = await roles.owner();
  console.log("   🔍 Verified - New Owner:", verifyOwner);
}

// Execute main function
main()
  .then(() => {
    console.log("\n✨ Command completed successfully!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n❌ Command failed:", error.message);
    process.exit(1);
  });
