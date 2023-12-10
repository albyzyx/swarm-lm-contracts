// Sources flattened with hardhat v2.19.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File contracts/BondingManager.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;

contract BondingManager {
    IERC20 public sltToken;

    mapping(string => address) public servers;
    mapping(address => bool) public isOrchestrator;

    event OrchestratorAdded(address indexed orchestrator);
    event OrchestratorRemoved(address indexed orchestrator);
    event ServerBound(string serverId, address serverAddress);
    event FundsTransferred(address indexed user, string serverId, uint256 amount);


    constructor(address _sltTokenAddress) {
        isOrchestrator[msg.sender] = true;
        sltToken = IERC20(_sltTokenAddress);
    }

    modifier onlyOrchestrator() {
        require(isOrchestrator[msg.sender], "Caller is not an orchestrator");
        _;
    }

    function addOrchestrator(address _orchestrator) public onlyOrchestrator {
        isOrchestrator[_orchestrator] = true;
        emit OrchestratorAdded(_orchestrator);
    }

    function removeOrchestrator(address _orchestrator) public onlyOrchestrator {
        isOrchestrator[_orchestrator] = false;
        emit OrchestratorRemoved(_orchestrator);
    }

    function bindServer(string memory serverId, address serverAddress) public {
        require(serverAddress != address(0), "Server address cannot be the zero address");
        require(servers[serverId] == address(0), "Server ID is already bound to an address");
        
        servers[serverId] = serverAddress;
        emit ServerBound(serverId, serverAddress);
    }


    function transferFunds(address user, string[] memory serverIds, uint256[] memory amounts) public onlyOrchestrator {
    require(serverIds.length == amounts.length, "Server IDs and amounts length mismatch");
    require(serverIds.length > 0, "No server IDs provided");

    uint256 totalAmount = 0;
    for (uint i = 0; i < serverIds.length; i++) {
        totalAmount += amounts[i];
        require(amounts[i] > 0, "Transfer amount must be greater than 0");
        }

    require(sltToken.allowance(user, address(this)) >= totalAmount, "Insufficient token allowance");
    require(sltToken.balanceOf(user) >= totalAmount, "Insufficient token balance");

    for (uint i = 0; i < serverIds.length; i++) {
        address recepient = servers[serverIds[i]] != address(0) ? servers[serverIds[i]] : msg.sender;
        require(sltToken.transferFrom(user, recepient, amounts[i]), "Token transfer failed");
        emit FundsTransferred(user, serverIds[i], amounts[i]);
        }
    }

    receive() external payable {}

    function withdraw(uint256 amount) public onlyOrchestrator {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }
}
