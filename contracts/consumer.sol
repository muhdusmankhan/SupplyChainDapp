// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MedicineSupplyChain.sol";

contract Consumer {
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

    function verifyMedicine (
        string memory _name, 
        uint256 _lotNumber, 
        address _pharmacy
        ) public returns(bool) {
        
        return supplyChain.verifyMedicine(
            _name,
            _lotNumber,
            _pharmacy
        );
    }

    //Purchase Medicine from Pharmacy
    function purchaseMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity,
        address _pharmacy
        ) public {
        
        require(
            _quantity > 0, 
            "Invalid Purchase Quantity"
        );

        supplyChain.purchaseFromPharmacy(
            _name,
            _lotNumber,
            _quantity,
            _pharmacy
        );
    }

    //sendReturnRequest to Pharmacy by Consumer
    function returnMedicine (
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
            _pharmacy!=address(0),
            "Invalid Pharmacy Address"
        );

        supplyChain.sendReturnRequest(
            _name, 
            _lotNumber, 
            _quantity, 
            _pharmacy
        );
    }
}
