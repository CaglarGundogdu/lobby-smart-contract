// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lobby {

    struct Room {
        string name;
        uint256 capacity;
        uint256 minEntryPrice;
        uint256 balance;
        address[] players;
    }

    // Owner of the contract
    // Only the owner distribute rewards to the users
    address payable owner;
    mapping(string => Room) public rooms;

    constructor() payable {
        // Contract owner 
        owner = payable(msg.sender);
    }

    // Create new room
    function createRoom(string memory _roomName, uint256 _capacity, uint256 _minEnrtyPrice) public {
        
        Room storage room = rooms[_roomName];
        // check room is not created before
        require(room.capacity == 0);
        address[] memory players;
        rooms[_roomName] = Room(_roomName, _capacity, _minEnrtyPrice, 0, players);
    }

    // Enter room with _roomName
    function enterRoom(string memory _roomName) public payable {
        
        Room storage room = rooms[_roomName];
        // check room created 
        require(room.capacity > 0);
        // check room full
        require(room.capacity > room.players.length);
        // check user pay min entry price
        require(msg.value >= room.minEntryPrice);
        room.balance += msg.value;
        room.players.push(msg.sender);

        // Collect entry price in owner
        owner.transfer(msg.value);
    }

    // Share room rewards to the winners, _roomName, _rank1, _rank2, _rank3
    function shareRewards(string memory _roomName, address payable _rank1, address payable _rank2, address payable _rank3) public payable{
        
        // Only owner share rewards
        require(owner == msg.sender);
    
        Room storage room = rooms[_roomName];
        // check room created/valid 
        require(room.capacity > 0);
        
        // reward calculation
        uint256 reward1 = room.balance * 5 / 10;
        uint256 reward2 = room.balance * 3 / 10;
        uint256 reward3 = room.balance * 2 / 10;

        // send rewards
        (bool sent1, ) = _rank1.call{value: reward1}("");
        require(sent1, "Failed to send reward to Rank1");
        (bool sent2, ) = _rank2.call{value: reward2}("");
        require(sent2, "Failed to send reward to Rank2");
        (bool sent3, ) = _rank3.call{value: reward3}("");
        require(sent3, "Failed to send reward to Rank3");
    }

    // Implemented for debugging
    function playersInRoom(string memory _roomName) public view returns(address[] memory) {
        return rooms[_roomName].players;
    }
}