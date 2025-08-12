// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Decentralized Identity Statement
 * @dev Smart contract for managing decentralized identity statements on blockchain
 * @author Your Name
 */
contract Project {
    
    // Structure to store identity statement
    struct IdentityStatement {
        string name;
        string bio;
        string[] credentials;
        string ipfsHash; // For storing additional documents
        uint256 timestamp;
        bool isActive;
    }
    
    // Mapping from address to identity statement
    mapping(address => IdentityStatement) private identities;
    
    // Mapping to track verified addresses
    mapping(address => bool) public verifiedUsers;
    
    // Array to keep track of all registered addresses
    address[] public registeredAddresses;
    
    // Events
    event IdentityCreated(address indexed user, string name, uint256 timestamp);
    event IdentityUpdated(address indexed user, uint256 timestamp);
    event IdentityVerified(address indexed user, uint256 timestamp);
    event IdentityDeactivated(address indexed user, uint256 timestamp);
    
    // Modifiers
    modifier onlyRegistered() {
        require(identities[msg.sender].timestamp > 0, "Identity not registered");
        _;
    }
    
    modifier onlyActive() {
        require(identities[msg.sender].isActive, "Identity is deactivated");
        _;
    }
    
    /**
     * @dev Core Function 1: Create or update identity statement
     * @param _name Full name of the user
     * @param _bio Biography or description
     * @param _credentials Array of credentials/qualifications
     * @param _ipfsHash IPFS hash for additional documents
     */
    function createIdentityStatement(
        string memory _name,
        string memory _bio,
        string[] memory _credentials,
        string memory _ipfsHash
    ) external {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_bio).length > 0, "Bio cannot be empty");
        
        // Check if this is a new registration
        bool isNewUser = identities[msg.sender].timestamp == 0;
        
        // Create or update identity statement
        identities[msg.sender] = IdentityStatement({
            name: _name,
            bio: _bio,
            credentials: _credentials,
            ipfsHash: _ipfsHash,
            timestamp: block.timestamp,
            isActive: true
        });
        
        if (isNewUser) {
            registeredAddresses.push(msg.sender);
            emit IdentityCreated(msg.sender, _name, block.timestamp);
        } else {
            emit IdentityUpdated(msg.sender, block.timestamp);
        }
    }
    
    /**
     * @dev Core Function 2: Retrieve identity statement
     * @param _user Address of the user whose identity to retrieve
     * @return name User's name
     * @return bio User's biography
     * @return credentials Array of user's credentials
     * @return ipfsHash IPFS hash of additional documents
     * @return timestamp When the identity was last updated
     * @return isActive Whether the identity is currently active
     * @return isVerified Whether the identity is verified
     */
    function getIdentityStatement(address _user) 
        external 
        view 
        returns (
            string memory name,
            string memory bio,
            string[] memory credentials,
            string memory ipfsHash,
            uint256 timestamp,
            bool isActive,
            bool isVerified
        ) 
    {
        require(identities[_user].timestamp > 0, "Identity not found");
        
        // Direct return to avoid stack too deep error
        return (
            identities[_user].name,
            identities[_user].bio,
            identities[_user].credentials,
            identities[_user].ipfsHash,
            identities[_user].timestamp,
            identities[_user].isActive,
            verifiedUsers[_user]
        );
    }
    
    /**
     * @dev Core Function 3: Manage identity verification and status
     * @param _user Address of the user to verify
     */
    function verifyIdentity(address _user) external {
        require(identities[_user].timestamp > 0, "Identity not found");
        require(identities[_user].isActive, "Identity is not active");
        require(!verifiedUsers[_user], "User already verified");
        
        // Simple verification logic - in production, this would involve
        // more sophisticated verification mechanisms
        require(
            msg.sender != _user, 
            "Cannot self-verify"
        );
        
        verifiedUsers[_user] = true;
        emit IdentityVerified(_user, block.timestamp);
    }
    
    /**
     * @dev Deactivate own identity
     */
    function deactivateIdentity() external onlyRegistered {
        identities[msg.sender].isActive = false;
        emit IdentityDeactivated(msg.sender, block.timestamp);
    }
    
    /**
     * @dev Reactivate own identity
     */
    function reactivateIdentity() external onlyRegistered {
        identities[msg.sender].isActive = true;
        emit IdentityUpdated(msg.sender, block.timestamp);
    }
    
    /**
     * @dev Add credential to existing identity
     * @param _credential New credential to add
     */
    function addCredential(string memory _credential) 
        external 
        onlyRegistered 
        onlyActive 
    {
        require(bytes(_credential).length > 0, "Credential cannot be empty");
        
        identities[msg.sender].credentials.push(_credential);
        identities[msg.sender].timestamp = block.timestamp;
        
        emit IdentityUpdated(msg.sender, block.timestamp);
    }
    
    /**
     * @dev Get total number of registered users
     * @return Total count of registered addresses
     */
    function getTotalRegisteredUsers() external view returns (uint256) {
        return registeredAddresses.length;
    }
    
    /**
     * @dev Check if an address has registered identity
     * @param _user Address to check
     * @return Whether the address has registered identity
     */
    function hasIdentity(address _user) external view returns (bool) {
        return identities[_user].timestamp > 0;
    }
    
    /**
     * @dev Get user's verification status
     * @param _user Address to check
     * @return Whether the user is verified
     */
    function isUserVerified(address _user) external view returns (bool) {
        return verifiedUsers[_user];
    }
}
