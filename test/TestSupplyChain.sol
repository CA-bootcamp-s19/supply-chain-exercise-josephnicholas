pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    uint public initialBalance = 1 ether;

    // buyItem
    function testBuyItemUsingDeployedContract() public payable {
        SupplyChain supplychain = SupplyChain(DeployedAddresses.SupplyChain());
        
        bool added = supplychain.addItem("book", 1000 wei);
        (string memory name, , , uint state, ,) = supplychain.fetchItem(0);
        
        Assert.equal(added, true, "Product should be added in the chain");
        Assert.equal(name, "book", "Product name should be added in the chain");
        Assert.equal(state, 0, "Product state should be ForSale in the chain"); 

        bytes memory payload = abi.encodeWithSignature("buyItem(uint256)", "0");
        (bool success, ) = msg.sender.call.value(2000 wei)(payload);
        require(success);

        supplychain.buyItem.value(3000 wei)(0);
        //Assert.equal(state, 1, "Product state be Sold in the chain");        
    }

    // test for failure if user does not send enough funds
    // test for purchasing an item that is not for Sale

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}
