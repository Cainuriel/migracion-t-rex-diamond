const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Diamond Pattern T-REX - New Architecture", function () {
  let diamond, token, roles, identity, compliance;
  let owner, agent, user1, user2;
  let diamondAddress;

  before(async function () {
    [owner, agent, user1, user2] = await ethers.getSigners();

    // Deploy DiamondCutFacet first
    const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
    const diamondCutFacet = await DiamondCutFacet.deploy();
    await diamondCutFacet.waitForDeployment();

    // Deploy Diamond contract with DiamondCutFacet address
    const Diamond = await ethers.getContractFactory("Diamond");
    diamond = await Diamond.deploy(await diamondCutFacet.getAddress());
    await diamond.waitForDeployment();
    diamondAddress = await diamond.getAddress();

    // Deploy all facets (new architecture)
    const TokenFacet = await ethers.getContractFactory("TokenFacet");
    const RolesFacet = await ethers.getContractFactory("RolesFacet");
    const IdentityFacet = await ethers.getContractFactory("IdentityFacet");
    const ComplianceFacet = await ethers.getContractFactory("ComplianceFacet");

    const tokenFacet = await TokenFacet.deploy();
    const rolesFacet = await RolesFacet.deploy();
    const identityFacet = await IdentityFacet.deploy();
    const complianceFacet = await ComplianceFacet.deploy();

    await tokenFacet.waitForDeployment();
    await rolesFacet.waitForDeployment();
    await identityFacet.waitForDeployment();
    await complianceFacet.waitForDeployment();

    // Get function selectors for new architecture
    const roleSelectors = [
      rolesFacet.interface.getFunction("initializeRoles").selector,
      rolesFacet.interface.getFunction("setAgent").selector,
      rolesFacet.interface.getFunction("isAgent").selector,
      rolesFacet.interface.getFunction("owner").selector,
      rolesFacet.interface.getFunction("transferOwnership").selector
    ];

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
      tokenFacet.interface.getFunction("unfreezeAccount").selector,
      tokenFacet.interface.getFunction("isFrozen").selector
    ];

    const identitySelectors = [
      identityFacet.interface.getFunction("registerIdentity").selector,
      identityFacet.interface.getFunction("updateIdentity").selector,
      identityFacet.interface.getFunction("updateCountry").selector,
      identityFacet.interface.getFunction("deleteIdentity").selector,
      identityFacet.interface.getFunction("isVerified").selector,
      identityFacet.interface.getFunction("getIdentity").selector,
      identityFacet.interface.getFunction("getInvestorCountry").selector
    ];

    const complianceSelectors = [
      complianceFacet.interface.getFunction("setMaxBalance").selector,
      complianceFacet.interface.getFunction("setMinBalance").selector,
      complianceFacet.interface.getFunction("setMaxInvestors").selector,
      complianceFacet.interface.getFunction("canTransfer").selector,
      complianceFacet.interface.getFunction("complianceRules").selector
    ];

    // Prepare cuts for diamond cut
    const FacetCutAction = { Add: 0, Replace: 1, Remove: 2 };
    
    const cuts = [
      {
        facetAddress: await rolesFacet.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: roleSelectors
      },
      {
        facetAddress: await tokenFacet.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: tokenSelectors
      },
      {
        facetAddress: await identityFacet.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: identitySelectors
      },
      {
        facetAddress: await complianceFacet.getAddress(),
        action: FacetCutAction.Add,
        functionSelectors: complianceSelectors
      }
    ];    // Deploy InitDiamond for new architecture initialization
    const InitDiamond = await ethers.getContractFactory("InitDiamond");
    const initDiamond = await InitDiamond.deploy();
    await initDiamond.waitForDeployment();    // Perform diamond cut with initialization
    const initData = initDiamond.interface.encodeFunctionData("init", [
      owner.address,
      "T-REX Token",
      "TREX"
    ]);

    // Use DiamondCutFacet to perform the cut
    const diamondCut = await ethers.getContractAt("DiamondCutFacet", diamondAddress);
    await diamondCut.diamondCut(cuts, await initDiamond.getAddress(), initData);

    // Create facet interfaces connected to diamond
    token = await ethers.getContractAt("TokenFacet", diamondAddress);
    roles = await ethers.getContractAt("RolesFacet", diamondAddress);
    identity = await ethers.getContractAt("IdentityFacet", diamondAddress);
    compliance = await ethers.getContractAt("ComplianceFacet", diamondAddress);
  });

  describe("New Architecture Tests", function () {
    it("should initialize with correct owner", async function () {
      expect(await roles.owner()).to.equal(owner.address);
    });

    it("should initialize token metadata correctly", async function () {
      expect(await token.name()).to.equal("T-REX Token");
      expect(await token.symbol()).to.equal("TREX");
      expect(await token.decimals()).to.equal(18);
      expect(await token.totalSupply()).to.equal(0);
    });

    it("should set and return agent status", async function () {
      await roles.setAgent(agent.address, true);
      expect(await roles.isAgent(agent.address)).to.equal(true);
    });

    it("should mint tokens as agent", async function () {
      await token.connect(agent).mint(user1.address, 1000);
      expect(await token.balanceOf(user1.address)).to.equal(1000);
      expect(await token.totalSupply()).to.equal(1000);
    });

    it("should transfer tokens", async function () {
      await token.connect(user1).transfer(user2.address, 200);
      expect(await token.balanceOf(user2.address)).to.equal(200);
      expect(await token.balanceOf(user1.address)).to.equal(800);
    });

    it("should freeze and unfreeze accounts", async function () {
      await token.connect(agent).freezeAccount(user1.address);
      expect(await token.isFrozen(user1.address)).to.equal(true);
      
      await token.connect(agent).unfreezeAccount(user1.address);
      expect(await token.isFrozen(user1.address)).to.equal(false);
    });

    it("should register identity", async function () {
      const mockIdentity = ethers.Wallet.createRandom().address;
      await identity.connect(agent).registerIdentity(user1.address, mockIdentity, 840); // US country code
      
      expect(await identity.getIdentity(user1.address)).to.equal(mockIdentity);
      expect(await identity.getInvestorCountry(user1.address)).to.equal(840);
    });

    it("should set compliance rules", async function () {
      await compliance.setMaxBalance(10000);
      await compliance.setMinBalance(100);
      await compliance.setMaxInvestors(1000);
      
      const rules = await compliance.complianceRules();
      expect(rules.maxBalance).to.equal(10000);
      expect(rules.minBalance).to.equal(100);
      expect(rules.maxInvestors).to.equal(1000);
    });

    it("should validate compliance for transfers", async function () {
      // Register identity for user2 to allow transfers
      const mockIdentity2 = ethers.Wallet.createRandom().address;
      await identity.connect(agent).registerIdentity(user2.address, mockIdentity2, 840);
      
      // Test compliance check
      const canTransfer = await compliance.canTransfer(user1.address, user2.address, 100);
      expect(canTransfer).to.equal(true);
    });
  });
});
