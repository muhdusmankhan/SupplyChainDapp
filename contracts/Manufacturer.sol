// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./MedicineSupplyChain.sol";
import "./MedicineToken.sol";

contract Manufacturer {
    MedicineSupplyChain public supplyChain;
    MedicineToken public token;

    constructor(address _supplyChainAddress) {
        supplyChain = MedicineSupplyChain(_supplyChainAddress);
    }

    function mintTokens(uint _amount)  public {
        require(
            _amount>0, 
            "INvalid Token Amount"
            );
            
        supplyChain.mintTokens(_amount);
    }

    function addMedicine(
        string memory _name,
        uint256 _lotNumber,
        uint8 _cat,
        uint256 _quantity,
        uint256 _price,
        uint256 _dateOfProduction,
        uint256 _dateofExpiry ) public {

        supplyChain.addMedicine(
            _name, 
            _lotNumber,
            _cat, 
            _quantity, 
            _price,
            _dateOfProduction,
            _dateofExpiry
        );
    }

      function destroyMed(
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity
        )  public {
       supplyChain.destroyMedicine(_name, _lotNumber, _quantity);
    }

    function acceptReturn (
        string memory _name,
        uint256 _lotNumber,
        uint256 _quantity, 
        address _distributor
    ) public {
        require(
            _quantity > 0,
            "Invalid Return Quantity"
        );

        require(
            _distributor != address(0),
            "Invalid Return Consumer Address"
        );

          supplyChain.returnMedicinebyManufacturer(
            _name, 
            _lotNumber, 
            _quantity, 
            _distributor
            );  

    }


     function addValidDistributor(address _address) public {
        supplyChain.addValidDistributor(_address);
    }
}