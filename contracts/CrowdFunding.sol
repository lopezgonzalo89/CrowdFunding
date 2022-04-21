// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    enum State {
        Open,
        Closed
    }

    struct Project {
        string id;
        string name;
        string description;
        State state;
        uint256 funds;
        uint256 fundraisingGoal;
        address payable author;
    }
    struct Contribution {
        address contributor;
        uint256 value;
    }

    mapping(string => Project) public projects;
    Project private project;

    mapping(string => Contribution[]) public contributions;

    /* constructor(string memory _id, string memory _name, string memory _description, uint _fundraisingGoal) {
        project = Project(_id, _name, _description, State.Open, 0, _fundraisingGoal, payable(msg.sender));
        projects[_id] = project;
    } */

    function addProject(
        string memory _id,
        string memory _name,
        string memory _description,
        uint256 _fundraisingGoal
    ) public {
        project = Project(
            _id,
            _name,
            _description,
            State.Open,
            0,
            _fundraisingGoal,
            payable(msg.sender)
        );
        projects[_id] = project;
    }

    event ChangeStatus(address author, State newState);

    event NewFound(address author, uint256 amount);
    event RestFund(uint256 RestFound);

    modifier onlyOwner(string memory _idProject) {
        require(
            msg.sender == projects[_idProject].author,
            "Only owner can change the project state"
        );
        _;
    }

    modifier notOwner(string memory _idProject) {
        require(msg.sender != projects[_idProject].author, "Owner can't fund");
        _;
    }

    // error StatusClosed(string status);

    function fundProject(string memory _idProject)
        public
        payable
        notOwner(_idProject)
    {
        require(
            projects[_idProject].state == State.Open,
            "The project is Closed"
        );
        require(msg.value > 0, "Value must be greater than zero");

        // TODO: chequear que el projecto exista
        projects[_idProject].author.transfer(msg.value);
        projects[_idProject].funds += msg.value;

        // Add contributor
        contributions[projects[_idProject].id].push(
            Contribution(msg.sender, msg.value)
        );

        emit NewFound(msg.sender, msg.value);
        emit RestFund(projects[_idProject].fundraisingGoal - project.funds);
    }

    function changeProjectsState(string memory _idProject, State newState)
        public
        onlyOwner(_idProject)
    {
        require(
            projects[_idProject].state != newState,
            "New state must be different"
        );
        projects[_idProject].state = newState;
        emit ChangeStatus(projects[_idProject].author, newState);
    }
}
