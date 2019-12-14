pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./SupplyChainAccount.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    uint public initialBalance = 1 ether;

    SupplyChain supplychain;
    SupplyChainAccount[4] accounts;

    function beforeEach() public {
        for(uint i = 0; i < accounts.length; i++) {
            accounts[i] = new SupplyChainAccount();
            if(i == 0) {
                supplychain = SupplyChain(accounts[i].deploySupplyChainContract());
            }
            accounts[i].setContractAddress(address(supplychain));
        }
    }

    // buyItem
    function testBuyItem() public {
        uint sellerBalance = address(accounts[1]).balance; //balance before buying
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        (string memory _name, , uint256 _price, uint _state,,) = supplychain.fetchItem(0);

        Assert.equal(_name, 'Ethereum for Developers', "Product name should be added in the chain");
        Assert.equal(_price, 1000 wei, "Product price should be added in the chain");
        Assert.equal(_state, 1, 'Item state should be Sold');
        Assert.notEqual(sellerBalance, address(accounts[1]).balance, "Balance should be increased");
    }

    // test for failure if user does not send enough funds
    function testBuyItemWithInsuffecientFunds() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        (bool r, ) = address(accounts[2]).call.value(300 wei)(abi.encodeWithSignature("buyItem(uint256)", 0));

        Assert.isFalse(r, "Should throw, funds are insuffecient");
    }

    // test for purchasing an item that is not for Sale
    function testNotForSaleItem() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        (bool r, ) = address(accounts[3]).call.value(3000 wei)(abi.encodeWithSignature("buyItem(uint256)", 0));

        Assert.isFalse(r, "Should throw, items is not for sale");
    }

    // shipItem
    function testShipItem() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        SupplyChain(address(accounts[1])).shipItem(0);
        (, , , uint _state,,) = supplychain.fetchItem(0);

        Assert.equal(_state, 2, 'Item state should be Shipped');
    }

    // test for calls that are made by not the seller
    function testShipItemMadeTheBuyer() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        (bool r, ) = address(accounts[3]).call(abi.encodeWithSignature("shipItem(uint256)", 0));

        Assert.isFalse(r, "Should throw, address is not the seller");
    }

    // test for trying to ship an item that is not marked Sold
    function testShipNotYetSold() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        (bool r, ) = address(accounts[1]).call(abi.encodeWithSignature("shipItem(uint256)", 0));

        Assert.isFalse(r, "Should throw, item not yet sold");
    }

    // receiveItem
    function testReceiveItem() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        SupplyChain(address(accounts[1])).shipItem(0);
        SupplyChain(address(accounts[2])).receiveItem(0);
        (, , , uint _state,,) = supplychain.fetchItem(0);

        Assert.equal(_state, 3, 'Item state should be Received');
    }

    // test calling the function from an address that is not the buyer
    function testReceiveItemNotBuyer() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        SupplyChain(address(accounts[1])).shipItem(0);
        (bool r, ) = address(accounts[1]).call(abi.encodeWithSignature("receiveItem(uint256)", 0));
        
        Assert.isFalse(r, "Should throw, item not yet sold");
    }

    // test calling the function on an item not marked Shipped
    function testReceiveItemNotShipped() public {
        SupplyChain(address(accounts[1])).addItem('Ethereum for Developers', 1000 wei);
        SupplyChain(address(accounts[2])).buyItem.value(3000 wei)(0);
        (bool r, ) = address(accounts[2]).call(abi.encodeWithSignature("receiveItem(uint256)", 0));
        
        Assert.isFalse(r, "Should throw, item not yet shipped");
    }

}
