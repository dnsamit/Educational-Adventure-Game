// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToAdventureGame {
    struct Player {
        address playerAddress;
        string username;
        uint256 score;
        uint256 level;
        uint256 experiencePoints;
        uint256[] completedQuests;
    }

    struct Quest {
        uint256 id;
        string description;
        uint256 reward;
        bool completed;
    }

    mapping(address => Player) public players;
    mapping(address => bool) public hasJoined;
    Quest[] public quests;

    event PlayerJoined(address indexed playerAddress, string username);
    event ScoreUpdated(address indexed playerAddress, uint256 newScore);
    event LevelUp(address indexed playerAddress, uint256 newLevel);
    event QuestCompleted(address indexed playerAddress, uint256 questId, uint256 reward);

    constructor() {
        // Initialize some quests
        quests.push(Quest(1, "Solve a math puzzle", 50, false));
        quests.push(Quest(2, "Complete a science quiz", 75, false));
        quests.push(Quest(3, "Read a historical article", 30, false));
    }

    function joinGame(string memory _username) public {
        require(!hasJoined[msg.sender], "Player has already joined.");
        
        players[msg.sender] = Player({
            playerAddress: msg.sender,
            username: _username,
            score: 0,
            level: 1,
            experiencePoints: 0,
            completedQuests: new uint256[](0)
        });
        
        hasJoined[msg.sender] = true;
        emit PlayerJoined(msg.sender, _username);
    }

    function updateScore(uint256 _score) public {
        require(hasJoined[msg.sender], "Player has not joined the game.");
        
        players[msg.sender].score += _score;
        emit ScoreUpdated(msg.sender, players[msg.sender].score);
        
        if (players[msg.sender].score >= 100) { // Example level-up condition
            levelUp();
        }
    }

    function levelUp() internal {
        players[msg.sender].level += 1;
        emit LevelUp(msg.sender, players[msg.sender].level);
    }

    function completeQuest(uint256 questId) public {
        require(hasJoined[msg.sender], "Player has not joined the game.");
        require(questId < quests.length, "Quest does not exist.");
        require(!quests[questId].completed, "Quest already completed.");

        quests[questId].completed = true;
        players[msg.sender].completedQuests.push(questId);
        players[msg.sender].score += quests[questId].reward;
        players[msg.sender].experiencePoints += quests[questId].reward;

        emit QuestCompleted(msg.sender, questId, quests[questId].reward);
        emit ScoreUpdated(msg.sender, players[msg.sender].score);
        
        if (players[msg.sender].score >= 100) { // Example level-up condition
            levelUp();
        }
    }

    function getPlayerInfo() public view returns (string memory, uint256, uint256, uint256) {
        require(hasJoined[msg.sender], "Player has not joined the game.");
        Player memory player = players[msg.sender];
        return (player.username, player.score, player.level, player.experiencePoints);
    }

    function getQuestInfo(uint256 questId) public view returns (string memory, uint256, bool) {
        require(questId < quests.length, "Quest does not exist.");
        Quest memory quest = quests[questId];
        return (quest.description, quest.reward, quest.completed);
    }

    function getAllQuests() public view returns (Quest[] memory) {
        return quests;
    }
}