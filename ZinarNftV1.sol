// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no base URI, return the token URI.
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mecanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

contract ZinarWhitelistRefferal is Ownable {

    using SafeMath for uint256;

    // Referral commission rate in basis points.
    uint16 public referralCommissionRate = 500;
    // Max referral commission rate: 10%.
    uint16 public constant MAXIMUM_REFERRAL_COMMISSION_RATE = 1000;

    // an array of all whitelisted addresses
    address[] public whiteListedAddresses;

    // an array of all reffered addresses
    address[] public refAddresses;

    // mapping to select whitelisted addresses based on the amount of zinax tokens an addresses is holding at the point of creating this contract
    mapping(address => bool) public isWhitelisted;

     // maps whitelisted addresses to their referred user addresses
    mapping(address => address[]) public referrals;

    // mapping to check if user is referred
    mapping(address => bool) public referralVerified;

    // maps referred addresses to their referrers
    mapping(address => address) public referredBy;

    // mapping for referrer and commission earned
    mapping(address => uint256) public referralCommissionEarned;

    event ReferralCommissionPaid(address user, address referrer, uint256 amount);

    /*
    modifier isAuthorized() {
        require(address(this) == msg.sender, "not authorized");
        _;
    }
    */

    //function to add users to whitelist
    function whitelistUser(address _addressToWhitelist) public onlyOwner{
        isWhitelisted[_addressToWhitelist] = true;
        whiteListedAddresses.push(_addressToWhitelist);
    }

    // verify that a user has been whitelisted
    function verifyUser(address _whitelistedAddress) public view returns(bool) {
        bool userIsWhitelisted = isWhitelisted[_whitelistedAddress];
        return userIsWhitelisted;
    }
    
    function recordReferral(address userReferred) public {
        require(verifyUser(msg.sender) == true, "only WL users can refer");

        referralVerified[userReferred] = true;
        referrals[msg.sender].push(userReferred);
        referredBy[userReferred] = msg.sender;
        refAddresses.push(userReferred);
    }

    function verifyReferral(address referredAddress) public view returns(bool) {
        bool userIsVerifiedReferral = referralVerified[referredAddress];
        return userIsVerifiedReferral;
    }

    function recordReferralCommission(address referrer, uint256 commission) internal {
        referralCommissionEarned[referrer] = commission;
    }

    function getReferrer(address user) public view returns (address) {
        return referredBy[user];
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(uint16 _referralCommissionRate) public onlyOwner {
        require(_referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE, "setReferralCommissionRate: invalid referral commission rate basis points");
        referralCommissionRate = _referralCommissionRate;
    }

    // Pay referral commission to the referrer who referred this user.
    
    // *** dont forget to add a modifier that only allows the smart contract to call the payReferral function
    function payReferralCommission(address _user, uint256 _quantity) public payable {
        require(_quantity > 0, "must be more than 0");
        address payable referrer = payable(getReferrer(_user));
        uint256 commissionAmount = _quantity.mul(msg.value).mul(referralCommissionRate).div(10000);

        require(referrer != address(0), "referrer is zero address"); 
        require(referrer != msg.sender, "referrer is msg.sender");
        require(commissionAmount > 0, "commission is less than 0");
        referrer.transfer(commissionAmount);
        recordReferralCommission(referrer, commissionAmount);
        emit ReferralCommissionPaid(_user, referrer, commissionAmount);
    }

}

contract ZinarSetter is Ownable {

    event NewZinar05NFTMinted(address sender, uint256 tokenId, string tokenURI);
    event NewZinar1NFTMinted(address sender, uint256 tokenId, string tokenURI);
    event NewZinar2NFTMinted(address sender, uint256 tokenId, string tokenURI);
    event NewZinar5NFTMinted(address sender, uint256 tokenId, string tokenURI);
    event NewZinar10NFTMinted(address sender, uint256 tokenId, string tokenURI);

    bool public saleIsActive;

    uint256 public zinar05price = 1 ether; // $30
    uint256 public zinar1price = 3 ether; // $60
    uint256 public zinar2price = 5 ether; // $120
    uint256 public zinar5price = 7 ether; // $300
    uint256 public zinar10price = 10 ether; // $600

    uint256 public MAX_ZINAR05 = 2000; //1500
    uint256 public MAX_ZINAR1 = 3000 ; //2000
    uint256 public MAX_ZINAR2 = 2500; // 2500
    uint256 public MAX_ZINAR5 = 1000; // 2500
    uint256 public MAX_ZINAR10 = 1500; // 1500

    uint256 public MAX_ZINAR_MINT = 20;

    string public zinar05Uri;
    string public zinar1Uri;
    string public zinar2Uri;
    string public zinar5Uri;
    string public zinar10Uri;
    
    function flipSaleState() public onlyOwner returns (bool) {
        saleIsActive = !saleIsActive;
        return !saleIsActive;
    }

    function setPrice05(uint _zinar05price) public onlyOwner {
        zinar05price = _zinar05price;
    }

    function setPrice1(uint _zinar1price) public onlyOwner {
        zinar1price = _zinar1price;
    }

    function setPrice2(uint _zinar2price) public onlyOwner {
        zinar2price = _zinar2price;
    }

    function setPrice5(uint _zinar5price) public onlyOwner {
        zinar5price = _zinar5price;
    }

    function setPrice10(uint _zinar10price) public onlyOwner {
        zinar10price = _zinar10price;
    }

    function setZinar05Uri(string memory newZinar05Uri) public onlyOwner {
        zinar05Uri = newZinar05Uri; 
    }

    function setZinar1Uri(string memory newZinar1Uri) public onlyOwner {
        zinar1Uri = newZinar1Uri; 
    }

    function setZinar2Uri(string memory newZinar2Uri) public onlyOwner {
        zinar2Uri = newZinar2Uri; 
    }

    function setZinar5Uri(string memory newZinar5Uri) public onlyOwner {
        zinar5Uri = newZinar5Uri; 
    }

    function setZinar10Uri(string memory newZinar10Uri) public onlyOwner {
        zinar10Uri = newZinar10Uri; 
    }

    function setMaxZinarMint(uint _newMaxZinarMint) public onlyOwner {
        MAX_ZINAR_MINT = _newMaxZinarMint;
    }

    function withdraw() public onlyOwner payable {
        uint balance = address(this).balance;
        require(balance > 0, "Balance should be more then zero");
        payable(owner()).transfer(balance);
    }

}

contract ZinarNFTtest is ERC721, Ownable, ReentrancyGuard, ZinarWhitelistRefferal, ZinarSetter {
    
    using SafeMath for uint256;
    using Counters for Counters.Counter; // openzeppelin library for updating our token Id

    Counters.Counter private _tokenIds; // assign the value of the counter struct to the token Id

    constructor() ERC721("Zinar NFT", "ZINAR") {
        saleIsActive = false;
    }

    modifier active() {
        require(saleIsActive, "Sale must be active to mint Zinar NFTs");
        _;
    }

    mapping (uint256 => string) private _tokenURIs;

    function mintZinar05(uint256 numberOfTokens) public payable nonReentrant active {
        require(verifyReferral(msg.sender) == true || verifyUser(msg.sender) == true, "only WL or referral addresses can mint");
        require(numberOfTokens <= MAX_ZINAR_MINT, "max exceeded");
        require(totalSupply().add(numberOfTokens) <= MAX_ZINAR05, "Purchase exceeds max supply");
        require(msg.value >= zinar05price.mul(numberOfTokens), "enter matic value");

        zinar05Uri = "https://gateway.pinata.cloud/ipfs/Qmc1iZvCSnEUTuPz6iSEngDWbKTzAagRz4U9JfssFSpynf";

        uint256 tokenId = _tokenIds.current();
        uint256 end = tokenId.add(numberOfTokens);
        for(uint i = tokenId; i < end; i++) {
            _tokenIds.increment();
            _safeMint(msg.sender, i);
            _setTokenURI(i, zinar05Uri);

            emit NewZinar05NFTMinted(msg.sender, i, zinar05Uri);
        }
        payReferralCommission(payable(msg.sender), numberOfTokens);
    }

    function mintZinar1(uint numberOfTokens) public payable nonReentrant active {
        require(verifyReferral(msg.sender) == true || verifyUser(msg.sender) == true, "only WL or referral addresses can mint");
        require(numberOfTokens <= MAX_ZINAR_MINT, "max exceeded");
        require(totalSupply().add(numberOfTokens) <= MAX_ZINAR1, "Purchase exceeds max supply");
        require(msg.value >= zinar1price.mul(numberOfTokens), "enter BNB value");

        zinar1Uri = "https://gateway.pinata.cloud/ipfs/Qmc1iZvCSnEUTuPz6iSEngDWbKTzAagRz4U9JfssFSpynf";

        uint256 tokenId = _tokenIds.current();
        uint256 end = tokenId.add(numberOfTokens);
        for(uint i = tokenId; i < end; i++) {
            _tokenIds.increment();
            _safeMint(msg.sender, i);
            _setTokenURI(i, zinar1Uri);
            
            emit NewZinar1NFTMinted(msg.sender, i, zinar1Uri);
        }
        payReferralCommission(payable(msg.sender), numberOfTokens);
    }

    function mintZinar2(uint numberOfTokens) public payable nonReentrant active {
        require(verifyReferral(msg.sender) == true || verifyUser(msg.sender) == true, "only WL or referral addresses can mint");
        require(numberOfTokens <= MAX_ZINAR_MINT, "max mint 2"); 
        require(totalSupply().add(numberOfTokens) <= MAX_ZINAR2, "Purchase exceeds max supply");
        require(msg.value >= zinar2price.mul(numberOfTokens), "enter BNB value");

        zinar2Uri = "https://gateway.pinata.cloud/ipfs/Qmc1iZvCSnEUTuPz6iSEngDWbKTzAagRz4U9JfssFSpynf";

        uint256 tokenId = _tokenIds.current();
        uint256 end = tokenId.add(numberOfTokens);
        for(uint i = tokenId; i < end; i++) {
            _tokenIds.increment();
            _safeMint(msg.sender, i);
            _setTokenURI(i, zinar2Uri);

            emit NewZinar2NFTMinted(msg.sender, i, zinar2Uri);
        }
        payReferralCommission(payable(msg.sender), numberOfTokens);
    }

    function mintZinar5(uint numberOfTokens) public payable nonReentrant active {
        require(verifyReferral(msg.sender) == true || verifyUser(msg.sender) == true, "only WL or referral addresses can mint");
        require(numberOfTokens <= MAX_ZINAR_MINT, "max mint 5"); 
        require(totalSupply().add(numberOfTokens) <= MAX_ZINAR5, "Purchase exceeds max supply");
        require(msg.value >= zinar5price.mul(numberOfTokens), "enter BNB value");

        zinar5Uri = "https://gateway.pinata.cloud/ipfs/Qmc1iZvCSnEUTuPz6iSEngDWbKTzAagRz4U9JfssFSpynf";

        uint256 tokenId = _tokenIds.current();
        uint256 end = tokenId.add(numberOfTokens);
        for(uint i = tokenId; i < end; i++) {
            _tokenIds.increment();
            _safeMint(msg.sender, i);
            _setTokenURI(i, zinar5Uri);

            emit NewZinar5NFTMinted(msg.sender, i, zinar5Uri);
        }
        payReferralCommission(payable(msg.sender), numberOfTokens);
    }

    function mintZinar10(uint numberOfTokens) public payable nonReentrant active {
        require(verifyReferral(msg.sender) == true || verifyUser(msg.sender) == true, "only WL or referral addresses can mint");
        require(numberOfTokens <= MAX_ZINAR_MINT, "max mint 10");
        require(totalSupply().add(numberOfTokens) <= MAX_ZINAR10, "Purchase exceeds max supply");
        require(msg.value >= zinar10price.mul(numberOfTokens), "enter BNB value");

        zinar10Uri = "https://gateway.pinata.cloud/ipfs/Qmc1iZvCSnEUTuPz6iSEngDWbKTzAagRz4U9JfssFSpynf";

        uint256 tokenId = _tokenIds.current();
        uint256 end = tokenId.add(numberOfTokens);
        for(uint i = tokenId; i < end; i++) {
            _tokenIds.increment();
            _safeMint(msg.sender, i);
            _setTokenURI(i, zinar10Uri);

            emit NewZinar10NFTMinted(msg.sender, i, zinar10Uri);
        }
        payReferralCommission(payable(msg.sender), numberOfTokens);
    }
    
}
