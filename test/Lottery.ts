import { expect } from "chai";
import { ethers } from "hardhat";
import { Lottery } from "../typechain-types";

describe("Lottery Contract", function () {
    let lottery: Lottery;
    let admin: any;
    let user1: any;
    let user2: any;

    beforeEach(async () => {
        // Pobierz konta
        [admin, user1, user2] = await ethers.getSigners();

        // Deploy kontraktu
        const Lottery = await ethers.getContractFactory("Lottery", admin);
        lottery = (await Lottery.deploy()) as Lottery;
        await (lottery as any).deployed();
    });

    it("should allow a user to enter the lottery", async () => {
        await lottery.connect(user1).enter({ value: ethers.parseEther("0.01") });

        const players = await lottery.getPlayers();
        expect(players).to.include(user1.address);
    });

    it("should not allow a user to enter without enough ETH", async () => {
        await expect(lottery.connect(user1).enter({ value: ethers.parseEther("0.001") })).to.be.revertedWith(
            "Minimum 0.01 ETH required to enter lottery."
        );
    });

    it("should allow admin to pick a winner", async () => {
        await lottery.connect(user1).enter({ value: ethers.parseEther("0.01") });
        await lottery.connect(user2).enter({ value: ethers.parseEther("0.01") });

        await lottery.connect(admin).pickWinner();

        const winner = await lottery.winner();
        expect([user1.address, user2.address]).to.include(winner);
    });

    it("should allow the winner to claim the prize", async () => {
        await lottery.connect(user1).enter({ value: ethers.parseEther("0.01") });

        await lottery.connect(admin).pickWinner();
        const winner = await lottery.winner();

        const initialBalance = await ethers.provider.getBalance(winner);
        await lottery.connect(user1).claimPrize();
        const finalBalance = await ethers.provider.getBalance(winner);

        expect(finalBalance).to.be.gt(initialBalance);
    });
});
