// Specifies the compiler version range for Solidity
pragma solidity >=0.5.0 <0.6.0;

// Imports the zombiefactory.sol file which is likely to define the base functionality for creating zombies
import "./zombiefactory.sol"; 

// Interface for interacting with the Kitty contract, presumably from CryptoKitties or a similar dApp
contract KittyInterface {

  // Function signature for getting kitty details by ID, returns multiple attributes of a kitty
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

// Extends ZombieFactory, adding functionality specific to feeding zombies
contract ZombieFeeding is ZombieFactory {
  // State variable to hold the KittyInterface contract instance
  KittyInterface kittyContract; 

  // Modifier to restrict function access to the owner of the zombie
  modifier onlyOwnerOf(uint _zombieId){

    // Checks that the caller owns the zombie
    require(msg.sender == zombieToOwner[_zombieId]); 

    // _; Continues execution of the modified function
    _; 
  }

  // Allows the contract owner to set the address of the KittyInterface contract
  function setKittyContractAddress(address _address) external onlyOwner {

    // Sets the kittyContract to the provided address
    kittyContract = KittyInterface(_address); 
  }

  // Internal function to start a cooldown period for a zombie after feeding
  function _triggerCooldown(Zombie storage _zombie) internal {

    // Sets the zombie's readyTime to the current time plus the cooldownTime
    _zombie.readyTime = uint32(now + cooldownTime); 
  }

  // Internal function to check if a zombie is ready to feed again
  function _isReady(Zombie storage _zombie) internal view returns (bool) {

    // Returns true if the current time is greater than or equal to the zombie's readyTime
    return (_zombie.readyTime <= now); 
  }

  // Internal function to handle the logic of a zombie feeding and potentially creating a new zombie
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {

    // Double-checks that the caller owns the zombie
    require(msg.sender == zombieToOwner[_zombieId]); 

    // Retrieves the zombie from storage
    Zombie storage myZombie = zombies[_zombieId];

    // Checks that the zombie is ready to feed
    require(_isReady(myZombie));

    // Modifies the target DNA to ensure it's within the valid range
    _targetDna = _targetDna % dnaModulus;

    // Combines the zombie's DNA with the target's DNA
    uint newDna = (myZombie.dna + _targetDna) / 2;

    // Increments the zombie's level
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      
      // If the species is "kitty", modifies the new DNA to mark the zombie as part kitty
      newDna = newDna - newDna % 100 + 99;
    }

    // Specifies the compiler version range for Solidity
    _createZombie("NoName", newDna);

    // Calls the internal function to start the cooldown for the feeding zombie
    _triggerCooldown(myZombie);
  }

  // Public function to allow a zombie to feed on a kitty, triggering the feed and multiply logic
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;

    // Calls the getKitty function on the kittyContract to retrieve the kitty's DNA
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

    // Calls the internal feedAndMultiply function with the kitty's DNA
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}