// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MedicineSupplyChain.sol";

contract Pharmacy {
    MedicineSupplyChain public supplyChain;

    constructor(address _supplyChainAddress) {
        supplyChain = MedicineSupplyChain(_supplyChainAddress);
    }

    function purchaseTokens(
        uint _amount
        ) public payable {
        require(
            msg.value ==_amount && _amount != 0,
            "Purchase Amount not Correct"
            );

        supplyChain.purchaseTokens{value: msg.value}(_amount);
    }

    function sellTokens(
        uint _amount
        ) public {
        require(
            _amount > 0,
            "Sell Token Amount not Correct"
            );

        supplyChain.withDraw(_amount);
    }

    //Purchase Medicine from Distributor
    function purchaseMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _distributor
    ) public {
        require(
            _quantity > 0,
            "Invalid Purhase Quantity by Pharmacy"
        );

        supplyChain.purchaseFromDistributor(
            _name,
            _lotNumber,
            _quantity, 
            _distributor
        );
    }

    //sendReturnRequest to Distributor by Pharmacy
    function returnMedicine (
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _distributor
    ) public {
        require(
            _quantity > 0, 
            "Invalid Return Quantity"
        );

        supplyChain.sendReturnRequest(
            _name, 
            _lotNumber, 
            _quantity, 
            _distributor
            );
    }

    function acceptReturn (
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _consumer
    ) public {
        require(
            _quantity > 0,
            "Invalid Return Quantity"
        );

        require(
            _consumer != address(0),
            "Invalid Return Consumer Address"
        );

          supplyChain.returnMedicinebyPharmacy(
            _name, 
            _lotNumber, 
            _quantity, 
            _consumer
            );  

    }
 
}