const { ethers } = require("hardhat");
const fs = require('fs');
const path = require('path');

/**
 * Helper function to convert BigInt values to strings for JSON serialization
 */
function serializeBigInts(obj) {
  if (typeof obj === 'bigint') {
    return obj.toString();
  } else if (Array.isArray(obj)) {
    return obj.map(serializeBigInts);
  } else if (obj !== null && typeof obj === 'object') {
    const serialized = {};
    for (const [key, value] of Object.entries(obj)) {
      serialized[key] = serializeBigInts(value);
    }
    return serialized;
  }
  return obj;
}

async function main() {
  console.log("🚀 Starting T-REX Diamond Deployment...\n");
  
  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📋 Deploying contracts with account:", deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // ========================================
  // DEPLOYMENT CONFIGURATION
  // ========================================
  const config = {
    tokenName: "T-REX Security Token",
    tokenSymbol: "TREX",
    initialOwner: deployer.address,
    // Add any additional configuration here
    complianceRules: {
      maxBalance: ethers.parseEther("1000000"), // 1M tokens max per investor
      minBalance: ethers.parseEther("1000"),    // 1K tokens minimum investment
      maxInvestors: 100                         // Max 100 investors
    },    initialAgents: [
      // Add initial agent addresses here if needed
      // "0x...",
    ],
    // Set to true if you want the deployer/owner to be automatically registered as an agent
    // This allows the owner to perform token operations like mint/burn without additional setup
    ownerAsAgent: true
  };

  console.log("⚙️  Deployment Configuration:");
  console.log("   Token Name:", config.tokenName);
  console.log("   Token Symbol:", config.tokenSymbol);
  console.log("   Initial Owner:", config.initialOwner);
  console.log("   Max Balance per Investor:", ethers.formatEther(config.complianceRules.maxBalance), "tokens");
  console.log("   Min Investment:", ethers.formatEther(config.complianceRules.minBalance), "tokens");
  console.log("   Max Investors:", config.complianceRules.maxInvestors);
  console.log("");

  // ========================================
  // STEP 1: DEPLOY DIAMONDCUT FACET
  // ========================================
  console.log("1️⃣  Deploying DiamondCutFacet...");
  const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
  const diamondCutFacet = await DiamondCutFacet.deploy();
  await diamondCutFacet.waitForDeployment();
  const diamondCutFacetAddress = await diamondCutFacet.getAddress();
  console.log("   ✅ DiamondCutFacet deployed to:", diamondCutFacetAddress);

  // ========================================
  // STEP 2: DEPLOY DIAMOND CONTRACT
  // ========================================
  console.log("\n2️⃣  Deploying Diamond contract...");
  const Diamond = await ethers.getContractFactory("Diamond");
  const diamond = await Diamond.deploy(diamondCutFacetAddress);
  await diamond.waitForDeployment();
  const diamondAddress = await diamond.getAddress();
  console.log("   ✅ Diamond deployed to:", diamondAddress);

  // ========================================
  // STEP 3: DEPLOY ALL FACETS
  // ========================================
  console.log("\n3️⃣  Deploying Facets...");
  
  // Deploy TokenFacet
  console.log("   📄 Deploying TokenFacet...");
  const TokenFacet = await ethers.getContractFactory("TokenFacet");
  const tokenFacet = await TokenFacet.deploy();
  await tokenFacet.waitForDeployment();
  const tokenFacetAddress = await tokenFacet.getAddress();
  console.log("   ✅ TokenFacet deployed to:", tokenFacetAddress);

  // Deploy RolesFacet
  console.log("   🔐 Deploying RolesFacet...");
  const RolesFacet = await ethers.getContractFactory("RolesFacet");
  const rolesFacet = await RolesFacet.deploy();
  await rolesFacet.waitForDeployment();
  const rolesFacetAddress = await rolesFacet.getAddress();
  console.log("   ✅ RolesFacet deployed to:", rolesFacetAddress);

  // Deploy IdentityFacet
  console.log("   🆔 Deploying IdentityFacet...");
  const IdentityFacet = await ethers.getContractFactory("IdentityFacet");
  const identityFacet = await IdentityFacet.deploy();
  await identityFacet.waitForDeployment();
  const identityFacetAddress = await identityFacet.getAddress();
  console.log("   ✅ IdentityFacet deployed to:", identityFacetAddress);

  // Deploy ComplianceFacet
  console.log("   ⚖️  Deploying ComplianceFacet...");
  const ComplianceFacet = await ethers.getContractFactory("ComplianceFacet");
  const complianceFacet = await ComplianceFacet.deploy();
  await complianceFacet.waitForDeployment();
  const complianceFacetAddress = await complianceFacet.getAddress();
  console.log("   ✅ ComplianceFacet deployed to:", complianceFacetAddress);

  // Deploy ClaimTopicsFacet
  console.log("   📋 Deploying ClaimTopicsFacet...");
  const ClaimTopicsFacet = await ethers.getContractFactory("ClaimTopicsFacet");
  const claimTopicsFacet = await ClaimTopicsFacet.deploy();
  await claimTopicsFacet.waitForDeployment();
  const claimTopicsFacetAddress = await claimTopicsFacet.getAddress();
  console.log("   ✅ ClaimTopicsFacet deployed to:", claimTopicsFacetAddress);

  // Deploy TrustedIssuersFacet
  console.log("   🤝 Deploying TrustedIssuersFacet...");
  const TrustedIssuersFacet = await ethers.getContractFactory("TrustedIssuersFacet");
  const trustedIssuersFacet = await TrustedIssuersFacet.deploy();
  await trustedIssuersFacet.waitForDeployment();
  const trustedIssuersFacetAddress = await trustedIssuersFacet.getAddress();
  console.log("   ✅ TrustedIssuersFacet deployed to:", trustedIssuersFacetAddress);

  // ========================================
  // STEP 4: DEPLOY INITIALIZATION CONTRACT
  // ========================================
  console.log("\n4️⃣  Deploying InitDiamond...");
  const InitDiamond = await ethers.getContractFactory("InitDiamond");
  const initDiamond = await InitDiamond.deploy();
  await initDiamond.waitForDeployment();
  const initDiamondAddress = await initDiamond.getAddress();
  console.log("   ✅ InitDiamond deployed to:", initDiamondAddress);

  // ========================================
  // STEP 5: PREPARE FUNCTION SELECTORS
  // ========================================
  console.log("\n5️⃣  Preparing function selectors...");

  // RolesFacet selectors
  const roleSelectors = [
    rolesFacet.interface.getFunction("initializeRoles").selector,
    rolesFacet.interface.getFunction("setAgent").selector,
    rolesFacet.interface.getFunction("isAgent").selector,
    rolesFacet.interface.getFunction("owner").selector,
    rolesFacet.interface.getFunction("transferOwnership").selector
  ];

  // TokenFacet selectors
  const tokenSelectors = [
    tokenFacet.interface.getFunction("name").selector,
    tokenFacet.interface.getFunction("symbol").selector,
    tokenFacet.interface.getFunction("decimals").selector,
    tokenFacet.interface.getFunction("totalSupply").selector,
    tokenFacet.interface.getFunction("balanceOf").selector,
    tokenFacet.interface.getFunction("transfer").selector,
    tokenFacet.interface.getFunction("approve").selector,
    tokenFacet.interface.getFunction("transferFrom").selector,
    tokenFacet.interface.getFunction("allowance").selector,
    tokenFacet.interface.getFunction("mint").selector,
    tokenFacet.interface.getFunction("burn").selector,
    tokenFacet.interface.getFunction("forceTransfer").selector,
    tokenFacet.interface.getFunction("freezeAccount").selector,
    tokenFacet.interface.getFunction("unfreezeAccount").selector
  ];

  // IdentityFacet selectors
  const identitySelectors = [
    identityFacet.interface.getFunction("registerIdentity").selector,
    identityFacet.interface.getFunction("updateIdentity").selector,
    identityFacet.interface.getFunction("updateCountry").selector,
    identityFacet.interface.getFunction("deleteIdentity").selector,
    identityFacet.interface.getFunction("isVerified").selector,
    identityFacet.interface.getFunction("getIdentity").selector,
    identityFacet.interface.getFunction("getInvestorCountry").selector
  ];

  // ComplianceFacet selectors
  const complianceSelectors = [
    complianceFacet.interface.getFunction("setMaxBalance").selector,
    complianceFacet.interface.getFunction("setMinBalance").selector,
    complianceFacet.interface.getFunction("setMaxInvestors").selector,
    complianceFacet.interface.getFunction("canTransfer").selector,
    complianceFacet.interface.getFunction("complianceRules").selector
  ];

  // ClaimTopicsFacet selectors
  const claimTopicsSelectors = [
    claimTopicsFacet.interface.getFunction("addClaimTopic").selector,
    claimTopicsFacet.interface.getFunction("removeClaimTopic").selector,
    claimTopicsFacet.interface.getFunction("getClaimTopics").selector
  ];

  // TrustedIssuersFacet selectors
  const trustedIssuersSelectors = [
    trustedIssuersFacet.interface.getFunction("addTrustedIssuer").selector,
    trustedIssuersFacet.interface.getFunction("removeTrustedIssuer").selector,
    trustedIssuersFacet.interface.getFunction("getTrustedIssuers").selector
  ];

  console.log("   ✅ Function selectors prepared");

  // ========================================
  // STEP 6: PREPARE DIAMOND CUT
  // ========================================
  console.log("\n6️⃣  Preparing Diamond Cut...");
  
  const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 };
  
  const cuts = [
    {
      facetAddress: rolesFacetAddress,
      action: FacetCutAction.Add,
      functionSelectors: roleSelectors
    },
    {
      facetAddress: tokenFacetAddress,
      action: FacetCutAction.Add,
      functionSelectors: tokenSelectors
    },
    {
      facetAddress: identityFacetAddress,
      action: FacetCutAction.Add,
      functionSelectors: identitySelectors
    },
    {
      facetAddress: complianceFacetAddress,
      action: FacetCutAction.Add,
      functionSelectors: complianceSelectors
    },
    {
      facetAddress: claimTopicsFacetAddress,
      action: FacetCutAction.Add,
      functionSelectors: claimTopicsSelectors
    },
    {
      facetAddress: trustedIssuersFacetAddress,
      action: FacetCutAction.Add,
      functionSelectors: trustedIssuersSelectors
    }
  ];

  console.log("   ✅ Diamond cuts prepared for", cuts.length, "facets");

  // ========================================
  // STEP 7: EXECUTE DIAMOND CUT
  // ========================================
  console.log("\n7️⃣  Executing Diamond Cut...");
  
  const diamondCut = await ethers.getContractAt("IDiamondCut", diamondAddress);
  
  const tx = await diamondCut.diamondCut(
    cuts,
    initDiamondAddress,
    initDiamond.interface.encodeFunctionData("init")
  );
  
  console.log("   📦 Transaction hash:", tx.hash);
  await tx.wait();
  console.log("   ✅ Diamond Cut executed successfully!");

  // ========================================
  // STEP 8: INITIALIZE SYSTEM
  // ========================================
  console.log("\n8️⃣  Initializing T-REX System...");

  // Get contract interfaces
  const roles = await ethers.getContractAt("RolesFacet", diamondAddress);
  const token = await ethers.getContractAt("TokenFacet", diamondAddress);
  const identity = await ethers.getContractAt("IdentityFacet", diamondAddress);
  const compliance = await ethers.getContractAt("ComplianceFacet", diamondAddress);
  const claimTopics = await ethers.getContractAt("ClaimTopicsFacet", diamondAddress);
  const trustedIssuers = await ethers.getContractAt("TrustedIssuersFacet", diamondAddress);

  // Verify initialization
  console.log("   🔍 Verifying system initialization...");
  const currentOwner = await roles.owner();
  const tokenName = await token.name();
  const tokenSymbol = await token.symbol();
    console.log("   ✅ Owner:", currentOwner);
  console.log("   ✅ Token Name:", tokenName);
  console.log("   ✅ Token Symbol:", tokenSymbol);

  // Register owner as agent if requested
  if (config.ownerAsAgent) {
    console.log("   👤 Registering owner as agent...");
    await roles.setAgent(deployer.address, true);
    console.log("   ✅ Owner registered as agent:", deployer.address);
  }

  // Set up initial agents if specified
  if (config.initialAgents.length > 0) {
    console.log("   👥 Setting up initial agents...");
    for (const agentAddress of config.initialAgents) {
      await roles.setAgent(agentAddress, true);
      console.log("   ✅ Agent added:", agentAddress);
    }
  } else {
    console.log("   💡 No additional initial agents configured.");
  }

  // Set up compliance rules
  console.log("   ⚖️  Setting up compliance rules...");
  if (config.complianceRules.maxBalance > 0) {
    await compliance.setMaxBalance(config.complianceRules.maxBalance);
    console.log("   ✅ Max balance set to:", ethers.formatEther(config.complianceRules.maxBalance), "tokens");
  }
  
  if (config.complianceRules.minBalance > 0) {
    await compliance.setMinBalance(config.complianceRules.minBalance);
    console.log("   ✅ Min balance set to:", ethers.formatEther(config.complianceRules.minBalance), "tokens");
  }
  
  if (config.complianceRules.maxInvestors > 0) {
    await compliance.setMaxInvestors(config.complianceRules.maxInvestors);
    console.log("   ✅ Max investors set to:", config.complianceRules.maxInvestors);
  }

  // Set up basic claim topics (KYC, AML)
  console.log("   📋 Setting up basic claim topics...");
  await claimTopics.addClaimTopic(1); // KYC
  await claimTopics.addClaimTopic(2); // AML
  console.log("   ✅ Basic claim topics added (KYC, AML)");

  // ========================================
  // STEP 9: DEPLOYMENT SUMMARY
  // ========================================
  console.log("\n🎉 T-REX Diamond Deployment Complete!\n");
  const deploymentInfo = {
    network: network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      Diamond: diamondAddress,
      DiamondCutFacet: diamondCutFacetAddress,
      TokenFacet: tokenFacetAddress,
      RolesFacet: rolesFacetAddress,
      IdentityFacet: identityFacetAddress,
      ComplianceFacet: complianceFacetAddress,
      ClaimTopicsFacet: claimTopicsFacetAddress,
      TrustedIssuersFacet: trustedIssuersFacetAddress,
      InitDiamond: initDiamondAddress
    },
    configuration: serializeBigInts(config)
  };

  console.log("📋 DEPLOYMENT SUMMARY");
  console.log("=".repeat(50));
  console.log("🏠 Main Diamond Contract:", diamondAddress);
  console.log("⚙️  Network:", network.name);
  console.log("👤 Deployer:", deployer.address);
  console.log("📅 Timestamp:", deploymentInfo.timestamp);
  console.log("");
  console.log("📄 FACET CONTRACTS:");
  console.log("   DiamondCutFacet:", diamondCutFacetAddress);
  console.log("   TokenFacet:", tokenFacetAddress);
  console.log("   RolesFacet:", rolesFacetAddress);
  console.log("   IdentityFacet:", identityFacetAddress);
  console.log("   ComplianceFacet:", complianceFacetAddress);
  console.log("   ClaimTopicsFacet:", claimTopicsFacetAddress);
  console.log("   TrustedIssuersFacet:", trustedIssuersFacetAddress);
  console.log("");
  console.log("🔧 CONFIGURATION:");
  console.log("   Token Name:", config.tokenName);
  console.log("   Token Symbol:", config.tokenSymbol);
  console.log("   Max Balance:", ethers.formatEther(config.complianceRules.maxBalance), "tokens");
  console.log("   Min Balance:", ethers.formatEther(config.complianceRules.minBalance), "tokens");
  console.log("   Max Investors:", config.complianceRules.maxInvestors);
  // ========================================
  // STEP 10: SAVE DEPLOYMENT INFO
  // ========================================
  console.log("\n💾 Saving deployment information...");
  
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }
  
  // Note: Using serializeBigInts to convert BigInt values to strings for JSON compatibility
  const deploymentFile = path.join(deploymentsDir, `${network.name}-deployment.json`);
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));
  console.log("   ✅ Deployment info saved to:", deploymentFile);

  // Create ABI file for easier interaction
  const abiFile = path.join(deploymentsDir, `${network.name}-diamond-abi.json`);
  const diamondABI = [
    ...tokenFacet.interface.fragments,
    ...rolesFacet.interface.fragments,
    ...identityFacet.interface.fragments,
    ...complianceFacet.interface.fragments,
    ...claimTopicsFacet.interface.fragments,
    ...trustedIssuersFacet.interface.fragments,
    ...diamondCutFacet.interface.fragments
  ].map(fragment => fragment.format('json')).map(json => JSON.parse(json));
  
  fs.writeFileSync(abiFile, JSON.stringify(diamondABI, null, 2));
  console.log("   ✅ Combined ABI saved to:", abiFile);

  console.log("\n✨ Deployment completed successfully!");
  console.log("🚀 Your T-REX Diamond is ready at:", diamondAddress);
  console.log("\n📚 Next steps:");
  console.log("   1. Set up trusted issuers for claim verification");
  console.log("   2. Configure additional compliance rules if needed");
  console.log("   3. Register the first investors");
  console.log("   4. Begin token operations");
  
  return deploymentInfo;
}

// Execute deployment
main()
  .then((deploymentInfo) => {
    console.log("\n🎊 Deployment script completed successfully!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  });
