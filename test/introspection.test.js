const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("IEIP2535Introspection Implementation", function () {
  let diamond;
  let tokenFacet, rolesFacet, identityFacet, complianceFacet, claimTopicsFacet, trustedIssuersFacet;
  let deployer;

  beforeEach(async function () {
    [deployer] = await ethers.getSigners();

    // Deploy DiamondCutFacet
    const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
    const diamondCutFacet = await DiamondCutFacet.deploy();
    await diamondCutFacet.waitForDeployment();

    // Deploy Diamond
    const Diamond = await ethers.getContractFactory("Diamond");
    diamond = await Diamond.deploy(await diamondCutFacet.getAddress());
    await diamond.waitForDeployment();

    // Deploy all facets
    const TokenFacet = await ethers.getContractFactory("TokenFacet");
    const RolesFacet = await ethers.getContractFactory("RolesFacet");
    const IdentityFacet = await ethers.getContractFactory("IdentityFacet");
    const ComplianceFacet = await ethers.getContractFactory("ComplianceFacet");
    const ClaimTopicsFacet = await ethers.getContractFactory("ClaimTopicsFacet");
    const TrustedIssuersFacet = await ethers.getContractFactory("TrustedIssuersFacet");

    tokenFacet = await TokenFacet.deploy();
    rolesFacet = await RolesFacet.deploy();
    identityFacet = await IdentityFacet.deploy();
    complianceFacet = await ComplianceFacet.deploy();
    claimTopicsFacet = await ClaimTopicsFacet.deploy();
    trustedIssuersFacet = await TrustedIssuersFacet.deploy();

    await tokenFacet.waitForDeployment();
    await rolesFacet.waitForDeployment();
    await identityFacet.waitForDeployment();
    await complianceFacet.waitForDeployment();
    await claimTopicsFacet.waitForDeployment();
    await trustedIssuersFacet.waitForDeployment();
  });

  describe("Selector Introspection", function () {
    it("TokenFacet should return correct selectors", async function () {
      const selectors = await tokenFacet.selectorsIntrospection();
      
      // Verify we have the expected number of selectors (14)
      expect(selectors.length).to.equal(14);
      
      // Verify specific selectors exist
      const expectedSelectors = [
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
      
      // Check that all expected selectors are present
      for (const expectedSelector of expectedSelectors) {
        expect(selectors).to.include(expectedSelector);
      }
    });

    it("RolesFacet should return correct selectors", async function () {
      const selectors = await rolesFacet.selectorsIntrospection();
      
      expect(selectors.length).to.equal(5);
      
      const expectedSelectors = [
        rolesFacet.interface.getFunction("initializeRoles").selector,
        rolesFacet.interface.getFunction("transferOwnership").selector,
        rolesFacet.interface.getFunction("owner").selector,
        rolesFacet.interface.getFunction("setAgent").selector,
        rolesFacet.interface.getFunction("isAgent").selector
      ];
      
      for (const expectedSelector of expectedSelectors) {
        expect(selectors).to.include(expectedSelector);
      }
    });

    it("IdentityFacet should return correct selectors", async function () {
      const selectors = await identityFacet.selectorsIntrospection();
      
      expect(selectors.length).to.equal(7);
      
      const expectedSelectors = [
        identityFacet.interface.getFunction("registerIdentity").selector,
        identityFacet.interface.getFunction("updateIdentity").selector,
        identityFacet.interface.getFunction("updateCountry").selector,
        identityFacet.interface.getFunction("deleteIdentity").selector,
        identityFacet.interface.getFunction("isVerified").selector,
        identityFacet.interface.getFunction("getInvestorCountry").selector,
        identityFacet.interface.getFunction("getIdentity").selector
      ];
      
      for (const expectedSelector of expectedSelectors) {
        expect(selectors).to.include(expectedSelector);
      }
    });

    it("ComplianceFacet should return correct selectors", async function () {
      const selectors = await complianceFacet.selectorsIntrospection();
      
      expect(selectors.length).to.equal(5);
      
      const expectedSelectors = [
        complianceFacet.interface.getFunction("setMaxBalance").selector,
        complianceFacet.interface.getFunction("setMinBalance").selector,
        complianceFacet.interface.getFunction("setMaxInvestors").selector,
        complianceFacet.interface.getFunction("canTransfer").selector,
        complianceFacet.interface.getFunction("complianceRules").selector
      ];
      
      for (const expectedSelector of expectedSelectors) {
        expect(selectors).to.include(expectedSelector);
      }
    });

    it("ClaimTopicsFacet should return correct selectors", async function () {
      const selectors = await claimTopicsFacet.selectorsIntrospection();
      
      expect(selectors.length).to.equal(3);
      
      const expectedSelectors = [
        claimTopicsFacet.interface.getFunction("addClaimTopic").selector,
        claimTopicsFacet.interface.getFunction("removeClaimTopic").selector,
        claimTopicsFacet.interface.getFunction("getClaimTopics").selector
      ];
      
      for (const expectedSelector of expectedSelectors) {
        expect(selectors).to.include(expectedSelector);
      }
    });

    it("TrustedIssuersFacet should return correct selectors", async function () {
      const selectors = await trustedIssuersFacet.selectorsIntrospection();
      
      expect(selectors.length).to.equal(3);
      
      const expectedSelectors = [
        trustedIssuersFacet.interface.getFunction("addTrustedIssuer").selector,
        trustedIssuersFacet.interface.getFunction("removeTrustedIssuer").selector,
        trustedIssuersFacet.interface.getFunction("getTrustedIssuers").selector
      ];
      
      for (const expectedSelector of expectedSelectors) {
        expect(selectors).to.include(expectedSelector);
      }
    });

    it("All facets should implement IEIP2535Introspection", async function () {
      // Verify that all facets have the selectorsIntrospection function
      const facets = [tokenFacet, rolesFacet, identityFacet, complianceFacet, claimTopicsFacet, trustedIssuersFacet];
      
      for (const facet of facets) {
        expect(facet.interface.hasFunction("selectorsIntrospection")).to.be.true;
        
        // Verify the function signature matches IEIP2535Introspection
        const func = facet.interface.getFunction("selectorsIntrospection");
        expect(func.outputs.length).to.equal(1);
        expect(func.outputs[0].type).to.equal("bytes4[]");
        expect(func.stateMutability).to.equal("pure");
      }
    });

    it("Should return unique selectors across all facets", async function () {
      const allSelectors = [];
      const facets = [tokenFacet, rolesFacet, identityFacet, complianceFacet, claimTopicsFacet, trustedIssuersFacet];
      
      // Collect all selectors from all facets
      for (const facet of facets) {
        const selectors = await facet.selectorsIntrospection();
        allSelectors.push(...selectors);
      }
      
      // Check that all selectors are unique (no conflicts)
      const uniqueSelectors = [...new Set(allSelectors)];
      expect(uniqueSelectors.length).to.equal(allSelectors.length, "Found duplicate selectors across facets");
    });

    it("Selector introspection should be pure function", async function () {
      // Call multiple times and verify the result is consistent
      const selectors1 = await tokenFacet.selectorsIntrospection();
      const selectors2 = await tokenFacet.selectorsIntrospection();
      
      expect(selectors1.length).to.equal(selectors2.length);
      for (let i = 0; i < selectors1.length; i++) {
        expect(selectors1[i]).to.equal(selectors2[i]);
      }
    });
  });
});
