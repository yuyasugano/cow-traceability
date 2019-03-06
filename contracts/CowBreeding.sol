pragma solidity ^0.4.23;

import "./ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

/**
 * @title CowBreeding
 * @dev Cow Basic Implementation to breed them and provides basic functions.
 */  
contract CowBreeding is Ownable {

  using SafeMath for uint256;
  event Breeding(uint tokenId, string cowType, string cowSex);

  uint cowDigits = 10;
  uint cowModulus = 10 ** cowDigits;

  struct Cow {
    uint cowNum;
    uint cowMom;
    uint birthDate;
    string types;
    string sex;
  }

  Cow[] public cows;

  // Mapping from cow ID to owner
  mapping (uint => address) public cowToOwner;

  // Mapping from owner to number of owned cow
  mapping (address => uint) ownerCowCount;

  // Mapping from token ID to number of cows
  mapping (uint => uint) idToCowNum;

  // Mapping from number of cows to token ID
  mapping (uint => uint) cowNumToId;

  modifier onlyOwnerOf(address _ownerOf) {
    require(msg.sender == _ownerOf);
    _;
  }

  /**
   * @dev Internal function to give birth of a cow with variables
   * @param _cowNum new cow identity number
   * @param _cowMom new cow's mother identity number
   * @param _types new cow's type such as BrownSwiss
   * @param _sex new cow's sex male or female
   */
  function _cowBirth(uint _cowNum, uint _cowMom, string _types, string _sex) internal {
    uint id = cows.push(Cow(_cowNum, _cowMom, block.timestamp, _types, _sex)) - 1;
    idToCowNum[id] = _cowNum;
    cowNumToId[_cowNum] = id;
    cowToOwner[_cowNum] = msg.sender;
    ownerCowCount[msg.sender] = ownerCowCount[msg.sender].add(1);
    emit Breeding(_cowNum, _types, _sex);
  }

  /**
   * @dev Gives birth of a cow with variables
   * @param _cowMom new cow's mother identity number
   * @param _types new cow's type such as BrownSwiss
   * @param _sex new cow's sex male or female
   */
  function cowBirth(uint _cowMom, string _types, string _sex) public {
    // Generate a unique identifier for cows
    uint _cowNum = uint(keccak256(abi.encodePacked(msg.sender, blockhash(block.number - 1)))) % cowModulus;
    _cowBirth(_cowNum, _cowMom, _types, _sex);
  }

  /**
   * @dev Gets cows in struct from the owner address
   * @param _owner cow owner address
   * @return uint array of cow structs
   */
  function getCowsByOwner(address _owner) external view returns (uint[]) {
    uint[] memory cowsByOwner = new uint[](ownerCowCount[_owner]);
    uint counter = 0;
    uint number;
    for (uint i = 0; i < cows.length; i++) {
      number = idToCowNum[i];
      if (cowToOwner[number] == _owner) {
        cowsByOwner[counter] = number;
        counter = counter.add(1);
      }
    }
    return cowsByOwner;
  }

  /**
   * @dev Gets cow counts from the owner address
   * @param _owner cow owner address
   * @return uint of cow counts of the owner
   */
  function getCountByOwner(address _owner) external view returns (uint) {
    return ownerCowCount[_owner]; 
  }

  /**
   * @dev Gets number of cows from the cow id
   * @param _cowNum cow identity number
   * @return uint of cow id
   */
  function getIdByCowNum(uint _cowNum) external view returns (uint) {
    return cowNumToId[_cowNum];
  }
 
  /**
   * @dev Gets an owner address from a cow identity number
   * @param _cowNum cow identity number
   * @return address of the owner of the mentioned identity number
   */
  function getOwnerByCow(uint _cowNum) public view returns (address) {
    return cowToOwner[_cowNum];
  } 
}

