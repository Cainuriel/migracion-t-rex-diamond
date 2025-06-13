const { ethers } = require("hardhat");

/**
 * Test script to verify BigInt serialization fix
 */
async function testSerialization() {
  console.log("🧪 Testing BigInt serialization fix...\n");

  // Helper function to convert BigInt values to strings for JSON serialization
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

  // Test configuration with BigInt values (similar to deploy script)
  const testConfig = {
    tokenName: "Test Token",
    tokenSymbol: "TEST",
    complianceRules: {
      maxBalance: ethers.parseEther("1000000"), // BigInt
      minBalance: ethers.parseEther("1000"),    // BigInt
      maxInvestors: 100                         // number
    },
    initialAgents: []
  };

  console.log("📋 Original config (with BigInt):");
  console.log("   Max Balance type:", typeof testConfig.complianceRules.maxBalance);
  console.log("   Min Balance type:", typeof testConfig.complianceRules.minBalance);
  console.log("   Max Balance value:", testConfig.complianceRules.maxBalance.toString());

  try {
    // This should fail
    console.log("\n❌ Testing direct JSON.stringify (should fail):");
    JSON.stringify(testConfig);
    console.log("   Unexpected: Direct serialization worked!");
  } catch (error) {
    console.log("   ✅ Expected error:", error.message);
  }

  try {
    // This should work
    console.log("\n✅ Testing with serializeBigInts function:");
    const serialized = serializeBigInts(testConfig);
    const jsonString = JSON.stringify(serialized, null, 2);
    
    console.log("   ✅ Serialization successful!");
    console.log("   Serialized max balance type:", typeof serialized.complianceRules.maxBalance);
    console.log("   Serialized max balance value:", serialized.complianceRules.maxBalance);
    
    // Test parsing back
    const parsed = JSON.parse(jsonString);
    console.log("   ✅ Parse back successful!");
    console.log("   Parsed max balance:", parsed.complianceRules.maxBalance);
    
    // Verify we can convert back to BigInt when needed
    const backToBigInt = BigInt(parsed.complianceRules.maxBalance);
    console.log("   ✅ Convert back to BigInt:", backToBigInt.toString());
    console.log("   ✅ Values match:", backToBigInt === testConfig.complianceRules.maxBalance);
    
  } catch (error) {
    console.log("   ❌ Unexpected error:", error.message);
  }

  console.log("\n🎉 BigInt serialization test completed!");
}

// Run test
testSerialization()
  .then(() => {
    console.log("\n✨ Test completed successfully!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n❌ Test failed:", error);
    process.exit(1);
  });
