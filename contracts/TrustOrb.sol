// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title TrustOrb
 * @notice A trust scoring system where users can create profiles and receive endorsements.
 */
contract TrustOrb {

    address public admin;

    struct OrbProfile {
        address user;
        uint256 trustScore;
        string metadataURI;
        bool exists;
    }

    mapping(address => OrbProfile) public profiles;
    mapping(address => mapping(address => bool)) public hasEndorsed;

    event OrbCreated(address indexed user, string metadataURI);
    event Endorsed(address indexed from, address indexed to, uint256 points);
    event MetadataUpdated(address indexed user, string newMetadata);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "TrustOrb: NOT_ADMIN");
        _;
    }

    modifier profileExists(address user) {
        require(profiles[user].exists, "TrustOrb: PROFILE_NOT_FOUND");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createOrb(string calldata metadataURI) external {
        require(!profiles[msg.sender].exists, "TrustOrb: ALREADY_EXISTS");

        profiles[msg.sender] = OrbProfile({
            user: msg.sender,
            trustScore: 0,
            metadataURI: metadataURI,
            exists: true
        });

        emit OrbCreated(msg.sender, metadataURI);
    }

    function endorse(address user, uint256 points) external profileExists(user) {
        require(user != msg.sender, "TrustOrb: SELF_ENDORSE");
        require(!hasEndorsed[msg.sender][user], "TrustOrb: ALREADY_ENDORSED");
        require(points > 0, "TrustOrb: INVALID_POINTS");

        hasEndorsed[msg.sender][user] = true;
        profiles[user].trustScore += points;

        emit Endorsed(msg.sender, user, points);
    }

    function updateMetadata(string calldata newMetadata) external profileExists(msg.sender) {
        profiles[msg.sender].metadataURI = newMetadata;
        emit MetadataUpdated(msg.sender, newMetadata);
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "TrustOrb: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function getProfile(address user) external view returns (OrbProfile memory) {
        return profiles[user];
    }
}
