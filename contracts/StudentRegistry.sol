// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StudentRegistry {

    // Define the Student structure
    struct Student {
        address studentAddr;
        string name;
        uint256 studentId;
        uint8 age;
    }

    // Owner of the contract
    address public owner;

    // Constructor to set the contract owner
    constructor () {
        owner = msg.sender; // Address of the person that deploys the contract
    }

    // Dynamic array of students
    Student[] private students;

    // Mapping of student addresses to Student structs
    mapping(address => Student) public studentMapping;

    // Event emitted when a student is added
    event StudentAdded(address indexed studentAddr, string name, uint256 studentId, uint8 age);

    // Event emitted when a student is deleted
    event StudentDeleted(address indexed studentAddr, uint256 studentId);

    // Modifier to restrict access to only the owner
    modifier onlyOwner() { 
        require(owner == msg.sender, "You are not authorized");
        _;
    }

    // Modifier to check if the address is not zero
    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    // Function to add a student
    function addStudent(
        address _studentAddr, 
        string memory _name, 
        uint8 _age
    ) public onlyOwner {
        require(_studentAddr != address(0), "Invalid Address");
        require(bytes(_name).length > 0, "Name cannot be blank");
        require(_age >= 18, "Age must be at least 18");

        uint256 _studentId = students.length + 1; 
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId 
        });

        students.push(student); 
        studentMapping[_studentAddr] = student;

        emit StudentAdded(_studentAddr, _name, _studentId, _age); // Emit event when student is added
    }

    // Function to get a student by ID
    function getStudent(uint256 _studentId) public view returns (Student memory) {
        require(_studentId > 0 && _studentId <= students.length, "Invalid student ID");
        return students[_studentId - 1]; 
    }

    // Function to get a student from the mapping by address
    function getStudentFromMapping(address _studentAddr) public view returns (Student memory) {
        return studentMapping[_studentAddr];
    }

    // Function to delete a student from the mapping
    function deleteStudentFromMapping(address _studentAddr) public onlyOwner{
        uint256 studentId = studentMapping[_studentAddr].studentId; // Get the student ID before deleting

        delete studentMapping[_studentAddr];

        emit StudentDeleted(_studentAddr, studentId); // Emit event when student is deleted
    }

    // Function to update a student's information
    function updateStudent(
        uint256 _studentId,
        address _studentAddr, 
        string memory _name, 
        uint8 _age
    ) public onlyOwner {
        require(_studentId > 0 && _studentId <= students.length, "Invalid student ID");
        require(_age >= 18, "Student age must be at least 18");
        
        Student storage student = students[_studentId - 1];
        student.studentAddr = _studentAddr;
        student.name = _name;
        student.age = _age;

        studentMapping[_studentAddr] = student;
    }

    // Function to delete a student from the array
    function deleteStudent(uint256 _studentId) public onlyOwner {
        require(_studentId > 0 && _studentId <= students.length, "Invalid student ID");
        
        address studentAddr = students[_studentId - 1].studentAddr; // Get the student address before deleting

        // Move every student element after the deleted one position to the left
        for (uint256 i = _studentId - 1; i < students.length - 1; i++) {
            students[i] = students[i + 1];
            students[i].studentId = i + 1; // Update the studentID
        }
        // Remove last element
        students.pop();

        emit StudentDeleted(studentAddr, _studentId); // Emit event when student is deleted
    }
}
