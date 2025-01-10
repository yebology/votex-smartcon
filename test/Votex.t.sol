// SPDX-License-Identifier

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Votex} from "../src/Votex.sol";
import {VotexDeploy} from "../script/Votex.s.sol";

contract VotexTest is Test {
    //
    VotexDeploy votexDeploy;
    Votex votex;

    modifier createNewElection(
        string memory _electionTitle,
        string memory _electionPicture,
        uint256 _electionStart,
        uint256 _electionEnd,
        string memory _electionDescription
    ) {
        string[] memory _candidateNames = new string[](2);
        _candidateNames[0] = "Alice Johnson";
        _candidateNames[1] = "Bob Smith";

        string[] memory _candidatePhotos = new string[](2);
        _candidatePhotos[0] = "https://example.com/alice_photo.jpg";
        _candidatePhotos[1] = "https://example.com/bob_photo.jpg";

        string[] memory _candidateVisions = new string[](2);
        _candidateVisions[
            0
        ] = "Alice will focus on economic growth and healthcare reform.";
        _candidateVisions[
            1
        ] = "Bob will prioritize environmental policies and education improvement.";

        string[] memory _candidateMissions = new string[](2);
        _candidateMissions[
            0
        ] = "Alice's mission is to improve healthcare accessibility and job creation.";
        _candidateMissions[
            1
        ] = "Bob's mission is to enhance environmental sustainability and reduce inequality.";

        votex.createNewElection(
            _electionTitle,
            _electionPicture,
            _electionStart,
            _electionEnd,
            _electionDescription,
            _candidateNames,
            _candidatePhotos,
            _candidateVisions,
            _candidateMissions
        );
        _;
    }

    function setUp() public {
        votexDeploy = new VotexDeploy();
        votex = votexDeploy.run();
    }

    function testSuccessfullyCreateNewElection()
        public
        createNewElection(
            "Presidential Election 2025",
            "https://example.com/election2025.jpg",
            1673052000,
            1673138400,
            "This is a dummy description for the 2025 presidential election. Voters will choose the next president."
        )
    {
        uint256 expectedElectionTotal = 1;
        uint256 actualElectionTotal = votex.getElections().length;

        uint256 expectedElectionTotalCandidateInOneElection = 2;
        uint256 actualElectionTotalCandidateInOneElection = votex
            .getCandidatesIdInOneElection(0)
            .length;

        uint256 expectedTotalCandidate = 2;
        uint256 actualTotalCandidate = votex.getCandidates().length;

        assertEq(expectedElectionTotal, actualElectionTotal);
        assertEq(
            expectedElectionTotalCandidateInOneElection,
            actualElectionTotalCandidateInOneElection
        );
        assertEq(expectedTotalCandidate, actualTotalCandidate);
    }

    function testSuccessfullyVoteCandidate()
        public
        createNewElection(
            "Presidential Election 2025",
            "https://example.com/election2025.jpg",
            1673052000,
            1673138400,
            "This is a dummy description for the 2025 presidential election. Voters will choose the next president."
        )
    {
        votex.voteCandidate(0, 1);
        uint256 expectedTotalVote = 1;
        uint256 actualTotalVote = votex.getCandidates()[1].totalVote;

        assertEq(expectedTotalVote, actualTotalVote);
    }

    function testRevertIfUserVoteTwice()
        public
        createNewElection(
            "Presidential Election 2025",
            "https://example.com/election2025.jpg",
            1673052000,
            1673138400,
            "This is a dummy description for the 2025 presidential election. Voters will choose the next president."
        )
    {
        vm.startPrank(address(1));
        votex.voteCandidate(0, 1);
        vm.expectRevert(
            abi.encodeWithSelector(Votex.VoterAlreadyVote.selector),
            address(1),
            0
        );
        votex.voteCandidate(0, 0);
        vm.stopPrank();
    }
    //
}
