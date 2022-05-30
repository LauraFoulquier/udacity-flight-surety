pragma solidity ^0.8.1;

//import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    //using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    /* Related to airlines */
    uint256 private airlineCount = 0;
    uint256 constant AIRLINE_FEE = 10 ether;

    mapping (address => Airline) private airlines;
    mapping (address => address[]) private registeredAirlinesFunded;


    struct Airline {
        address airlineAddress;
        bool isRegistered;
        bool isParticipant; // has paid the 10 ether
        bool isPending; // registration pending (need to be voted in)
        address[] voters;
    }
    

    /* Related to flights */
    uint256 private flightCount = 0;

    /* constants */
    uint8 constant AIRLINE_THREASHOLD = 5;
    uint8 constant CONSENSUS_DIVISOR = 2;
    uint8 constant INSURANCE_MULTIPLIER = 150;

    uint256 constant PASSENGER_FEE = 1 ether;
    


    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    event AirlineRegistered(address); //airline added to registry but has not paid yet
    event AirlineParticipant(address); // airline has now paid

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor(address airlineAddress)  
    {
        contractOwner = msg.sender;
        registerAirline(airlineAddress);
    }

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

    modifier requireAirlineIsAuthorized()
    {
        require(msg.sender == contractOwner || airlines[msg.sender].isParticipant, "Caller is not authorized");
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
    function isAirlineRegistered(address airlineAddress) external view
    returns(bool success)
    {
        return airlines[airlineAddress].isRegistered;
    }

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                address airlineAddress   
                            )
                            public
                            requireIsOperational
                            requireAirlineIsAuthorized
                            returns (bool success)
    {
        require(airlines[airlineAddress].airlineAddress != airlineAddress, 'Airline already registered');

        //First airline to be added with initialisation or only added by authorized airline if less than 5
        if (airlineCount == 0 )
        {
            Airline storage airline = airlines[airlineAddress];
            airline.airlineAddress = airlineAddress;
            airline.isRegistered = true;
            airline.isParticipant = true;
            airline.isPending = false;
            airline.voters.push(msg.sender);
            airlineCount++;
            
            emit AirlineParticipant(airlineAddress);
            return true;
        }
        else if (airlineCount > 0 && airlineCount < 5)
        {
            Airline storage airline = airlines[airlineAddress];
            airline.airlineAddress = airlineAddress;
            airline.isRegistered = true;
            airline.isParticipant = false;
            airline.isPending = false;
            airline.voters.push(msg.sender);
            airlineCount++;
            
            emit AirlineRegistered(airlineAddress);
            return true;
        }
        else 
        // 5 or more airlines already registered
        {
            Airline storage airline = airlines[airlineAddress];
            airline.airlineAddress = airlineAddress;
            airline.isPending = true;
            airline.voters.push(msg.sender);
        }
    }

   /**
    * @dev Check if an airline is participan
    *
    */ 
    function isAirlineParticipant(address airlineAddress) external view requireAirlineIsAuthorized
    returns (bool success)
    {
        return airlines[airlineAddress].isParticipant;
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

