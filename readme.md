# Reentrancy
A demo cow-traceability application v1.01

# Requirements
The code is written in solidity version 0.4.23 and the test uses async/await functions.

Here's information of workable environment.

$ truffle version
Truffle v4.1.15 (core: 4.1.15)
Solidity v0.4.25 (solc-js)

$ npm --version
6.4.1

$ node --version
v10.13.0

$ ganache-cli --version
Ganache CLI v6.2.5 (ganache-core: 2.3.3)

## Contracts
`CowBreeding` contract is a test solidity code for cow-traceability with functions defined below: cowBirth is a public function for farmers to issue a transaction of a cow while _cowBirth is an internal function which can be called from the front-facing cowBirth function. getCowsByOnwer is to get owner's cow details by looking up an owner's address. getCountByOwner is a function to get a total number of owned cows by that owner's address. At last getOnwerbyCow is a look-up function for public to search a cow's owner from a unique cow identity number.

function _cowBirth(uint _cowNum, uint _cowMom, string _types, string _sex) internal {}
function cowBirth(uint _cowMom, string _types, string _sex) public {}
function getCowsByOwner(address _owner) external ownerOf(_owner) view returns(uint[]) {}
function getCountByOwner(address _owner) external ownerOf(_owner) view returns (uint) {}
function getOwnerbyCow(uint _cowNum) public view returns (address) {}

A cow is given in an array of structure as below:

struct Cow {
  uint cowNum;
  uint cowMom;
  uint birthDate;
  string types;
  string sex;
}

## To Migrate:
1. Run: `truffle develop` under the application root
2. In the development console run: `compile`
3. Next run: `migrate` or (`migrate --reset`)

## To Test:
1. Migrate the contracts in the truffle development blockchain
2. `truffle test` or `test` in the truffle development console
