// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @author  Mr. Muhammad Usman Khan, Mr. Syed Awais, Ms Uswa, Mr. Imran, Mr Faisal
/// @title (Medicince Supply Chain) - Medicine Sales and Counterfeit Medicine Verification System - Final Project for Blockchain BootCamp by MOIT

import "./MedicineToken.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/security/ReentrancyGuard.sol";

contract MedicineSupplyChain is ReentrancyGuard , AccessControl {
    
    address public owner;
    address immutable tokenCOntractAddress;
    uint256 minimumLotQuantity = 1000;
    MedicineToken private tokenContract;
    
     //Roles - for Access Control
    bytes32 private constant Manufacturer = keccak256("Manufacturer");
    bytes32 private constant Distributor = keccak256("Distributor");
    bytes32 private constant Pharmacy = keccak256("Pharmacy");

    //Medicine Category
    enum Category {
        OffTheCounter,
        PrescriptionOnly,
        Herbal,
        LifeSaving
    }
    
    // Define a mapping for medicines --- name => medicine -- Updated
    mapping(string => mapping(uint256 => Medicine)) medicines;
    //mapping for return requests
    mapping (string => mapping(uint256 => mapping (address => mapping (address => mapping (uint256 => bool))))) returnMedStatus; 
    //medName=>lotNumber=>addressOfRequestor=>addressOfReturnee=>quantityofReturn=>Status
    
    //this mapping struct will be needed for purchase and return medicines function
    struct mapQuantity {
        mapping(address => MedQuantity) distributorQuantity;
        mapping(address => MedQuantity) PharmacyQuantity;
        mapping(address => uint256) consumerQuantity;
    }
    
    // Define a struct for a Medicine
    struct Medicine {
        Category cat; 
        uint256 quantity; // will reamin fixed after lot is manufactured
        uint256 cirSupply;
        bool cirSuply;
        uint256 totalDistQty; //added cumulative sum for all distributor
        uint256 totalPharmQty; //added cumulative sum for all Pharm
        uint256 totalSoldQty; //added cumulative sum for total sold
        uint256 price;
        uint256 dateOfProduction; //added
        uint256 dateOfExpiry; // added
        mapQuantity qty; // to maintain medicine qty for dist, pharmacy and consumer
    }
    //added structure to be used in mapQuantity
    struct MedQuantity {
        uint256 medPurchased;
        uint256 medSold;
    }
    
    // Define events for actions
    
    event PharmacyAdded(address pharmacy);
    event DistributorAdded(address distributor);
    event MedicineVerified(uint256 lotNumber, string message);
    event MedicineReturned(uint256 lotNumber, uint256 quantity);
    event MedicineDestroyed(uint256 lotNumber, uint256 quantity);
    event MedicinePurchased(uint256 lotNumber, uint256 quantity, uint256 totalPrice);
    event MedicineAdded(uint256 lotNumber, string name, uint256 quantity, uint256 price);
    
    
    // Modifier to check role
    modifier onlyManufacturer() {
        require(
            hasRole(Manufacturer,tx.origin), 
            "Restricted to Manufacturer"
        );
        _;
    }

    modifier onlyDistributor() {
        require(
            hasRole(Distributor, tx.origin), 
            "Restricted to Distributor"
        );
        _;
    }
    modifier onlyPharmacy() {
        require(
            hasRole(Pharmacy, tx.origin), 
            "Restricted to Pharmacy"
        );
        _;
    }
    modifier onlyConsumer() {
        require(!
            hasRole(Pharmacy, tx.origin) && !hasRole(Distributor, tx.origin) && !hasRole(Manufacturer,tx.origin), 
            "Restricted to Consumer"
        );
        _;
    }

    /// Store _tokenAddress and owner address to state variables at deployment
    /// @param _tokenAddress of token contract
    /// @dev _tokenAddress is address to token contract and the address used to deploy the contract is the owner of this contract

    constructor(address _tokenAddress) {
        owner = msg.sender;
        _grantRole(Manufacturer, owner);
        tokenCOntractAddress = _tokenAddress;  
        // Initialize the token, adjust the parameters as needed
        tokenContract =  MedicineToken(_tokenAddress);
    }

    
    /// Stores / Update minted token _amount to manufacturer balance.
    /// @param _amount of tokens to be minted
    /// @dev update the amount of token balance of manufacturer 

    function mintTokens(uint256 _amount) external onlyManufacturer() {
        unchecked {
            uint _approveAmount = _amount + tokenContract.getBalance(); 
            tokenContract.approve(_approveAmount); 
        }

        tokenContract.mint(owner, _amount);
    }

    /// Transfers _amount to caller/purchaser from manufacturer.
    /// @param _amount of tokens to be transferred 
    /// @dev update token balances of manufacturer and purchaser/caller. Transfers equivalent eth to contract

    function purchaseTokens(uint256 _amount) external nonReentrant payable {
        require(
            msg.value == _amount && _amount != 0, 
            "Invalid Amount"
        );

        require(
            tx.origin != owner,
            "Invalid Caller"
        );
        // Transfer tokens from manufacturer to distributor
        tokenContract.transferFrom(owner, tx.origin, _amount);
    }

    
    /// Transfers token _amount from caller/seller to manufacturer.
    /// @param _amount of tokens to be transferred 
    /// @dev update token balances of manufacturer and purchaser/caller and transfer equivalent eth to caller/seller from contract

    function withDraw (uint256 _amount) external nonReentrant {
        require(
            tx.origin != owner, 
            "Invalid Caller"
        );

        require(
            msg.sender != address(this), 
            "Invalid Caller"
        );

        require(
            address(this).balance >= _amount, 
            "Insufficient Funds"
        );

        require(
            _amount != 0, 
            "Invalid Amount"
        );

        require(
            tokenContract.balanceOf(tx.origin) >= _amount,
            "Insufficient Funds"
        );

        // Transfer tokens from manufacturer to distributor
        tokenContract.approve(_amount);
        tokenContract.transferFrom(tx.origin, owner, _amount); // transfer tokens to owner i.e. Manufacturer
        payable(tx.origin).transfer(_amount); //pay ether to caller address from contract
        tokenContract.approve(0);
    }

    
    /// Store manufactured medicine lot in Medicine Struct and State Variables
    /// @param _name, _lotNumber,_cat, _quantity, _price, _dateOfProduction, _dateofExpiry for manufacturer lot to be added
    /// @dev adds new lot of medicine by Maufacturer
    
    function addMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint8 _cat,
        uint256 _quantity,
        uint256 _price,
        uint256 _dateOfProduction,
        uint256 _dateofExpiry
        ) external onlyManufacturer() {

        //add check if this lot is not already added
        Medicine storage med = medicines[_name][_lotNumber];
        require(
            _dateofExpiry >= _dateOfProduction,
            "Invalid Med Details"
        );

        require(
            _price > 0,
            "Invalid Med Details"
        );

        require(
            _quantity >= minimumLotQuantity,
            "Invalid Quanity"
        );

        require(
            med.quantity == 0,
            "Duplicate Request"
        );

        Category c;
        
        if (_cat==0) {
            c = Category.OffTheCounter;
        }
        else if(_cat==1){
            c = Category.PrescriptionOnly;
        }
        else if(_cat==2){
            c = Category.Herbal;
        }
        else if(_cat==3) {
            c = Category.LifeSaving;
        }
        
        medicines[_name][_lotNumber].cat = c;
        medicines[_name][_lotNumber].quantity = _quantity;
        medicines[_name][_lotNumber].cirSupply = 0;
        medicines[_name][_lotNumber].cirSuply=false;
        medicines[_name][_lotNumber].totalDistQty = 0;
        medicines[_name][_lotNumber].totalPharmQty = 0;
        medicines[_name][_lotNumber].totalSoldQty = 0;
        medicines[_name][_lotNumber].price = _price;
        medicines[_name][_lotNumber].dateOfProduction = _dateOfProduction;
        medicines[_name][_lotNumber].dateOfExpiry = _dateofExpiry;
        emit MedicineAdded(_lotNumber, _name, _quantity, _price); 
    }


    /// Updates destroyed quantities of medicine lot in Medicine Struct and State Variables
    /// @param _name, _lotNumber, _quantity of medicine to be destoryed
    /// @dev update respective lot of medicine by Maufacturer in case provided medicine quantity is destroyed due to expiry or bad lot
    
    function destroyMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity
        ) external onlyManufacturer() {
        
        require (
            _quantity != 0,
            "Invalid Quantity"
        );

        Medicine storage med = medicines[_name][_lotNumber];

        require(
            med.quantity - (med.cirSupply + med.totalSoldQty) >= _quantity,
            "Invalid Quantity"
        ); //updated

        med.quantity -= _quantity;
        emit MedicineDestroyed(_lotNumber, _quantity);
    }
    

    /// Updates and Store purchased medicine lot in Medicine Struct and State Variables by distributer
    /// @param _name, _lotNumber of lot to be purchased
    /// @dev Distributor will puchase complete lot of specified medicine. Transfers equivalent tokens to owner

    function purchaseMedicineLot (
        string memory _name,
        uint256 _lotNumber
        ) external nonReentrant onlyDistributor() {

        Medicine storage med = medicines[_name][_lotNumber];
        
        require(
            med.quantity != med.cirSupply,
            "Invalid Medicine"
        );
        
        unchecked {
            //FRONTEND check if lot number and med exists
            uint256 totalPrice = med.price * med.quantity;
            medicines[_name][_lotNumber].cirSuply=true;
            med.cirSupply += med.quantity;
            med.totalDistQty = med.quantity; //conmulative sum of qty purchased by all distributors
            med.qty.distributorQuantity[tx.origin].medPurchased =med.quantity; //update distributor quantity
            //distributor has to approve contract first to transfer to owner
            tokenContract.approve(totalPrice);
            tokenContract.transferFrom(tx.origin, owner, totalPrice);// Transfer tokens to Manufacturer
            tokenContract.approve(0);
            emit MedicinePurchased(_lotNumber, med.quantity, totalPrice);
        }
    }

    
    /// Stores and update purchased medicine quantity in Medicine Struct and State Variables by Pharmacy
    /// @param _name, _lotNumber, _quantity, _distributor  of medicine to be purchased
    /// @dev Pharmacy will puchase selected quanitity of specified medicine. Transfers equivalent tokens to Distributor

    function purchaseFromDistributor(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _distributor
        ) external nonReentrant onlyPharmacy() {
        
        require(
            hasRole(Distributor,_distributor), 
            "Invalid Address"
        );
        
        unchecked {

            Medicine storage med = medicines[_name][_lotNumber];
            uint256 DistQuantity = med.qty.distributorQuantity[_distributor].medPurchased-med.qty.distributorQuantity[_distributor].medSold;
            require(
                DistQuantity >= _quantity && _quantity != 0,
                "Invalid Quantity"
            );

            uint256 totalPrice = med.price * _quantity;
            med.qty.distributorQuantity[_distributor].medSold += _quantity;
            med.qty.PharmacyQuantity[tx.origin].medPurchased += _quantity; //update distributor quantity
            med.totalPharmQty += _quantity;
            med.totalDistQty -= _quantity;
            tokenContract.approve(totalPrice);
            tokenContract.transferFrom(tx.origin, _distributor, totalPrice); // Transfer tokens to distributer
            tokenContract.approve(0);
            emit MedicinePurchased(_lotNumber, _quantity, totalPrice);
        }
    }

    /// Stores and update purchased medicine quantity in Medicine Struct and State Variables by Consumer
    /// @param _name, _lotNumber, _quantity, _pharmacy  of medicine to be purchased
    /// @dev Consumer will puchase selected quanitity of specified medicine. Transfers equivalent tokens to Pharmacy

    function purchaseFromPharmacy(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _pharmacy
        )  external nonReentrant onlyConsumer() {

        require(
            hasRole(Pharmacy, _pharmacy),
            "Invalid Address"
        );

        Medicine storage med = medicines[_name][_lotNumber];
        require(
            verifyMedicine(_name,_lotNumber,_pharmacy),
            "Invalid Medicine"
        );

        unchecked {
            uint256 PharmQuantity = med.qty.PharmacyQuantity[_pharmacy].medPurchased - med.qty.PharmacyQuantity[_pharmacy].medSold;
            require(
                PharmQuantity >= _quantity && _quantity != 0,
                "Invalid Quantity"
            );

            uint256 totalPrice = med.price * _quantity;
            med.cirSupply -= _quantity; // updated
            med.qty.PharmacyQuantity[_pharmacy].medSold += _quantity; //update pharmacy quantity
            med.qty.consumerQuantity[tx.origin] += _quantity; //Update consumer quantity - can be used for returns
            med.totalSoldQty += _quantity;
            med.totalPharmQty -= _quantity;
            //Transfer will be called but we might face issue here
            //if tranferFrom is called then we need to authorize contract first to trnasfer the token on msg.sender behalf
            tokenContract.approve(totalPrice);
            tokenContract.transferFrom(tx.origin, _pharmacy, totalPrice); // Transfer tokens from customer to pharmacy
            tokenContract.approve(0);
            emit MedicinePurchased(_lotNumber, _quantity, totalPrice);
        }
    }

    
    /// Stores and  update retrned medicine quantity in Medicine Struct and State Variables by Distributor
    /// @param _name, _lotNumber, _quantity, _distributor  of medicine to be returned
    /// @dev Manufacturer can call this function after verification of returned by distributor. Transfers equivalent tokens to Distributor

    function returnMedicinebyManufacturer (
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _distributor
        ) external onlyManufacturer() {

        require(
            hasRole(Distributor, _distributor), 
            "Invalid Distributor"
        );

        //medName=>lotNumber=>addressOfRequestor=>addressOfReturnee=>quantityofReturn=>Status
        require(
            returnMedStatus[_name][_lotNumber][_distributor][owner][_quantity], 
            "Invalid Request"
        );

        unchecked {

            Medicine storage med = medicines[_name][_lotNumber];
            require(
                med.qty.distributorQuantity[_distributor].medPurchased - med.qty.distributorQuantity[_distributor].medSold  >= _quantity,
                "Invalid Quantity"
            );

            uint totalPrice = _quantity * med.price;
            med.cirSupply += _quantity;
            med.totalDistQty -= _quantity;
            med.qty.distributorQuantity[_distributor].medPurchased -= _quantity;
            tokenContract.transferFrom(owner, _distributor, totalPrice);
            delete returnMedStatus[_name][_lotNumber][_distributor][owner][_quantity];
            emit MedicineReturned(_lotNumber, _quantity);
        }
    }

    /// Store and update retrned medicine quantity in Medicine Struct and State Variables by Pharmacy
    /// @param _name, _lotNumber, _quantity, _pharmacy  of medicine to be returned
    /// @dev Distributor can call this function after verification of returned by Pharmacy. Transfers equivalent tokens to Pharmacy

    function returnMedicinebyDistributor(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _pharmacy
        ) external onlyDistributor() {

        require(
            returnMedStatus[_name][_lotNumber][_pharmacy][tx.origin][_quantity], 
            "Invalid Request"
        );

        unchecked {

            Medicine storage med = medicines[_name][_lotNumber];
            uint256 totalQuantity = med.qty.PharmacyQuantity[_pharmacy].medPurchased - med.qty.PharmacyQuantity[_pharmacy].medSold;
            require (
                hasRole(Pharmacy,_pharmacy),
                "Invalid Address"
            );

            require(
                totalQuantity >= _quantity,
                "Invalid Quantity"
            );
            
            uint totalPrice = _quantity * med.price;
        
            med.qty.distributorQuantity[tx.origin].medPurchased += _quantity;
            med.qty.distributorQuantity[tx.origin].medSold -= _quantity;
            med.qty.PharmacyQuantity[_pharmacy].medPurchased -= _quantity;

            med.totalDistQty += _quantity;
            med.totalPharmQty -= _quantity;
            delete returnMedStatus[_name][_lotNumber][_pharmacy][tx.origin][_quantity];
            tokenContract.approve(totalPrice);
            //there will be issue in transfer from here
            tokenContract.transferFrom(tx.origin, _pharmacy, totalPrice);
            tokenContract.approve(0);
            
            emit MedicineReturned(_lotNumber, _quantity);
        }
    }

    /// Store and update retrned medicine quantity in Medicine Struct and State Variables by consumer
    /// @param _name, _lotNumber, _quantity, _consumer  of medicine to be returned
    /// @dev Pharmacy can call this function after verification of returned by consumer. Transfers equivalent tokens to consumer

    function returnMedicinebyPharmacy(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _consumer
        ) public onlyPharmacy() {

        unchecked {
            require(
                returnMedStatus[_name][_lotNumber][_consumer][tx.origin][_quantity], 
                "Invalid Request"
            );

            Medicine storage med = medicines[_name][_lotNumber];
            require(
                med.qty.consumerQuantity[_consumer] >= _quantity && _quantity != 0,
                "Invalid Quantity"
            );

            require (
                hasRole(Pharmacy,tx.origin),
                "Invalid Address"
            );
            

            uint totalPrice = _quantity * med.price;
            
            med.qty.PharmacyQuantity[tx.origin].medPurchased += _quantity;
            med.qty.PharmacyQuantity[tx.origin].medSold -= _quantity;
            med.qty.consumerQuantity[_consumer] -= _quantity;
            
            med.totalPharmQty += _quantity;
            med.totalSoldQty -= _quantity;
            delete returnMedStatus[_name][_lotNumber][_consumer][tx.origin][_quantity];
            tokenContract.approve(totalPrice);
            //again transfer from issue here
            tokenContract.transferFrom(tx.origin, _consumer, totalPrice);
            tokenContract.approve(0);
            
            emit MedicineReturned(_lotNumber, _quantity);
        }
    }
    
    /// Store valid distributor's address to State Variables
    /// @param _distributor  address to be added
    /// @dev Manufacturer can call this function to add distrubutor

    function addValidDistributor(address _distributor) external onlyManufacturer() {
        
        require(
            hasRole(Distributor, _distributor), 
            "Duplicate Request"
        );

        require(
            _distributor != address(0),
            "Invalid Address"
        );
        _grantRole(Distributor, _distributor);
        emit DistributorAdded(_distributor);
    }

    /// Store valid pharmacy's address to State Variables
    /// @param _pharmacy  address to be added
    /// @dev Distributor can call this function to add pharmacy

    function addValidPharmacy(address _pharmacy) external onlyDistributor() {

        require(
            hasRole(Pharmacy, _pharmacy), 
            "Duplicate Request"
        );

        require(
            _pharmacy != address(0),
            "Invalid Address"
        );
        _grantRole(Pharmacy, _pharmacy);
        emit PharmacyAdded(_pharmacy);
    }
   
    /// Updates returned medicine quantity request in Med Struct
    /// @param _name, _lotNumber, _quantity, _retAddress  of medicine to be returned
    /// @dev Anyone can call this function to submit return request to mentioned return address. Handles all the stake holders
    
    function sendReturnRequest(
        string memory _name, 
        uint256 _lotNumber, 
        uint256 _quantity, 
        address _retAddress
        ) external {

        unchecked {
            Medicine storage med = medicines[_name][_lotNumber];
            require(
                tx.origin != owner,
                "Invalid Caller"
            );
            //Cannot Add multiple Return Requests at one time  to same Party, Wait till previous is accepted
            require(
                !(returnMedStatus[_name][_lotNumber][tx.origin][_retAddress][_quantity]), 
                "Duplicate Request"
            );
                    
            if(hasRole(Distributor, tx.origin)) {
                require(
                   _retAddress==owner,
                    "Invalid Adddress"
                );

                require(
                    med.qty.distributorQuantity[tx.origin].medPurchased - med.qty.distributorQuantity[tx.origin].medSold  >= _quantity,
                    "Invalid Quantity"
                );
                
                returnMedStatus[_name][_lotNumber][tx.origin][owner][_quantity] = true;
            }
            
            else if (hasRole(Pharmacy,tx.origin)) {
                require(
                    hasRole(Distributor, _retAddress) && med.qty.distributorQuantity[_retAddress].medPurchased > _quantity, 
                   "Invalid Adddress"
                );
                    
                uint256 totalQuantity = med.qty.PharmacyQuantity[tx.origin].medPurchased - med.qty.PharmacyQuantity[tx.origin].medSold;
                    
                require(
                    totalQuantity >= _quantity,
                    "Invalid Quantity"
                );

                returnMedStatus[_name][_lotNumber][tx.origin][_retAddress][_quantity] = true;
            }

            else {

                require(
                    hasRole(Pharmacy,_retAddress) && 
                    med.qty.PharmacyQuantity[_retAddress].medPurchased >= _quantity,
                    "Invalid Adddress"
                );
                   
                require(
                med.qty.consumerQuantity[tx.origin] >= _quantity,
                "Invalid Quantity"
                );
                    
                returnMedStatus[_name][_lotNumber][tx.origin][_retAddress][_quantity] = true;
            }

                
        }
    }
    
    /// Returns true if medicine is verified
    /// @param _name, _lotNumber, _quantity, _pharmacy  of medicine to be verified
    /// @dev Anyone can call this function to verify the medicine available in pharmacy

    function verifyMedicine(
        string memory _name,
        uint256 _lotNumber,
        address _pharmacy
        ) public nonReentrant returns (bool) {
        
        unchecked {
            Medicine storage med = medicines[_name][_lotNumber];
            bool check = true;
            string memory mesg = "Not Verified";
            if (med.dateOfExpiry >= block.timestamp) {
                mesg = "Expired";
                check = false;
            }
            else if(medicines[_name][_lotNumber].cirSuply == false){
                mesg = "Not in Circulation";//not purchased by distributor
                check = false;
            }
            else if (med.cirSupply == 0) {
                mesg = "No Longer in Circulation";//sold all to consumers
                check = false;
            }
            else if (med.qty.PharmacyQuantity[_pharmacy].medPurchased - med.qty.PharmacyQuantity[_pharmacy].medSold == 0) {
                mesg = "Not available";
                check = false;
            }
            emit MedicineVerified(_lotNumber, mesg);
            return check;
        }
    }

    /// Returns quantity of medicine available to caller
    /// @param _name, _lotNumber  of medicine
    /// @dev Anyone can call this function to get the medicine count available in pocession

    function getMedicineCount(
        string memory _name, 
        uint256 _lotNumber
        ) public view returns (uint256 qty) {
        
        Medicine storage med = medicines[_name][_lotNumber];
        
        unchecked {
            uint256 quantity;
            if(tx.origin == owner) {
                quantity = med.quantity - med.totalDistQty;
                return quantity;
            }
            else if(hasRole(Distributor, tx.origin)) {
                quantity = med.qty.distributorQuantity[tx.origin].medPurchased - med.qty.distributorQuantity[tx.origin].medSold;
            return quantity;
            }
            else if (hasRole(Pharmacy,tx.origin)) {
                quantity = med.qty.PharmacyQuantity[tx.origin].medPurchased - med.qty.PharmacyQuantity[tx.origin].medSold;
                return quantity;
            }
            else {
                return med.qty.consumerQuantity[tx.origin];
            }
        }
    }

    
}
