// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
