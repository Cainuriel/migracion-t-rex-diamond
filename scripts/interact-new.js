const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Universal Interaction Script for T-REX Diamond - New Architecture
 * This script provides common administrative and operational tasks
 * Works on any network where the diamond has been deployed
 */
async function main() {
  console.log("🔧 T-REX Diamond Interaction Script - New Architecture\n");

  // Get command line arguments
  const args = process.argv.slice(2);
  let command = args[0];
  let cmdArgs = args.slice(1);

  // Alternative: use environment variables if no direct args
  if (!command && process.env.TREX_COMMAND) {
    command = process.env.TREX_COMMAND;
    cmdArgs = process.env.TREX_ARGS ? process.env.TREX_ARGS.split(' ') : [];
    console.log("📝 Using environment variables for command");
  }

  if (!command) {
    console.log("📚 AVAILABLE COMMANDS:");
    console.log("   setup-issuer <issuerAddress> <topicId>     - Add a trusted issuer");
    console.log("   register-investor <investorAddr> <idAddr>  - Register investor identity");
    console.log("   mint <recipientAddr> <amount>              - Mint tokens to recipient");
    console.log("   set-agent <agentAddr> <true/false>         - Set agent status");
    console.log("   check-agent <agentAddr>                    - Check if address is authorized agent");
    console.log("   freeze <investorAddr>                      - Freeze investor account");
    console.log("   unfreeze <investorAddr>                    - Unfreeze investor account");
    console.log("   balance <address>                          - Check token balance");
    console.log("   total-supply                               - Check total token supply");
    console.log("   transfer <toAddr> <amount>                 - Transfer tokens");
    console.log("   info                                       - Show system information");
    console.log("");
    console.log("💡 Example: npx hardhat run scripts/interact.js --network alastria info");
    return;
  }

  // Get network and diamond address
  const networkName = network.name;
  console.log("🌐 Network:", networkName);
  
  let diamondAddress;
  let deploymentInfo = null;
  
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  const deploymentFile = path.join(deploymentsDir, `${networkName}-deployment.json`);
  
  if (fs.existsSync(deploymentFile)) {
    deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, 'utf8'));
    diamondAddress = deploymentInfo.contracts.Diamond;
    console.log("📄 Using deployment file:", deploymentFile);
  } else {
    // For Alastria or manual interaction, use the known address
    if (networkName === 'alastria') {
      diamondAddress = "0x8E96e3F80aF9c715C90d35BFFFAA32d330C69528";
      console.log("📍 Using Alastria address:", diamondAddress);
    } else {
      throw new Error(`❌ No deployment file found for ${networkName}. Please deploy first.`);
    }
  }

  console.log("🏛️  Diamond Address:", diamondAddress);

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
    console.log(`⚡ Executing command: ${command} ${cmdArgs.join(' ')}\n`);
    
    switch (command) {
      case "setup-issuer":
        if (cmdArgs.length < 2) {
          console.log("❌ Usage: setup-issuer <issuerAddress> <topicId>");
          return;
        }
        await setupIssuer(trustedIssuers, cmdArgs[0], cmdArgs[1]);
        break;
      
      case "register-investor":
        if (cmdArgs.length < 2) {
          console.log("❌ Usage: register-investor <investorAddr> <identityAddr>");
          return;
        }
        await registerInvestor(identity, cmdArgs[0], cmdArgs[1]);
        break;
      
      case "mint":
        if (cmdArgs.length < 2) {
          console.log("❌ Usage: mint <recipientAddr> <amount>");
          return;
        }
        await mintTokens(token, cmdArgs[0], cmdArgs[1]);
        break;
      
      case "set-agent":
        if (cmdArgs.length < 2) {
          console.log("❌ Usage: set-agent <agentAddr> <true/false>");
          return;
        }
        await setAgent(roles, cmdArgs[0], cmdArgs[1]);
        break;
      
      case "check-agent":
        if (cmdArgs.length < 1) {
          console.log("❌ Usage: check-agent <agentAddr>");
          return;
        }
        await checkAgent(roles, cmdArgs[0]);
        break;
      
      case "freeze":
        if (cmdArgs.length < 1) {
          console.log("❌ Usage: freeze <investorAddr>");
          return;
        }
        await freezeAccount(token, cmdArgs[0]);
        break;
      
      case "unfreeze":
        if (cmdArgs.length < 1) {
          console.log("❌ Usage: unfreeze <investorAddr>");
          return;
        }
        await unfreezeAccount(token, cmdArgs[0]);
        break;
      
      case "balance":
        if (cmdArgs.length < 1) {
          console.log("❌ Usage: balance <address>");
          return;
        }
        await checkBalance(token, cmdArgs[0]);
        break;
      
      case "total-supply":
        await checkTotalSupply(token);
        break;
      
      case "transfer":
        if (cmdArgs.length < 2) {
          console.log("❌ Usage: transfer <toAddr> <amount>");
          return;
        }
        await transferTokens(token, cmdArgs[0], cmdArgs[1]);
        break;
      
      case "info":
        await showSystemInfo(token, roles, identity, compliance);
        break;
      
      default:
        console.log(`❌ Unknown command: ${command}`);
        console.log("💡 Run without arguments to see available commands");
        return;
    }
    
  } catch (error) {
    console.error("❌ Command failed:", error.message);
    throw error;
  }
}

// ========================================
// COMMAND IMPLEMENTATIONS
// ========================================

async function setupIssuer(trustedIssuers, issuerAddress, topicId) {
  console.log(`🤝 Setting up trusted issuer...`);
  console.log(`   Issuer: ${issuerAddress}`);
  console.log(`   Topic ID: ${topicId}`);
  
  const tx = await trustedIssuers.addTrustedIssuer(issuerAddress, parseInt(topicId));
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Trusted issuer added successfully!`);
}

async function registerInvestor(identity, investorAddr, identityAddr) {
  console.log(`🆔 Registering investor identity...`);
  console.log(`   Investor: ${investorAddr}`);
  console.log(`   Identity: ${identityAddr}`);
  
  const tx = await identity.registerIdentity(investorAddr, identityAddr);
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Investor identity registered successfully!`);
}

async function mintTokens(token, recipientAddr, amount) {
  console.log(`💰 Minting tokens...`);
  console.log(`   Recipient: ${recipientAddr}`);
  console.log(`   Amount: ${amount} tokens`);
  
  const amountWei = ethers.parseEther(amount);
  const tx = await token.mint(recipientAddr, amountWei);
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Tokens minted successfully!`);
}

async function setAgent(roles, agentAddr, status) {
  console.log(`🔐 Setting agent status...`);
  console.log(`   Agent: ${agentAddr}`);
  console.log(`   Status: ${status}`);
  
  const isAgent = status.toLowerCase() === 'true';
  const tx = await roles.setAgent(agentAddr, isAgent);
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Agent status updated successfully!`);
}

async function checkAgent(roles, agentAddr) {
  console.log(`🔍 Checking agent status...`);
  console.log(`   Address: ${agentAddr}`);
  
  const isAgent = await roles.isAgent(agentAddr);
  console.log(`   📊 Status: ${isAgent ? 'Agent' : 'Not an agent'}`);
}

async function freezeAccount(token, investorAddr) {
  console.log(`❄️  Freezing account...`);
  console.log(`   Address: ${investorAddr}`);
  
  const tx = await token.freeze(investorAddr);
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Account frozen successfully!`);
}

async function unfreezeAccount(token, investorAddr) {
  console.log(`🔥 Unfreezing account...`);
  console.log(`   Address: ${investorAddr}`);
  
  const tx = await token.unfreeze(investorAddr);
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Account unfrozen successfully!`);
}

async function checkBalance(token, address) {
  console.log(`💰 Checking balance...`);
  console.log(`   Address: ${address}`);
  
  const balance = await token.balanceOf(address);
  console.log(`   📊 Balance: ${ethers.formatEther(balance)} tokens`);
}

async function checkTotalSupply(token) {
  console.log(`📊 Checking total supply...`);
  
  const totalSupply = await token.totalSupply();
  console.log(`   📊 Total Supply: ${ethers.formatEther(totalSupply)} tokens`);
}

async function transferTokens(token, toAddr, amount) {
  console.log(`💸 Transferring tokens...`);
  console.log(`   To: ${toAddr}`);
  console.log(`   Amount: ${amount} tokens`);
  
  const amountWei = ethers.parseEther(amount);
  const tx = await token.transfer(toAddr, amountWei);
  console.log(`   📦 Transaction: ${tx.hash}`);
  await tx.wait();
  console.log(`   ✅ Tokens transferred successfully!`);
}

async function showSystemInfo(token, roles, identity, compliance) {
  console.log(`📋 System Information`);
  console.log("=".repeat(50));
  
  try {
    // Basic token info
    const name = await token.name();
    const symbol = await token.symbol();
    const decimals = await token.decimals();
    const totalSupply = await token.totalSupply();
    
    console.log(`📄 Token Name: ${name}`);
    console.log(`🔤 Token Symbol: ${symbol}`);
    console.log(`🔢 Decimals: ${decimals}`);
    console.log(`📊 Total Supply: ${ethers.formatEther(totalSupply)} tokens`);
    
    // Roles info
    const owner = await roles.owner();
    console.log(`👑 Owner: ${owner}`);
    
    // Try to get additional info if available
    try {
      const [signer] = await ethers.getSigners();
      const signerBalance = await token.balanceOf(signer.address);
      const isSignerAgent = await roles.isAgent(signer.address);
      
      console.log(`\n👤 Current Signer Info:`);
      console.log(`   Address: ${signer.address}`);
      console.log(`   Balance: ${ethers.formatEther(signerBalance)} tokens`);
      console.log(`   Is Agent: ${isSignerAgent}`);
    } catch (e) {
      // Ignore errors getting signer info
    }
    
  } catch (error) {
    console.log(`❌ Error getting system info: ${error.message}`);
  }
}

// Execute interaction
main()
  .then(() => {
    console.log("\n✨ Interaction completed successfully!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n❌ Interaction failed:");
    console.error(error);
    process.exit(1);
  });
