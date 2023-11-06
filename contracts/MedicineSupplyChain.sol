// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "./MedicineToken.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ReentrancyGuard.sol";

contract MedicineSupplyChain is ReentrancyGuard , AccessControl {
    address public owner;
    // Linking ERC20 token
    MedicineToken public tokenContract;
    address immutable tokenCOntractAddress;
    // Define roles

    //Medicine Category
    enum Category {
        OffTheCounter,
        PrescriptionOnly,
        Herbal,
        LifeSaving
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
    struct medQuantity {
        uint256 medPurchased;
        uint256 medSold;
    }

    //this mapping will be needed for purchase and return medicines function
    struct mapQuantity {
        mapping(address => medQuantity) distributorQuantity;
        mapping(address => medQuantity) PharmacyQuantity;
        mapping(address => uint256) consumerQuantity;
    }

    // Define a mapping for medicines --- name => medicine -- Updated
    mapping(string => mapping(uint256 => Medicine)) medicines;

    //mapping for return requests
    mapping (string => mapping(uint256 =>mapping (address => mapping (address => mapping (uint256 => bool))))) returnMedStatus; 
    //medName=>lotNumber=>addressOfRequestor=>addressOfReturnee=>quantityofReturn=>Status
    
    // Define events for actions
    event MedicineAdded(
        uint256 lotNumber,
        string name,
        uint256 quantity,
        uint256 price
    );
    event MedicinePurchased(
        uint256 lotNumber,
        uint256 quantity,
        uint256 totalPrice
    );

    event MedicineReturned(uint256 lotNumber, uint256 quantity);
    event MedicineVerified(uint256 lotNumber, string message);
    event DistributorAdded(address distributor);
    event PharmacyAdded(address pharmacy);
    event MedicineDestroyed(uint256 lotNumber, uint256 quantity);
    
    //Roles - for Access Control
    bytes32 public constant Manufacturer = keccak256("Manufacturer");
    bytes32 public constant Distributor = keccak256("Distributor");
    bytes32 public constant Pharmacy = keccak256("Pharmacy");


    uint256 minimumLotQuantity = 1000;
    // Constructor
    constructor(address _tokenAddress) {
        owner = msg.sender;
        _grantRole(Manufacturer, owner);
        tokenCOntractAddress = _tokenAddress;  
        // Initialize the token, adjust the parameters as needed
        tokenContract =  MedicineToken(_tokenAddress);
    }

    // Function to mint tokens (only manufacturer can do this)
    function mintTokens(uint256 _amount)
        public 
        onlyManufacturer() {
            uint _approveAmount = _amount + tokenContract.getBalance();
            tokenContract.approve(_approveAmount);
            tokenContract.mint(owner, _amount);
    }

    // Function to purchase tokens (pays in wei) 
    //Anyone can buy tokens - eth will be tranferred to contract
    function purchaseTokens(uint256 _amount) public payable {
        require(
            msg.value == _amount && _amount != 0, 
            "Incorrect payment amount"
        );

        require(
            tx.origin != owner,
            "Owner cannot purchase tokens he already owns"
        );
        // Transfer tokens from manufacturer to distributor
        tokenContract.transferFrom(owner, tx.origin, _amount);
    }

    //this functions enables distributor, pharmacy and consumer to sell their tokens to owner
    //the eth will be held in contract which will be transferred to called
    //the token selling amount will be transfered to owner
    function withDraw (uint256 _amount) external nonReentrant {
        require(
            tx.origin != owner, 
            "Owner Cannot withdraw funds from Contract"
        );

        require(
            msg.sender != address(this), 
            "Cannot transfer Ether to the contract itself"
        );

        require(
            address(this).balance >= _amount, 
            "Insufficient Funds in Contract"
        );

        require(
            _amount != 0, 
            "Invalid withdrawl Amount"
        );

        require(
            tokenContract.balanceOf(tx.origin) >= _amount,
            "Not enough tokens to Sell"
        );

        // Transfer tokens from manufacturer to distributor
        tokenContract.approve(_amount);
        tokenContract.transferFrom(tx.origin, owner, _amount); // transfer tokens to owner i.e. Manufacturer
        payable(tx.origin).transfer(_amount); //pay ether to caller address from contract
        tokenContract.approve(0);
    }

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
            "Only Consumer can buy Medicine From Pharmacy"
        );
        _;
    }

    // Add medicine
    //date of production and expiry will be sent in seconds from frontEnd
    function addMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint8 _cat,
        uint256 _quantity,
        uint256 _price,
        uint256 _dateOfProduction,
        uint256 _dateofExpiry
    ) public onlyManufacturer() {

        //add check if this lot is not already added
         Medicine storage med = medicines[_name][_lotNumber];
        require(
            _dateofExpiry >= _dateOfProduction && _price > 0,
            "Invalid Expiry/Production Date or Unit Price of Medicine"
        );

        require(
            _quantity >= minimumLotQuantity,
            "Medicine Quanity for Lot Not Valid / Minimum is 1000"
        );

        require(
            med.quantity == 0,
            "Lot Already Added"
        );

        Category c;
        if (_cat==0)
            c = Category.OffTheCounter;
        else if(_cat==1)
            c = Category.PrescriptionOnly;
        else if(_cat==2)
            c = Category.Herbal;
        else if(_cat==3)
            c = Category.LifeSaving;
        
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

    // Destroy medicine only Manufacturer can call
    //this can be called in case of returned meds which are expired
    function destroyMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity
    ) public onlyManufacturer() {
        
        require (
            _quantity != 0,
            "Invalid Quantity to Destroy"
        );
        Medicine storage med = medicines[_name][_lotNumber];
        require(
            med.quantity - (med.cirSupply + med.totalSoldQty) >= _quantity,
            "Not enough quantity to destroy"
        ); //updated

        med.quantity -= _quantity;
        emit MedicineDestroyed(_lotNumber, _quantity);
    }
    

    // Distributor Purchase medicine from Manufacturer 
    //Assumption Distributor purchase whole lot from manufacturer
    function purchaseMedicineLot(
        string memory _name,
        uint256 _lotNumber
    ) public  onlyDistributor() {
        Medicine storage med = medicines[_name][_lotNumber];
        require(
            med.quantity != med.cirSupply,
            "Medicine not available in mentioned Lot"
        );

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

    // Pharmacy Purchase medicine from distributor
    function purchaseFromDistributor(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _distributor
    ) public onlyPharmacy() {
        require(
            hasRole(Distributor,_distributor), 
            "Invalid distributor"
        );

        Medicine storage med = medicines[_name][_lotNumber];
        uint256 DistQuantity = med.qty.distributorQuantity[_distributor].medPurchased-med.qty.distributorQuantity[_distributor].medSold;
        require(
             DistQuantity >= _quantity && _quantity != 0,
            "Not enough quantity with Distributor / Invalid Quantity"
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

    // Customer Purchase medicine from pharmacy using tokens
    function purchaseFromPharmacy(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _pharmacy
    )  external onlyConsumer() {
        require(
            hasRole(Pharmacy, _pharmacy),
            "Invalid pharmacy"
        );

        Medicine storage med = medicines[_name][_lotNumber];
        require(
            verifyMedicine(_name,_lotNumber,_pharmacy),
            "Medicine not Verifed"
        );

        uint256 PharmQuantity = med.qty.PharmacyQuantity[_pharmacy].medPurchased - med.qty.PharmacyQuantity[_pharmacy].medSold;
        require(
              PharmQuantity >= _quantity && _quantity != 0,
            "Not enough quantity to purchase from Pharmacy / Invalid Quantity"
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

    // LOT EXPIRE CHECK, LOT AVAILABILITY CHECK
    //Verify medicine
    function verifyMedicine(
        string memory _name,
        uint256 _lotNumber,
        address _pharmacy
    ) public returns (bool) {
        Medicine storage med = medicines[_name][_lotNumber];
        bool check = true;
        string memory mesg = "Not Verified";
        if (med.dateOfExpiry >= block.timestamp) {
            mesg = "Medicine in this Lot are Expired";
            check = false;
        }
        else if(medicines[_name][_lotNumber].cirSuply == false){
            mesg = "Medicine in this Lot is not in Circulation Yet";//not purchased by distributor
            check = false;
        }
        else if (med.cirSupply == 0) {
            mesg = "Medicine in this Lot in no Longer in Circulating Supply";//sold all to consumers
            check = false;
        }
        else if (med.qty.PharmacyQuantity[_pharmacy].medPurchased - med.qty.PharmacyQuantity[_pharmacy].medSold == 0) {
            mesg = "Medicine Stock not available at Mentioned Pharmacy";
            check = false;
        }
        emit MedicineVerified(_lotNumber, mesg);
        return check;
    }

    
    // Return medicine by Distributor
    //Manufacturer can call this function after verification of returned  by distributor
    function returnMedicinebyManufacturer (
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _distributor
    ) public onlyManufacturer() {

        require(
            hasRole(Distributor, _distributor), 
            "Invalid Distributor"
        );

        //    //medName=>lotNumber=>addressOfRequestor=>addressOfReturnee=>quantityofReturn=>Status
        require(
            returnMedStatus[_name][_lotNumber][_distributor][owner][_quantity], 
            "Return Request Not Found"
        );

        Medicine storage med = medicines[_name][_lotNumber];
        require(
            med.qty.distributorQuantity[_distributor].medPurchased - med.qty.distributorQuantity[_distributor].medSold  >= _quantity,
            "Return Quantity Not Valid"
        );

        uint totalPrice = _quantity * med.price;
        
        med.cirSupply += _quantity;
        med.totalDistQty -= _quantity;

        med.qty.distributorQuantity[_distributor].medPurchased -= _quantity;
        tokenContract.transferFrom(owner, _distributor, totalPrice);
        delete returnMedStatus[_name][_lotNumber][_distributor][owner][_quantity];
        emit MedicineReturned(_lotNumber, _quantity);
    }

    // Accept return by pharmacy 
    //Only distributor can call this function after verification of returned medicine by pharmacy
    function returnMedicinebyDistributor(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _pharmacy
    ) public  onlyDistributor() {
        require(
            returnMedStatus[_name][_lotNumber][_pharmacy][tx.origin][_quantity], 
            "No Return Request Found"
        );

        Medicine storage med = medicines[_name][_lotNumber];
        uint256 totalQuantity = med.qty.PharmacyQuantity[_pharmacy].medPurchased - med.qty.PharmacyQuantity[_pharmacy].medSold;
        require (
            hasRole(Pharmacy,_pharmacy),
            "Pharmacy Address not Valid"
        );

        require(
            totalQuantity >= _quantity,
            "Invalid Return Quantity / Not enough quantity to Return"
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

    // Accept return by Consumer Pharmacy
    //Only Pharmacy can call this function after verification of returned medicine by consumer
    function returnMedicinebyPharmacy(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _consumer
    ) public onlyPharmacy() {

        require(
            returnMedStatus[_name][_lotNumber][_consumer][tx.origin][_quantity], 
            "No Return Request Found"
        );

        Medicine storage med = medicines[_name][_lotNumber];
        require(
            med.qty.consumerQuantity[_consumer] >= _quantity && _quantity != 0,
            "Invalid Return Quantity by Consumer"
        );

        require (
            hasRole(Pharmacy,tx.origin),
            "Pharmacy Address not Valid"
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
    
    // Add valid distributor
    function addValidDistributor(address _distributor)
        external
        onlyManufacturer()
    {
        require(
            _distributor != address(0),
            "Distributor Address Invalid"
        );
        _grantRole(Distributor, _distributor);
        emit DistributorAdded(_distributor);
    }

    //         // Add valid pharmacy
    function addValidPharmacy(address _pharmacy)
        public
        onlyDistributor()
    {
        require(
            _pharmacy != address(0),
            "Pharmacy Address Invalid"
        );
        _grantRole(Pharmacy, _pharmacy);
        emit PharmacyAdded(_pharmacy);
    }

    // function approveContract(uint256 _amount) public {
    //     tokenContract.approve(_amount);
    // }
    //Additional function to get stats of particular medicine quantity
    //it will return meds quantity for whoever is calls this function
    function getMedicineCount(string memory _name, uint256 _lotNumber) public view returns(uint256 qty) {
        Medicine storage med = medicines[_name][_lotNumber];
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

    //Create Return Request
    function sendReturnRequest(string memory _name, uint256 _lotNumber, uint256 _quantity, address _retAddress) public  {
        Medicine storage med = medicines[_name][_lotNumber];
        require(
            tx.origin != owner,
            "Manufacturer Cannot Send Return Request"
        );

        require(
            !(returnMedStatus[_name][_lotNumber][tx.origin][_retAddress][_quantity]), 
            "Cannot Add multiple Return Requests at one time  to same Party, Wait till previous is accepted"
        );
            
        if(hasRole(Distributor, tx.origin)) {
            require(
                _retAddress==owner,
                "Return Adddress not Valid"
            );

            require(
                med.qty.distributorQuantity[tx.origin].medPurchased - med.qty.distributorQuantity[tx.origin].medSold  >= _quantity,
                "Return Quantity Not Valid by Distributor"
            );
        
            returnMedStatus[_name][_lotNumber][tx.origin][owner][_quantity] = true;
        }
        else if (hasRole(Pharmacy,tx.origin)) {
            require(
                hasRole(Distributor, _retAddress) && med.qty.distributorQuantity[_retAddress].medPurchased > _quantity, 
                "Return Distributor Adddress not Valid / Distributor Didn't sold the selected Quantity"
            );
            
            uint256 totalQuantity = med.qty.PharmacyQuantity[tx.origin].medPurchased - med.qty.PharmacyQuantity[tx.origin].medSold;
            
            require(
                totalQuantity >= _quantity,
                "Invalid Return Quantity by Pharmacy"
            );

            returnMedStatus[_name][_lotNumber][tx.origin][_retAddress][_quantity] = true;
        }
        else {

            require(
                hasRole(Pharmacy,_retAddress) && 
                med.qty.PharmacyQuantity[_retAddress].medPurchased >= _quantity,
                "Return Pharmacy Adddress not Valid / Pharmacy Didn't sold the selected Quantity"
            );
            
            require(
                med.qty.consumerQuantity[tx.origin] >= _quantity,
                "Invalid Return Quantity by Consumer"
            );
            
            returnMedStatus[_name][_lotNumber][tx.origin][_retAddress][_quantity] = true;
        }
    }
}