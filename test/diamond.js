const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

let diamondAddress;

describe("Diamond Pattern T-REX", function () {
  let diamondCut, diamondLoupe, token, roles, identity, compliance;
  let owner, agent, user1, user2;

  before(async function () {
    [owner, agent, user1, user2] = await ethers.getSigners();

    const DiamondCutFacet = await ethers.getContractFactory("DiamondCutFacet");
    const cutFacet = await DiamondCutFacet.deploy();
    await cutFacet.waitForDeployment();

    const Diamond = await ethers.getContractFactory("Diamond");
    const diamond = await Diamond.deploy(owner.address, cutFacet.target);
    await diamond.waitForDeployment();
    diamondAddress = await diamond.getAddress();

    const DiamondLoupeFacet = await ethers.getContractFactory("DiamondLoupeFacet");
    const OwnershipFacet = await ethers.getContractFactory("OwnershipFacet");
    const TokenFacet = await ethers.getContractFactory("TokenFacet");
    const RolesFacet = await ethers.getContractFactory("RolesFacet");
    const IdentityFacet = await ethers.getContractFactory("IdentityFacet");
    const ComplianceFacet = await ethers.getContractFactory("ComplianceFacet");

    const facets = [
      [await DiamondLoupeFacet.deploy(), ["facetAddress(bytes4)"]],
      [await OwnershipFacet.deploy(), ["owner()", "transferOwnership(address)"]],
      [await TokenFacet.deploy(), ["name()", "symbol()", "totalSupply()", "balanceOf(address)", "transfer(address,uint256)", "mint(address,uint256)"]],
      [await RolesFacet.deploy(), ["initializeRoles(address)", "setAgent(address,bool)", "isAgent(address)"]],
      [await IdentityFacet.deploy(), ["registerIdentity(address,address,uint16)", "isVerified(address)"]],
      [await ComplianceFacet.deploy(), ["canTransfer(address,address,uint256)", "setMaxBalance(uint256)"]],
    ];

    const selectors = (contract) => Object.keys(contract.interface.functions).map(fn => contract.interface.getSighash(fn));
    const cuts = await Promise.all(facets.map(async ([instance, _]) => ({
      facetAddress: await instance.getAddress(),
      action: 0,
      functionSelectors: selectors(instance.interface)
    })));

    const diamondCutContract = await ethers.getContractAt("IDiamondCut", diamondAddress);
    const InitDiamond = await ethers.getContractFactory("InitDiamond");
    const init = await InitDiamond.deploy();
    await init.waitForDeployment();

    await diamondCutContract.diamondCut(
      cuts,
      await init.getAddress(),
      init.interface.encodeFunctionData("init")
    );

    token = await ethers.getContractAt("TokenFacet", diamondAddress);
    roles = await ethers.getContractAt("RolesFacet", diamondAddress);
    identity = await ethers.getContractAt("IdentityFacet", diamondAddress);
    compliance = await ethers.getContractAt("ComplianceFacet", diamondAddress);

    await roles.initializeRoles(owner.address);
    await roles.setAgent(agent.address, true);
  });

  it("should set and return agent status", async function () {
    expect(await roles.isAgent(agent.address)).to.equal(true);
  });

  it("should mint tokens as agent", async function () {
    await token.connect(agent).mint(user1.address, 1000);
    expect(await token.balanceOf(user1.address)).to.equal(1000);
  });

  it("should transfer tokens", async function () {
    await token.connect(user1).transfer(user2.address, 200);
    expect(await token.balanceOf(user2.address)).to.equal(200);
  });

  it("should register and verify identity", async function () {
        await identity.registerIdentity(user1.address, "0x1234567890abcdef1234567890abcdef12345678", 1);
        expect(await identity.isVerified(user1.address)).to.equal(true);
    });
    
    it("should enforce compliance rules", async function () {
        await compliance.setMaxBalance(500);
        await expect(token.connect(user2).transfer(user1.address, 600)).to.be.revertedWith("Transfer exceeds max balance");
    });
});
    
