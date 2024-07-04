pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./safemath.sol";

// Imports the ERC721 contract interface for NFT functionality
import "./erc721.sol";

// Declare ERC721 inheritance here
contract ZombieOwnership is ZombieAttack, ERC721 {

    using SafeMath for uint256;

    // Maps the zombie ID to the approved address
    mapping (uint => address) zombieApprovals;

    // Function to return the total number of zombies owned by an address
    function balanceOf(address _owner) external view returns (uint256) {

        // Returns the number of zombies owned by the address
        return ownerZombieCount[_owner];
    }

    // Function to return the owner of a specific zombie
    function ownerOf(uint256 _tokenId) external view returns (address) {

        // Returns the owner of the specified zombie
        return zombieToOwner[_tokenId];
    }

    // Function to transfer a zombie from one address to another
    function _transfer(address _from, address _to, uint256 _tokenId) private {

        // Increases the zombie count for the new owner and decreases for the old owner
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);

        // Transfers the zombie to the new owner
        zombieToOwner[_tokenId] = _to;

        // Emits a Transfer event, a requirement of the ERC721 standard
        emit Transfer(_from, _to, _tokenId);
    }

    // Function to transfer a zombie from the owner's address to another address
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {

        // Requires the sender to be the owner of the zombie or the approved address
        require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);

        // Transfers the zombie to the new owner
        _transfer(_from, _to, _tokenId);
    }

    // Approves another address to transfer a specific zombie
    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {

        // Sets the approved address for the specified zombie
        zombieApprovals[_tokenId] = _approved;

        // Emits an Approval event, a requirement of the ERC721 standard
        emit Approval(msg.sender, _approved, _tokenId);

    }
}