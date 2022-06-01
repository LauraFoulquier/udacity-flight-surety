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
    uint8 constant CONSENSUS = 4; //maximum number of registered airline before it goes to voting
    uint8 constant VOTING_RULE = 50; //% of participant airlines votes
    uint256 airlineCount = 0;
    uint256 constant AIRLINE_FEE = 10 ether;

    mapping (address => bool) authorizedContracts;
    mapping (address => Airline) private airlines;
    mapping (address => address[]) votes;

    struct Airline {
        bytes32 airlineName;
        bool isCandidate; // registration pending
        bool isRegistered; // registered but not paid the fee yet
        bool isParticipant; // has paid the 10 ether
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
        airlines[msg.sender] = Airline(name, false, true, true);
        votes[msg.sender].push(msg.sender);
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
    function isOperational() public view returns(bool) 
    {
        return operational;
    }

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus (bool mode) external requireContractOwner 
    {
        operational = mode;
    }

    function getAuthorizedContracts(address addr) view external returns (bool result)
    {
        return authorizedContracts[addr];
    } 

    function getAirlineCount() view external returns (uint256 count) 
    {
        return airlineCount;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
    
    /**
    * @dev Add account to authorized callers : contract Owner, Participant Airline or App contract
    */
    function _authorizeCaller(address contractAddress) external requireIsOperational requireContractOwner
    {
        authorizedContracts[contractAddress] = true;
    }

    /**
    * @dev Check an airline has been registered and paid the fee
    *
    */   
    function isAirlineParticipant(address airlineAddress) external view requireIsAuthorized
    returns(bool success)
    {
        return airlines[airlineAddress].isParticipant;
    }

    /**
    * @dev Check an airline has been registered 
    *
    */   
    function isAirlineRegistered(address airlineAddress) external view requireIsAuthorized
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
                                address newAirlineAddress,
                                bytes32 newAirlineName
                            )
                            public
                            requireIsOperational
                            requireIsAuthorized
                            returns (bool success)
    {
        if (airlineCount <= CONSENSUS)
        {
            registerValidatedAirline(newAirlineAddress, newAirlineName, msg.sender);
        }
        else
        {
            voteForRegisteringAirline(newAirlineAddress);
            registerIfEnoughVotes(newAirlineAddress, newAirlineName);
        }
        return true;
    }

    function registerValidatedAirline(address newAirlineAddress, bytes32 newAirlineName, address registeringParty) private 
    {
            airlines[newAirlineAddress] = Airline(newAirlineName, false, true, false);
            votes[newAirlineAddress].push(registeringParty);
            airlineCount++;
            emit AirlineRegistered(newAirlineAddress);
    }

    function voteForRegisteringAirline(address newAirlineAddress) private 
    {
        bool hasVoted = false;
        for (uint i=0; i< votes[newAirlineAddress].length; i++){
            if (votes[newAirlineAddress][i] == msg.sender)
            {
                hasVoted = true;
                break;
            }
        }
        if(!hasVoted)
        {
            votes[newAirlineAddress].push(msg.sender);
        }
    }

    function registerIfEnoughVotes(address newAirlineAddress, bytes32 newAirlineName) private 
    {
        uint256 numberOfVotesRequired = airlineCount*VOTING_RULE/100; //multiply by 50% (50/100)
        uint256 remainder = airlineCount*VOTING_RULE/100;
        if (remainder == 1) 
        {
            numberOfVotesRequired++;
        }
        if (votes[newAirlineAddress].length >= numberOfVotesRequired)
        {
            registerValidatedAirline(newAirlineAddress, newAirlineName, msg.sender);
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

