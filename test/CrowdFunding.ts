import { expect } from "chai";
import { ethers } from "hardhat";
import { CrowdFunding } from "../typechain-types"
import { Signer } from "ethers";
import { log } from "console";
import { network } from "hardhat";


describe("CrowdFunfing Contract", function () {
    let crowdFunding: CrowdFunding;
    let admin: any;
    let users: Signer[];


    beforeEach(async () => {
        [admin, ...users] = await ethers.getSigners();

        const CrowdFundingFactory = await ethers.getContractFactory("CrowdFunding", admin);
        crowdFunding = (await CrowdFundingFactory.deploy()) as CrowdFunding;
        await crowdFunding.waitForDeployment();
    });

    it("should allow user to create a goal", async () => {
        await crowdFunding.connect(users[0]).createGoal(
            'car',
            'The Car',
            100,
            7
        )

        const goalCount = await crowdFunding.goalCount();
        const goal = await crowdFunding.goals(0);

        expect(goalCount).to.equal(1);
        expect(goal[0]).to.equal('car'); // title
        expect(goal[1]).to.equal('The Car'); // description
        expect(goal[2]).to.equal(100); // targetAmount
        expect(goal[4]).to.equal(0); // collectedAmount
        expect(goal[5]).to.equal(users[0]); // owner
        expect(goal[6]).to.equal(false); // isCollected
    });

    it("should allow user to donate to a goal", async () => {
        await crowdFunding.connect(users[0]).createGoal(
            'car',
            'The Car',
            100,
            7
        )

        await crowdFunding.connect(users[1]).contribute(0, { value: ethers.parseEther("1") });

        const goal = await crowdFunding.goals(0);
        expect(goal[4]).to.equal(ethers.parseEther("1"));
    });

    it("should allow user to claim donations", async () => {
        await crowdFunding.connect(users[0]).createGoal(
            'car',
            'The Car',
            100,
            7
        )

        await crowdFunding.connect(users[1]).contribute(0, { value: ethers.parseEther("1") });

        const SEVEN_DAYS_IN_SECONDS = 7 * 24 * 60 * 60;

        await network.provider.send("evm_increaseTime", [SEVEN_DAYS_IN_SECONDS]);
        await network.provider.send("evm_mine");

        const goal = await crowdFunding.goals(0);
        const balanceBefore = await ethers.provider.getBalance(users[0]);
        await crowdFunding.connect(users[0]).withdraw(0);
        const balanceAfter = await ethers.provider.getBalance(users[0]);
        expect(balanceBefore).lessThan(balanceAfter);

    });
});
