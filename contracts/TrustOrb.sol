// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title TrustOrb
 * @notice A decentralized reputation and trust verification system 
 *         where users can build, view, and endorse reputations transparently on-chain.
 */
contract Project {
    address public admin;
    uint256 public userCount;

    struct UserProfile {
        uint256 id;
        address userAddress;
        string name;
        uint256 trustScore;
        uint256 endorsements;
        bool registered;
    }

    mapping(address => UserProfile) public users;

    event UserRegistered(uint256 indexed id, address indexed user, string name);
    event TrustEndorsed(address indexed endorser, address indexed target, uint256 newScore);
    event TrustScoreUpdated(address indexed user, uint256 newScore);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Register a new user profile
     * @param _name The display name of the user
     */
    function registerUser(string memory _name) external {
        require(!users[msg.sender].registered, "User already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");

        userCount++;
        users[msg.sender] = UserProfile(userCount, msg.sender, _name, 50, 0, true); // Default trust score = 50

        emit UserRegistered(userCount, msg.sender, _name);
    }

    /**
     * @notice Endorse another user's trust score
     * @param _target The address of the user to endorse
     */
    function endorseTrust(address _target) external onlyRegistered {
        require(users[_target].registered, "Target user not registered");
        require(_target != msg.sender, "Cannot endorse yourself");

        users[_target].endorsements++;
        users[_target].trustScore += 1;

        emit TrustEndorsed(msg.sender, _target, users[_target].trustScore);
    }

    /**
     * @notice Admin can adjust a user's trust score in case of fraud or misuse
     * @param _target The address of the user
     * @param _newScore The new trust score to set
     */
    function updateTrustScore(address _target, uint256 _newScore) external onlyAdmin {
        require(users[_target].registered, "User not registered");
        users[_target].trustScore = _newScore;

        emit TrustScoreUpdated(_target, _newScore);
    }

    /**
     * @notice View a user's profile details
     * @param _user Address of the user
     */
    function getUserProfile(address _user) external view returns (UserProfile memory) {
        require(users[_user].registered, "User not registered");
        return users[_user];
    }
}
