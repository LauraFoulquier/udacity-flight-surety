pragma solidity ^0.8.1;

contract FlightSuretyData {

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    /**
    /* RELATED TO AIRLINES
     */
    uint256 private airlineCount = 0;
    uint256 constant AIRLINE_FEE = 10 ether;

    mapping (address => bool) authorizedContracts;
    mapping (address => Airline) private airlines;

    struct Airline {
        bytes32 airlineName;
        bool isCandidate; // registration pending
        bool isRegistered; // registered but not paid the fee yet
        bool isParticipant; // has paid the 10 ether
        address[] voters;
    }

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor(bytes32 name) public 
    {
        contractOwner = msg.sender;
        //init address list
        address[] memory t = new address[](1);
        t[0]= msg.sender;

        airlines[msg.sender] = Airline(name, false, true, true, t);
        airlineCount++;
    }

    /**
    * EVENTS
    */
    event AirlineRegistered(address);
    event AirlineParticipant(address);
    event AirlineCandidate(address);

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
    * @dev Modifier for registered airlines (and contract owner)
     */
    modifier requireIsAuthorized()
    {
        require(msg.sender == contractOwner || authorizedContracts[msg.sender], "Caller is not authorized");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
    
    /**
    * @dev Check an airline has been registered
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function isAirlineParticipant(address airlineAddress) external view
    returns(bool success)
    {
        return airlines[airlineAddress].isParticipant;
    }
   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                address airlineAddress,
                                bytes32 airlineName
                            )
                            public
                            requireIsOperational
                            requireIsAuthorized
                            returns (bool success)
    {
        if (airlineCount < 5)
        {
            //init address list
            address[] memory t = new address[](1);
            t[0]= msg.sender;

            airlines[airlineAddress] = Airline(airlineName, false, true, true, t);
            airlineCount++;

            emit AirlineRegistered(airlineAddress);
            return true;
        }
    }


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (                             
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            payable
    {
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    fallback() 
                            external 
                            payable 
    {
        fund();
    }


}

