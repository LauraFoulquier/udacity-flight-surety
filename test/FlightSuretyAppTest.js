// var Test = require('../config/testConfig.js');
// const truffleAssert = require('truffle-assertions');
// const ethers = require('ethers');

// contract('Flight Surety App Tests', async (accounts) => {

//   var config;
//   before('setup contract', async () => {
//     config = await Test.Config(accounts);
//     //await config.flightSuretyData._authorizeCaller(config.flightSuretyApp.address);
//   });

//   describe('Can check the contract is operational', () => {
//     it('Once contract initialised, the contract should be operational',() => {
//         let check = config.flightSuretyApp.isOperational.call({from: config.owner});
//         assert.equal(check, true, "The contract has not been initialised correctly" )
//         })

//     it('Anyone can check if the contract is operational', ()=> {
//       let check = config.flightSuretyApp.isOperational.call({from: config.testAddresses[3]});
//       assert.equal(check, true, "The contract has not been initialised correctly" )
//       })
//     })
// });
