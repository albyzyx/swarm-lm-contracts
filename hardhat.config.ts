import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();
const { PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    scroll: {
      url: "https://scroll-mainnet.chainstacklabs.com",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      gas: 21000,
    },
    arbitrumTestnet: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      arbitrumTestnet: "BBUDX7I9QYPFGC4GRJS93T3Q2FGCJFDH9K",
    },
    customChains: [
      {
        network: "arbitrumTestnet",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://api-sepolia.arbiscan.io",
        },
      },
    ],
  },
};

export default config;
