module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    live: {
      host: "133.242.150.97",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
