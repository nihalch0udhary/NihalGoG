// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TrustOrb
 * @dev A decentralized trust and reputation system where users can rate others on-chain.
 */
contract TrustOrb {
    struct Rating {
        uint256 id;
        address rater;
        address ratedUser;
        uint8 score; // Rating between 1 and 5
        string feedback;
    }

    mapping(uint256 => Rating) public ratings;
    mapping(address => uint256[]) public userRatings;
    uint256 public totalRatings;

    event RatingSubmitted(uint256 indexed id, address indexed rater, address indexed ratedUser, uint8 score, string feedback);

    /**
     * @dev Submit a rating for a user.
     * @param _ratedUser Address of the user being rated.
     * @param _score Rating score (1 to 5).
     * @param _feedback Feedback text.
     */
    function submitRating(address _ratedUser, uint8 _score, string calldata _feedback) external {
        require(_ratedUser != address(0), "Invalid user address");
        require(_score >= 1 && _score <= 5, "Score must be between 1 and 5");

        totalRatings++;
        ratings[totalRatings] = Rating(totalRatings, msg.sender, _ratedUser, _score, _feedback);
        userRatings[_ratedUser].push(totalRatings);

        emit RatingSubmitted(totalRatings, msg.sender, _ratedUser, _score, _feedback);
    }

    /**
     * @dev Get average rating of a user.
     * @param _user The address of the user to check.
     * @return average rating score.
     */
    function getAverageRating(address _user) external view returns (uint256) {
        uint256[] memory userRatingIds = userRatings[_user];
        if (userRatingIds.length == 0) return 0;

        uint256 totalScore = 0;
        for (uint256 i = 0; i < userRatingIds.length; i++) {
            totalScore += ratings[userRatingIds[i]].score;
        }
        return totalScore / userRatingIds.length;
    }

    /**
     * @dev Get details of a specific rating by ID.
     */
    function getRating(uint256 _id) external view returns (address, address, uint8, string memory) {
        require(_id > 0 && _id <= totalRatings, "Rating does not exist");
        Rating memory r = ratings[_id];
        return (r.rater, r.ratedUser, r.score, r.feedback);
    }
}
