// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import 'hardhat/console.sol';

contract WavePortal {
	uint256 totalWaves;
	uint256 private seed;

	/*
	 * A little magic, Google what events are in Solidity!
	 */
	event NewWave(
		address indexed from,
		uint256 timestamp,
		string message,
		bool winner,
		uint256 totalWaves
	);

	/*
	 * A struct is basically a custom datatype where we can customize what we want to hold inside it.
	 */
	struct Wave {
		address waver; // The address of the user who waved.
		string message; // The message the user sent.
		uint256 timestamp; // The timestamp when the user waved.
		bool winner; // Prize winner?
	}

	Wave[] waves;

	/*
	 * This is an address => uint mapping, meaning I can associate an address with a number!
	 * In this case, I'll be storing the address with the last time the user waved at us.
	 */
	mapping(address => uint256) public lastWavedAt;

	constructor() payable {
		console.log('Yo yo, I am a contract and I am smart');
	}

	function wave(string memory _message) public {
		/*
		 * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
		 */
		require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, 'Must wait 30 seconds before waving again.');

		/*
		 * Update the current timestamp we have for the user
		 */
		lastWavedAt[msg.sender] = block.timestamp;

		totalWaves += 1;
		console.log('%s waved', msg.sender);

		uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 100;
		console.log('Random # generated: %s', randomNumber);

		seed = randomNumber;

		bool winner = false;

		if (randomNumber < 50) {
			winner = true;

			console.log('%s won!', msg.sender);

			uint256 prizeAmount = 0.0001 ether;
			require(
				prizeAmount <= address(this).balance,
				'Trying to withdraw more money than they contract has.'
			);
			(bool success, ) = (msg.sender).call{ value: prizeAmount }('');
			require(success, 'Failed to withdraw money from contract.');
		}

		/*
		 * This is where I actually store the wave data in the array.
		 */
		waves.push(Wave(msg.sender, _message, block.timestamp, winner));

		/*
		 * I added some fanciness here, Google it and try to figure out what it is!
		 * Let me know what you learn in #general-chill-chat
		 */
		emit NewWave(msg.sender, block.timestamp, _message, winner, totalWaves);
	}

	/*
	 * I added a function getAllWaves which will return the struct array, waves, to us.
	 * This will make it easy to retrieve the waves from our website!
	 */
	function getAllWaves() public view returns (Wave[] memory) {
		return waves;
	}

	function getTotalWaves() public view returns (uint256) {
		console.log("We've been waved %d times!", totalWaves);
		return totalWaves;
	}
}
