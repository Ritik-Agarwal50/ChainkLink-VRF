// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomWinnerGame is VRFConsumerBase, Ownable {
    uint public fee;
    bytes32 public keyHash;
    address[] public players;
    uint8 maxPlayers;
    bool public gameStarted;
    uint entryFee;
    uint public gameId;

    event GameStarted(uint gameId, uint8 maxPlayers, uint entryFee);
    event PlayerJoined(uint gameId, address player);
    event GameEnded(uint gameId, address winner, bytes32 requestId);

    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 vrfkeyHash,
        uint vrfFee
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfkeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

    function startGame(uint8 _maxplayers, uint256 _entryFee) public onlyOwner {
        require(!gameStarted, "Game is currrently running!!!");
        delete players;
        maxPlayers = _maxplayers;
        gameStarted = true;
        entryFee = _entryFee;
        gameId += 1;
        emit GameStarted(gameId, maxPlayers, entryFee);
    }

    function joinGame() public payable {
        require(gameStarted, "Game has not been started yet sir");
        require(msg.value == entryFee, "Value sent is not equal to entry fee");
        require(players.length < maxPlayers, "Game is Full");
        players.push(msg.sender);
        emit PlayerJoined(gameId, msg.sender);
        if (players.length == maxPlayers) {
            getRandomWinner();
        }
    }

    function fulfillRandomness(bytes32 requestId, uint randomness)
        internal
        virtual
        override
    {
        uint winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
        emit GameEnded(gameId, winner, requestId);
        gameStarted = false;
    }

    function getRandomWinner() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK token");
        return requestRandomness(keyHash, fee);
    }

    receive() external payable {}

    fallback() external payable {}
}
