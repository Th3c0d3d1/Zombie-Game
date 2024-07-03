pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable {

    // Using SafeMath to prevent overflows and underflows
    using SafeMath for uint256;

    // Event declaration for creating a new zombie
    event NewZombie(uint zombieId, string name, uint dna);

    // Variable to store the number of DNA digits
    uint dnaDigits = 16;

    // Variable to calculate the modulus for DNA to ensure it's within a specific range
    uint dnaModulus = 10 ** dnaDigits;

    // Variable to store the cooldown time for a zombie
    uint cooldownTime = 1 days;

    // Struct definition for a Zombie
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Array to store all zombies
    Zombie[] public zombies;

    // Mapping to store the owner of a zombie
    mapping (uint => address) public zombieToOwner;

    // Mapping to store the number of zombies owned by an address
    mapping (address => uint) ownerZombieCount;

    // Internal function to create a zombie and add it to the zombies array
    function _createZombie(string memory _name, uint _dna) internal {

        // Adds the new zombie to the zombies array
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTimer), 0, 0)) - 1;

        // Maps the zombie ID to the owner's address
        zombieToOwner[id] = msg.sender;

        // Increments the owner's zombie count
        ownerZombieCount[msg.sender]++;

        // Emits a NewZombie event
        emit NewZombie(id, _name, _dna);
    }

    // Internal function to generate a random DNA based on a string input
    function _generateRandomDna(string memory _str) private view returns (uint) {

        // Generates a random number using keccak256 hash of the input string
        uint rand = uint(keccak256(abi.encodePacked(_str)));

        // Ensures the DNA is within the range defined by dnaModulus
        return rand % dnaModulus;
    }

    // Public function to create a zombie with a random DNA
    function createRandomZombie(string memory _name) public {

        // Requires the owner to have no zombies
        require(ownerZombieCount[msg.sender] == 0);

        // Generates a random DNA based on the provided name
        uint randDna = _generateRandomDna(_name);

        // Ensures the DNA is within the valid range
        randDna = randDna - randDna % 100;

        // Calls the internal function to create a new zombie
        _createZombie(_name, randDna);
    }

}
