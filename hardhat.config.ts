import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenvx from "@dotenvx/dotenvx";
import "solidity-coverage";
import "@openzeppelin/hardhat-upgrades";

dotenvx.config();

const config: HardhatUserConfig = {
   solidity: {
    compilers: [

      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    artifacts: "./artifacts",
  },  networks: {
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      accounts: process.env.ADMIN_WALLET_PRIV_KEY ? [process.env.ADMIN_WALLET_PRIV_KEY] : [],
      gasPrice: 400000000000,
      timeout: 120000, 
    },
    amoy: {
      url: "https://polygon-amoy.drpc.org",
      accounts: process.env.ADMIN_WALLET_PRIV_KEY ? [process.env.ADMIN_WALLET_PRIV_KEY] : [],
      gasPrice: 400000000000,
      timeout: 300000, 
    },
        taycan: {
      url: "http://5.250.188.118:8545",
      accounts: process.env.ADMIN_WALLET_PRIV_KEY ? [process.env.ADMIN_WALLET_PRIV_KEY] : [],
      timeout: 300000, 
    },
    alastria: {
      url: "http://108.142.237.13:8545",
      accounts: [
        process.env.ADMIN_WALLET_PRIV_KEY,
        process.env.INVESTOR1_PRIV_KEY,
        process.env.INVESTOR2_PRIV_KEY
      ].filter((key): key is string => !!key),
      gasPrice: 0, // Alastria es una red sin gas
      timeout: 300000,
    }
  },
};

export default config;
