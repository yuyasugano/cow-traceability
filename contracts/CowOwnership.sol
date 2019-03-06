pragma solidity ^0.4.23;

import "./CowBreeding.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol";

/**
 * @title ERC721 compatible Cow Standard Basic Implementation
 * @dev Implements Cow transfer with inherited OpenZeppelin ERC721
 */
contract CowOwnership is CowBreeding, ERC721Metadata {

  /// @notice Name and Symbol of the NFT token
  string private _name = "CowToken";
  string private _symbol = "CWTK";

  // Mapping from token ID to approved address
  mapping (uint256 => address) private _tokenApprovals;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) private _operatorApprovals;

  constructor() public ERC721Metadata(_name, _symbol) {}

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256 _balance) {
    require(_owner != address(0));
    return ownerCowCount[_owner];
  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    address owner = cowToOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    // Only an owner can grant transfer approval
    address owner = ownerOf(_tokenId);
    // The address to be approved should not be the owner
    require(_to != owner, "Approval to the owner is prohibited");
    // Sender should be the owner and approved by the owner to transfer
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Unpermitted approval");

    // Register the approval (replacing any previous approval)
    _tokenApprovals[_tokenId] = _to;

    // Emit approval event
    emit Approval(owner, _to, _tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * Reverts if the token ID does not exist.
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address operator) {
    require(_exists(_tokenId));
    return _tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _operator, bool _approved) public {
    require(_operator != address(0), "Approval to zero address is prohibited");
    require(_operator != msg.sender);
    _operatorApprovals[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return _operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    require(_isApprovedOrOwner(msg.sender, _tokenId));
    _transferFrom(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   *
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public {
    transferFrom(_from, _to, _tokenId);
    require(_checkOnERC721Received(_from, _to, _tokenId, _data)); 
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function _exists(uint256 _tokenId) internal view returns (bool) {
    address owner = cowToOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *    is an operator of the owner, or is the owner of the token
   */
  function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
  }

  /**
   * @dev Internal function to transfer ownership of a given token ID to another address.
   * As opposed to transferFrom, this imposes no restrictions on msg.sender.
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) ==_from);
    require(_to != address(0));
    _clearApproval(_tokenId);

    ownerCowCount[_from] = ownerCowCount[_from].sub(1);
    ownerCowCount[_to]   = ownerCowCount[_to].add(1);

    cowToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);  
  }

  /**
   * @dev Private function to clear current approval of a given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function _clearApproval(uint256 _tokenId) private {
    if (_tokenApprovals[_tokenId] != address(0)) {
      _tokenApprovals[_tokenId] = address(0);
    }
  }

  /**
   * @dev Set the token URI for a given token by the owner
   * Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function setTokenURI(uint256 _tokenId, string _uri) external {
    address owner = ownerOf(_tokenId);
    require(msg.sender == owner);
    super._setTokenURI(_tokenId, _uri);
  }

  /**
   * @dev External function to burn a specific token
   * Reverts if the token does not exist
   * Deprecated, use _burn(uint256) instead
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function burn(uint256 _tokenId) external {
    address owner = ownerOf(_tokenId);
    require(msg.sender == owner);
    super._burn(owner, _tokenId);
  }
}

