require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
module.exports = {
  solidity: "0.8.4",
  networks: {
    mumbai: {
      url: process.env.MUMBAI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGON_SCAN_KEY,
    },
  },
};
