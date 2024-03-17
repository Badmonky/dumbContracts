// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract AddressSubmission {
    address public owner;
    IERC20 public usdcContract;

    struct Submission {
        address user;
        string deliveryAddress;
        bool shipped;
    }

    Submission[] public submissions;

    constructor(address _usdcContract) {
        owner = msg.sender;
        usdcContract = IERC20(_usdcContract);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function submitAddress(string memory deliveryAddress, uint256 usdcAmount) public {
        require(usdcContract.transferFrom(msg.sender, address(this), usdcAmount), "Transfer failed");
        submissions.push(Submission(msg.sender, deliveryAddress, false));
    }

    function getSubmissions() public view onlyOwner returns (Submission[] memory) {
        return submissions;
    }

    function getUnshippedSubmissions() public view onlyOwner returns (Submission[] memory) {
        uint unshippedCount = 0;
        for (uint i = 0; i < submissions.length; i++) {
            if (!submissions[i].shipped) {
                unshippedCount++;
            }
        }

        Submission[] memory unshippedSubmissions = new Submission[](unshippedCount);
        uint currentIndex = 0;
        for (uint i = 0; i < submissions.length; i++) {
            if (!submissions[i].shipped) {
                unshippedSubmissions[currentIndex] = submissions[i];
                currentIndex++;
            }
        }
        return unshippedSubmissions;
    }

    function markShipped(uint submissionIndex) public onlyOwner {
        submissions[submissionIndex].shipped = true;
    }

    function withdrawUSDC(uint256 amount) public onlyOwner {
        require(usdcContract.transfer(owner, amount), "Withdrawal failed");
    }
}
