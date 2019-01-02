pragma solidity ^0.4.23;

import "./ownable.sol";
import "./safemath.sol";

contract CowBreeding is Ownable {

  using SafeMath for uint256;
  event CowBirth(uint cowNumber, uint momNumber, string cowType, string cowSex);

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
  mapping (uint => address) public cowToOwner;
  mapping (address => uint) ownerCowCount;
  mapping (uint => uint) idToCowNum;

  modifier ownerOf(address _ownerOf) {
    require(msg.sender == _ownerOf);
    _;
  }

  function _cowBirth(uint _cowNum, uint _cowMom, string _types, string _sex) internal {
    uint id = cows.push(Cow(_cowNum, _cowMom, block.timestamp, _types, _sex)) - 1;
    idToCowNum[id] = _cowNum;
    cowToOwner[_cowNum] = msg.sender;
    ownerCowCount[msg.sender] = ownerCowCount[msg.sender].add(1);
    emit CowBirth(_cowNum, _cowMom, _types, _sex);
  }

  function cowBirth(uint _cowMom, string _types, string _sex) public {
    // Generate a unique identifier for cows
    uint _cowNum = uint(keccak256(abi.encodePacked(msg.sender, blockhash(block.number - 1)))) % cowModulus;
    _cowBirth(_cowNum, _cowMom, _types, _sex);
  }

  function getCowsByOwner(address _owner) external ownerOf(_owner) view returns (uint[]) {
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

  function getCountByOwner(address _owner) external ownerOf(_owner) view returns (uint) {
    return ownerCowCount[_owner]; 
  }

  function getOwnerByCow(uint _cowNum) public view returns (address) {
    return cowToOwner[_cowNum];
  } 
}

