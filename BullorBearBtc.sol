// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BullOrBear {
    address public owner;
    uint public votingEndTime;
    bool public isVotingOpen;
    string public question;  // Variable pour stocker la question

    // Mappage pour les votes (bull = true, bear = false)
    mapping(address => bool) public votes;
    mapping(bool => uint) public voteCounts;  // Compte des votes pour 'bull' (true) ou 'bear' (false)

    event Voted(address indexed voter, bool predictedRise);
    event VotingEnded(bool predictedRise);
    event VotingRestarted(uint newVotingEndTime);

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut executer cette fonction."); 
        _;
    }

    modifier onlyDuringVoting() {
        require(isVotingOpen, "Le vote est ferme.");
        _;
    }

    modifier onlyAfterVoting() {
        require(block.timestamp >= votingEndTime, "Le vote n'est pas encore termine.");
        _;
    }

    constructor() {
        owner = msg.sender;
        votingEndTime = block.timestamp + 12 hours;  // Fixer la période de vote à 12 heures
        isVotingOpen = true;
        question = "Are you bull or bear on Bitcoin? (Bull = true, Bear = false)";  // Clarification de la question
    }

    // Fonction pour récupérer la question
    function getQuestion() public view returns (string memory) {
        return question;  // Retourner la question stockée
    }

    // Fonction pour voter
    function vote(bool _predictedRise) public onlyDuringVoting {
        require(votes[msg.sender] == false, "Vous avez deja vote.");
        
        votes[msg.sender] = true;
        voteCounts[_predictedRise] += 1;

        // Émettre un événement clair sur ce que signifie le vote
        if (_predictedRise) {
            emit Voted(msg.sender, true);  // "Bull" vote
        } else {
            emit Voted(msg.sender, false); // "Bear" vote
        }
    }

    // Fonction pour fermer automatiquement le vote après 12h
    function endVoting() public {
        require(block.timestamp >= votingEndTime, "Le vote n'est pas encore termine.");

        isVotingOpen = false;

        bool predictedRise = voteCounts[true] > voteCounts[false];  // Plus de votes pour bull (true) ou bear (false)?
        emit VotingEnded(predictedRise);
    }

    // Fonction pour relancer le vote
    function restartVoting() public onlyOwner {
        // Réinitialiser les votes et les résultats
        for (uint i = 0; i < voteCounts[true]; i++) {
            votes[msg.sender] = false; // Réinitialiser les votes des participants (c'est un exemple simplifié)
        }

        // Réinitialiser les résultats
        voteCounts[true] = 0;
        voteCounts[false] = 0;

        // Fixer une nouvelle période de 12 heures
        votingEndTime = block.timestamp + 12 hours;
        isVotingOpen = true;

        emit VotingRestarted(votingEndTime);
    }

    // Fonction pour vérifier le résultat
    function getResults() public view onlyAfterVoting returns (bool predictedRise, uint votesForRise, uint votesForFall) {
        return (voteCounts[true] > voteCounts[false], voteCounts[true], voteCounts[false]);
    }
}
