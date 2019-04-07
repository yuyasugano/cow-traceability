App = {
  web3Provider: null,
  contracts: {},
  ipfs: {},

  init: async function() {
    // Init task
    App.initIpfs();
    return await App.initWeb3();
  },

  initIpfs: function() {
    App.ipfs = window.IpfsApi('localhost', '5001');
  },

  initWeb3: async function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    
    return App.initContract();
  },

  initContract: function() {
    $.getJSON('CowOwnership.json', function(artifact) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var OwnershipArtifact = artifact;
      App.contracts.CowOwnership = TruffleContract(OwnershipArtifact);

      // Set the provider for our contract
      App.contracts.CowOwnership.setProvider(App.web3Provider);

      // Use our contract to retrieve and handle cows
      return App.markRetrieved();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-submit', App.handleSubmit);
    $(document).on('click', '.btn-upload', App.handleUpload);
  },

  markRetrieved: function(cows, account) {
    var OwnershipInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        $("#txStatus").text(error).show();
      }

      var account = accounts[0];

      App.contracts.CowOwnership.deployed().then(function(instance) {
        OwnershipInstance = instance;

        // Execute to get cows by the account
        return OwnershipInstance.getCowsByOwner(account);
      }).then(function(ids) {
        $("#cows").empty();
        // if ids does not have length ignore this for loop
        for (i = 0; i < ids.length; i++) {

          // Look up cow details from the contract
          OwnershipInstance.getIdByCowNum(ids[i]).then(function(num) {
            OwnershipInstance.cows(num).then(function(cow) {
              // Using ES6's "template literals" to inject variables into the HTML
              // Append each one to our DOM

              OwnershipInstance.tokenURI(cow[0].c).then(function(hash) {
                var url  = "https://ipfs.io/ipfs/" + hash;

                $("#cows").append(`
                  <div class="card img-thumbnail mb-3">
                    <img class="card-img-top" src=${url} alt="example" width="100%" height="100%">
                    <div class="card-block">
                      <h4 class="card-title">${cow[3]} ${cow[0].c}</h4>
                      <h6 class="card-subtitle mb-2 text-muted">Birth: ${cow[2].c}</h6>
                      <p class="card-text">${cow[3]} ${cow[0].c} (${cow[4]}) was born from ${cow[1].c} on ${cow[2].c}.</p>
                      <p class="card-text"><small class="text-muted">Last updated 3 months ago</small></p>
                    </div>
                  </div>
                </div>
                `);
              }).catch(function(error) {
                $("#txStatus").text(error).show();
              });
            });
          });
        }
      }).catch(function(error) {
        $("#txStatus").text(error).show();
      });
    });
  },

  handleSubmit: function(event) {
    event.preventDefault();

    var id    = $('input:text[name="id"]').val();
    var type = $('input:text[name="type"]').val();
    var sex   = $('input:text[name="sex"]').val();
    var OwnershipInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        $("#txStatus").text(error).show();
      }

      var account = accounts[0];
      App.contracts.CowOwnership.deployed().then(function(instance) {
        OwnershipInstance = instance;

        // Show a transaction status
        $("#txStatus").text("Breeding new cow on the blockchain. This may take a while...");
        return OwnershipInstance.cowBirth(id, type, sex);
      }).then(function(result) {

        // Transaction was accepted into the blockchain, redraw the UI
        $("#txStatus").text("Successfully created " + type + " !").show();
        return App.markRetrieved();
      }).catch(function(error) {
        // Transaction returned with an error
        $("#txStatus").text(error).show();
      });
    });
  },

  handleUpload: function(event) {
    event.preventDefault();

    var tokenid = $('input:text[name="tokenid"]').val();
    var reader  = new window.FileReader();
    return App.saveIpfs(reader, tokenid);
  },

  saveIpfs: function(reader, tokenid) {
    var buf = buffer.Buffer(reader.result);
    App.ipfs.files.add(buf, function(error, result) {
      if (error) {
        console.log(error);
        return;
      }
      var OwnershipInstance;
      var hash = result[0].hash;
      var url = "https://ipfs.io/ipfs/" + hash;
      App.contracts.CowOwnership.deployed().then(function(instance) {
        OwnershipInstance = instance;

        // Call a setTokenURI function relavant hashed value
        return OwnershipInstance.setTokenURI(tokenid, hash);
      }).then(function(result) {

        // Transaction was accepted into the blockchain, redraw the UI
        $("#txStatus").text("Successfully uploaded " + tokenid + " !").show();
        return App.markRetrieved();
      }).catch(function(error) {
        // Transaction returned with an error
        $("#txStatus").text(error).show();
      });
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

