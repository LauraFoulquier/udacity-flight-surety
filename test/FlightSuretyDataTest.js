var Test = require('../config/testConfig.js');
const truffleAssert = require('truffle-assertions');
const ethers = require('ethers');

contract('Flight Surety Data Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData._authorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* FLIGHT SETUP                                                                 */
  /****************************************************************************************/

  describe('Setting up the Data Contract properly', () => {
    it('Once contract initialised, contract owner should be a registered flight participant', async() => {
        let check = await config.flightSuretyData.isAirlineParticipant.call(config.owner);
        assert.equal(check, true, "The contract has not been initialised correctly" )
        })

        it('Should not be possible for someone to change the contract operational if they are not the contract owner', async()=> {
            truffleAssert.fails( config.flightSuretyData.setOperatingStatus(false,  {from: config.firstAirline}),  truffleAssert.ErrorType.REVERT);
        })

        // it('Only the contract owner can change the operational status', async() => {
        //     await config.flightSuretyData.setOperatingStatus(false, {from: config.owner});
        //     let check = await config.flightSuretyData.isOperational();
        //     assert.equal(check, false, "The operational status of the contract was not modified");
        // })

    it('No one but the contract owner can authorize callers', () =>{
      truffleAssert.fails( config.flightSuretyData._authorizeCaller(config.testAddresses[2], {from: config.testAddresses[1]}));
    })

    it('Only the contract owner can authorize callers', async() =>{
      await config.flightSuretyData._authorizeCaller(config.testAddresses[2], {from: config.owner});
      let check = await config.flightSuretyData.getAuthorizedContracts.call(config.testAddresses[2]);
      assert.equal(check, true, "Account has not been authorized");
    })
  })

  describe('Register Airline', () => {
    it('before adding a new airline, the contract shoudl have initilisaed the first one',  async() => {
      let nb = await config.flightSuretyData.getAirlineCount.call();
      assert.equal(nb, 1, "Problem with number of airline counted");
    })
    
    it('The first airline is registered by the App', async() => {
      let checkAccess = await config.flightSuretyData.getAuthorizedContracts.call(config.flightSuretyApp.address);
      assert.equal(checkAccess, true, "App Account has not been authorized");

      await config.flightSuretyApp.registerAirline.call(config.firstAirline, config.firstAirlineName, {from: config.flightSuretyApp.address});
      let check = await config.flightSuretyData.isAirlineRegistered.call(config.firstAirline);
      assert.equal(check, true, "The first airline has not been registered" )
    })
  })

});
