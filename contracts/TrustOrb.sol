Default trust score = 50

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
// 
End
// 
