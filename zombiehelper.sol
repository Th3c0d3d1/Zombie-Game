pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

// Contract inherits from ZombieFeeding
contract ZombieHelper is ZombieFeeding {

    uint levelUpFee = 0.001 ether;

    // Define the level up logic
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function withdraw() external onlyOwner {
        address payable _owner = address(uint160(owner()));
        _owner.transfer(address(this).balance);
    }

    function setLevelUpFee(uint _fee) external onlyOwner{
        levelUpFee = _fee;
    }

    // Create a payable function in our zombie game.
    // Function where users can pay ETH to level up their zombies
    // The ETH will get stored in the contract
    // Increase the zombie's level by 1 per payment
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }


    // Change the name of a zombie
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId), ownerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    // Change the DNA of a zombie
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId), ownerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    // View a user's entire zombie army
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;

        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

}
