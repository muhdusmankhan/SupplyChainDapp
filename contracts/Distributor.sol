// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./MedicineSupplyChain.sol";

contract Distributor {

    MedicineSupplyChain public supplyChain;

    constructor(address _supplyChainAddress) {
        supplyChain = MedicineSupplyChain(_supplyChainAddress);
    }

    function purchaseTokens(uint _amount) public payable {
        require(
            msg.value ==_amount && _amount != 0,
            "Purchase Amount not Correct"
        );

        supplyChain.purchaseTokens{value: msg.value}(_amount);
    }

    function sellTokens(uint _amount) public {
        require(
            _amount > 0,
            "Sell Token Amount not Correct"
        );

        supplyChain.withDraw(_amount);
    }

    //Purchase Medicine from Manufacturer
    function purchaseMedicine(string memory _name, uint256 _lotNumber) public {
        supplyChain.purchaseMedicineLot(
            _name,
            _lotNumber
        );
    }

    //sendReturnRequest to Manufacturer by Distributor
    function returnMedicine (string memory _name, uint256 _lotNumber, uint256 _quantity) public {
        require(
            _quantity > 0, 
            "Invalid Return Quantity"
        );

        supplyChain.sendReturnRequest(
            _name, 
            _lotNumber, 
            _quantity, 
            supplyChain.owner()
        );
    }

    function acceptReturn (
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _pharmacy
        ) public {
        require(
            _quantity > 0,
            "Invalid Return Quantity"
        );

        require(
            _pharmacy != address(0),
            "Invalid Return Consumer Address"
        );

          supplyChain.returnMedicinebyDistributor(
            _name, 
            _lotNumber, 
            _quantity, 
            _pharmacy
        );  

    }

    function addPharmacy(address _pharmacy) public {
       supplyChain.addValidPharmacy(_pharmacy);
    }
}
