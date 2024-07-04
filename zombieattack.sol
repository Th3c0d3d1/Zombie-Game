pragma solidity >=0.5.0 <0.6.0;

import "./zombiehelper.sol";

contract ZombieAttack is ZombieHelper {

    // A nonce to ensure randomness in the generated number
    uint randNonce = 0;

    // Probability of winning an attack
    uint attackVictoryProbability = 70;

    // Internal function to generate a random number based on a modulus
    function randMod(uint _modulus) internal returns(uint) {

        // Increments the nonce to ensure different results for subsequent calls using the same timestamp and safemath
        randNonce = randNonce.add(1);

        // Generates a random number using keccak256 hash of current time, sender address, and nonce
        return uint(kecchak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
    }

    // External function to initiate an attack from one zombie to another
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {

        // Retrieves the zombies from storage
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];

        // Checks if the zombie is ready to attack
        uint rand = randMod(100);

        // Checks if the random number is less than or equal to the attack victory probability
        if (rand <= attackVictoryProbability) {

            // Increments the win count of the attacking zombie
            myZombie.winCount = myZombie.winCount.add(1);

            // Increments the level of the attacking zombie
            myZombie.level = myZombie.level.add(1);

            // Increments the loss count of the defending zombie
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);

            // Triggers the cooldown for the attacking zombie
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {

            // Increments the loss count of the attacking zombie
            myZombie.lossCount = myZombie.lossCount.add(1);

            // Increments the win count of the defending zombie
            enemyZombie.winCount = enemyZombie.winCount.add(1);

            // Triggers the cooldown for the attacking zombie
            _triggerCooldown(myZombie);
        }
    }
}