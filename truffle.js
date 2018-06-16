var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "";
module.exports = {
   networks: {
       development: {
           host: "localhost",
           port: 8545,
           network_id: "*" // Match any network id
        },
        ropsten: {
            provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/VF416V94qOwdHr98vLd4"),
            network_id: 3,
            gas: 4600000,
            gasPrice: 1000
        }
    }
};
