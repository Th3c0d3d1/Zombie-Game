pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

// Contract inherits from ZombieFeeding
contract ZombieHelper is ZombieFeeding {

    // Sets the fee required to level up a zombie
    uint levelUpFee = 0.001 ether;

    // Modifier to check if a zombie has reached a certain level
    modifier aboveLevel(uint _level, uint _zombieId) {

        // Requires the zombie's level to be at or above the specified level
        require(zombies[_zombieId].level >= _level);

        // Continues execution of the modified function
        _;
    }

    // Allows the contract owner to withdraw Ether from the contract
    function withdraw() external onlyOwner {

        // Gets the owner's address
        address _owner = owner();
        
        // Transfers the contract's balance to the owner's address
        _owner.transfer(address(this).balance);
    }

    // Allows the contract owner to set the levelUpFee
    function setLevelUpFee(uint _fee) external onlyOwner{

        // Sets the levelUpFee to the provided fee
        levelUpFee = _fee;
    }

    // Create a payable function in our zombie game.
    // Function where users can pay ETH to level up their zombies
    // The ETH will get stored in the contract
    // Increase the zombie's level by 1 per payment

    // Payable function for users to level up their zombies by paying Ether
    function levelUp(uint _zombieId) external payable {

        // Requires the sent Ether to be equal to the levelUpFee
        require(msg.value == levelUpFee);

        // Increases the zombie's level by 1
        zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    }

    // Change the name of a zombie
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId), onlyOwnerOf(_zombieId) {

        // Sets the zombie's name to the provided name
        zombies[_zombieId].name = _newName;
    }

    // Change the DNA of a zombie
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId), onlyOwnerOf(_zombieId) {

        // Sets the zombie's DNA to the provided DNA
        zombies[_zombieId].dna = _newDna;
    }

    // View a user's entire zombie army
    // Returns an array of zombie IDs owned by a user
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {

        // Creates a new array to store the zombie IDs
        uint[] memory result = new uint[](ownerZombieCount[_owner]);

        // Counter to keep track of the number of zombies
        uint counter = 0;

        // Loops through all zombies
        for (uint i = 0; i < zombies.length; i++) {

            // Checks if the zombie is owned by the specified address
            if (zombieToOwner[i] == _owner) {

                // Adds the zombie's ID to the result array
                result[counter] = i;

                // Increments the counter
                counter++;
            }
        }

        // Returns the array of zombie IDs
        return result;
    }

}
