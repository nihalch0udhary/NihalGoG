// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title TrustOrb
 * @notice A trust scoring and verification system that allows users to create identities,
 *         earn trust points, and receive endorsements from others.
 * @dev Simple, gas-efficient design. Can be expanded with roles, ZK checks, or token rewards.
 */
contract TrustOrb {

    /* -------------------------------------------------------------------------- */
    /*                                   STORAGE                                   */
    /* -------------------------------------------------------------------------- */

    struct OrbProfile {
        address user;
        uint256 trustScore;
        string metadataURI;
        bool exists;
    }

    mapping(address => OrbProfile) public profiles;
    mapping(address => mapping(address => bool)) public hasEndorsed;

    address public admin;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                    */
    /* -------------------------------------------------------------------------- */

    event OrbCreated(address indexed user, string metadataURI);
    event Endorsed(address indexed from, address indexed to, uint256 points);
    event MetadataUpdated(address indexed user, string newMetadata);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    /* -------------------------------------------------------------------------- */
    /*                                   MODIFIERS                                 */
    /* -------------------------------------------------------------------------- */

    modifier onlyAdmin() {
        require(msg.sender == admin, "TrustOrb: NOT_ADMIN");
        _;
    }

    modifier profileExists(address user) {
        require(profiles[user].exists, "TrustOrb: PROFILE_NOT_FOUND");
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                INITIAL SETUP                                 */
    /* -------------------------------------------------------------------------- */

    constructor() {
        admin = msg.sender;
    }

    /* -------------------------------------------------------------------------- */
    /*                                CORE FUNCTIONS                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Create a TrustOrb identity.
     */
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

    /**
     * @notice Endorse another user’s TrustOrb.
     * @param user Address being endorsed.
     * @param points Trust points to award.
     */
    function endorse(address user, uint256 points)
        external
        profileExists(user)
    {
        require(user != msg.sender, "TrustOrb: SELF_ENDORSE");
        require(!hasEndorsed[msg.sender][user], "TrustOrb: ALREADY_ENDORSED");
        require(points > 0, "TrustOrb: INVALID_POINTS");

        hasEndorsed[msg.sender][user] = true;
        profiles[user].trustScore += points;

        emit Endorsed(msg.sender, user, points);
    }

    /**
     * @notice Update metadata for your TrustOrb.
     */
    function updateMetadata(string calldata newMetadata)
        external
        profileExists(msg.sender)
    {
        profiles[msg.sender].metadataURI = newMetadata;
        emit MetadataUpdated(msg.sender, newMetadata);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   ADMIN                                      */
    /* -------------------------------------------------------------------------- */

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "TrustOrb: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  VIEWERS                                     */
    /* -------------------------------------------------------------------------- */

    function getProfile(address user)
        external
        view
        returns (OrbProfile memory)
    {
        return profiles[user];
    }
}
