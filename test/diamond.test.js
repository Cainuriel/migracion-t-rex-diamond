const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Diamond Pattern T-REX", function () {
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

    // Deploy all facets
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
    await complianceFacet.waitForDeployment();    // Get function selectors manually - more reliable approach
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
      tokenFacet.interface.getFunction("mint").selector,
      tokenFacet.interface.getFunction("burn").selector
    ];

    const identitySelectors = [
      identityFacet.interface.getFunction("registerIdentity").selector,
      identityFacet.interface.getFunction("updateIdentity").selector,
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
    ];

    // Deploy InitDiamond for initialization
    const InitDiamond = await ethers.getContractFactory("InitDiamond");
    const initDiamond = await InitDiamond.deploy();
    await initDiamond.waitForDeployment();

    // Use diamond as DiamondCut interface since it has the diamondCut function
    const diamondCut = await ethers.getContractAt("IDiamondCut", diamondAddress);
    
    // Perform diamond cut to add all facets
    await diamondCut.diamondCut(
      cuts,
      await initDiamond.getAddress(),
      initDiamond.interface.encodeFunctionData("init")
    );    // Get facet interfaces
    roles = await ethers.getContractAt("RolesFacet", diamondAddress);
    token = await ethers.getContractAt("TokenFacet", diamondAddress);
    identity = await ethers.getContractAt("IdentityFacet", diamondAddress);
    compliance = await ethers.getContractAt("ComplianceFacet", diamondAddress);

    // Initialize the system (try/catch in case it's already initialized)
    try {
      await roles.initializeRoles(owner.address);
    } catch (error) {
      console.log("Roles already initialized or InitDiamond handles initialization");
    }
  });

  it("should set and return agent status", async function () {
    await roles.setAgent(agent.address, true);
    expect(await roles.isAgent(agent.address)).to.equal(true);
  });

  it("should mint tokens as agent", async function () {
    await token.connect(agent).mint(user1.address, 1000);
    expect(await token.balanceOf(user1.address)).to.equal(1000);
  });

  it("should transfer tokens", async function () {
    await token.connect(user1).transfer(user2.address, 200);
    expect(await token.balanceOf(user2.address)).to.equal(200);
    expect(await token.balanceOf(user1.address)).to.equal(800);
  });

  it("should register and verify identity", async function () {
    // Register identity with a valid address
    const mockIdentityAddress = "0x1234567890123456789012345678901234567890";
    await identity.connect(agent).registerIdentity(user1.address, mockIdentityAddress, 1);
    
    // Check that identity was registered
    const userIdentity = await identity.getIdentity(user1.address);
    expect(userIdentity).to.equal(mockIdentityAddress);
  });
    
  it("should enforce compliance rules", async function () {
    await compliance.setMaxBalance(500);
    
    // Test that compliance rules are set
    const rules = await compliance.complianceRules();
    expect(rules.maxBalance).to.equal(500);
    
    // Test canTransfer function
    const canTransfer = await compliance.canTransfer(user2.address, user1.address, 600);
    expect(canTransfer).to.equal(false); // Should fail due to max balance rule
  });
});
