// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableStakingDemo {
    // Total points accumulated by all stakers.
    uint256 public totalPoints;
    
    // Mapping from staker address to their individual points.
    mapping(address => uint256) public stakerPoints;
    
    // Mapping from staker address to the last time they claimed rewards.
    mapping(address => uint256) public lastClaimTime;
    
    // Fixed reward rate (tokens per second) for demonstration.
    uint256 public constant REWARD_RATE = 100;

    event Staked(address indexed staker, uint256 points);
    event Unstaked(address indexed staker, uint256 points);
    event RewardClaimed(address indexed staker, uint256 reward);

    /**
     * @notice Stake a given amount of points.
     * @param _points The number of points to stake.
     */
    function stake(uint256 _points) external {
        require(_points > 0, "Must stake more than zero");

        // If the staker is new, record the claim time.
        if (stakerPoints[msg.sender] == 0) {
            lastClaimTime[msg.sender] = block.timestamp;
        }

        stakerPoints[msg.sender] += _points;
        totalPoints += _points;

        emit Staked(msg.sender, _points);
    }

    /**
     * @notice Unstake a given amount of points.
     * @param _points The number of points to unstake.
     */
    function unstake(uint256 _points) external {
        require(stakerPoints[msg.sender] >= _points, "Not enough staked points");

        stakerPoints[msg.sender] -= _points;
        totalPoints -= _points;

        emit Unstaked(msg.sender, _points);
    }

    /**
     * @notice Claim accrued rewards based on staked points.
     * @dev Vulnerable calculation: uses current totalPoints without adjusting for historical changes.
     * @return reward The reward amount for the caller.
     */
    function claimRewards() external returns (uint256 reward) {
        uint256 timeElapsed = block.timestamp - lastClaimTime[msg.sender];
        uint256 totalReward = timeElapsed * REWARD_RATE;

        // Vulnerability: The reward share is calculated using the current totalPoints,
        // which may have changed since the stake was made.
        if (totalPoints > 0) {
            reward = (totalReward * stakerPoints[msg.sender]) / totalPoints;
        } else {
            reward = 0;
        }

        // Update the claim time.
        lastClaimTime[msg.sender] = block.timestamp;

        emit RewardClaimed(msg.sender, reward);
        return reward;
    }
}
