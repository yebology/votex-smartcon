// SPDX-License-Identifier

pragma solidity ^0.8.28;

import {console} from "forge-std/console.sol";

contract Votex {
    //
    struct Candidate {
        uint256 id;
        uint256 totalVote;
        string candidateName;
        string candidatePhoto;
        string candidateVision;
        string candidateMission;
    }
    struct Election {
        uint256 id;
        string electionTitle;
        string electionPicture;
        address electionCreator;
        uint256 electionStart;
        uint256 electionEnd;
        string electionDescription;
    }

    mapping(uint256 electionId => uint256[] candidateId) s_electionCandidate;
    mapping(uint256 electionId => address[] voter) s_electionVoter;
    mapping(address voter => mapping(uint256 electionId => bool isAlreadyVote)) s_isAlreadyVote;

    error VoterAlreadyVote(address voter, uint256 electionId);
    error InvalidElectionInput();

    Election[] private s_elections;
    Candidate[] private s_candidates;

    event newElectionHasBeenCreated(uint256 indexed electionId);
    event newCandidateHasBeenAdded(
        uint256 indexed electionId,
        uint256 indexed candidateId
    );
    event newVoteHasBeenAdded(
        address indexed voter,
        uint256 indexed electionId,
        uint256 indexed candidateId
    );

    modifier onlyVoteOneTimeInOneElection(address _voter, uint256 _electionId) {
        console.log("modi", s_isAlreadyVote[msg.sender][_electionId]);
        console.log("modif", _voter);
        require(
            s_isAlreadyVote[msg.sender][_electionId] == false,
            VoterAlreadyVote(_voter, _electionId)
        );
        _;
    }

    modifier checkElectionInput(
        string memory _electionTitle,
        string memory _electionPicture,
        uint256 _electionStart,
        uint256 _electionEnd,
        string memory _electionDescription,
        string[] memory _candidateNames,
        string[] memory _candidatePhotos,
        string[] memory _candidateVisions,
        string[] memory _candidateMissions
    ) {
        require(
            bytes(_electionTitle).length > 0 &&
                bytes(_electionPicture).length > 0 &&
                _electionStart > 0 &&
                _electionEnd > 0 &&
                _electionEnd > _electionStart &&
                _electionStart <= block.timestamp &&
                _candidateNames.length == _candidatePhotos.length &&
                _candidatePhotos.length == _candidateVisions.length &&
                _candidateVisions.length == _candidateMissions.length,
            InvalidElectionInput()
        );
        _;
    }

    function createNewElection(
        string memory _electionTitle,
        string memory _electionPicture,
        uint256 _electionStart,
        uint256 _electionEnd,
        string memory _electionDescription,
        string[] memory _candidateNames,
        string[] memory _candidatePhotos,
        string[] memory _candidateVisions,
        string[] memory _candidateMissions
    ) external {
        s_elections.push(
            Election({
                id: s_elections.length,
                electionTitle: _electionTitle,
                electionPicture: _electionPicture,
                electionCreator: msg.sender,
                electionStart: _electionStart,
                electionEnd: _electionEnd,
                electionDescription: _electionDescription
            })
        );

        uint256 length = _candidateNames.length;
        for (uint256 i = 0; i < length; i++) {
            _addNewCandidate(
                s_elections.length - 1,
                _candidateNames[i],
                _candidatePhotos[i],
                _candidateVisions[i],
                _candidateMissions[i]
            );
        }

        emit newElectionHasBeenCreated(s_elections.length - 1);
    }

    function _addNewCandidate(
        uint256 _electionId,
        string memory _candidateName,
        string memory _candidatePhoto,
        string memory _candidateVision,
        string memory _candidateMission
    ) private {
        s_candidates.push(
            Candidate({
                id: s_candidates.length,
                totalVote: 0,
                candidateName: _candidateName,
                candidatePhoto: _candidatePhoto,
                candidateVision: _candidateVision,
                candidateMission: _candidateMission
            })
        );
        s_electionCandidate[_electionId].push(s_candidates.length - 1);
        emit newCandidateHasBeenAdded(_electionId, s_candidates.length - 1);
    }

    function voteCandidate(
        uint256 _electionId,
        uint256 _candidateId
    ) external onlyVoteOneTimeInOneElection(msg.sender, _electionId) {
        s_electionVoter[_electionId].push(msg.sender);
        s_candidates[_candidateId].totalVote += 1;
        s_isAlreadyVote[msg.sender][_electionId] = true;
        emit newVoteHasBeenAdded(msg.sender, _electionId, _candidateId);
    }

    function getElections() external view returns (Election[] memory) {
        return s_elections;
    }

    function getCandidatesIdInOneElection(
        uint256 _electionId
    ) external view returns (uint256[] memory) {
        uint256[] memory candidateIds = s_electionCandidate[_electionId];
        return candidateIds;
    }

    function getCandidates() external view returns (Candidate[] memory) {
        return s_candidates;
    }

    function getTotalVoterInOneElection(
        uint256 _electionId
    ) external view returns (uint256) {
        return s_electionVoter[_electionId].length;
    }

    //
}
