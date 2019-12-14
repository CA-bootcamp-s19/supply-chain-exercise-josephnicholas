pragma solidity ^0.5.0;

import "./Proxy.sol";
import "../contracts/SupplyChain.sol";

contract SupplyChainAccount is Proxy {
    function deploySupplyChainContract() external returns(address) {
        return address(new SupplyChain());
    }
}