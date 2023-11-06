require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config();
const alchemyPrivateKey = process.env.alchemyPrivateKey;
const sopheliaPrivateKey = process.env.sopheliaPrivateKey;
const ethScanAPi = process.env.ethScan;

module.exports = {
  solidity: "0.8.21",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200, 
    },
  },
  networks: {
    sophelia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${alchemyPrivateKey}`, // To Interact with block chain, we delopy our contract with the interaction of alchemy
      // chainId: 12345, // This should be the chain ID of your network
      accounts: [sopheliaPrivateKey], // Add accounts if needed for testing
    }
  },
  etherscan: {
    apiKey: ethScanAPi
  }
};
