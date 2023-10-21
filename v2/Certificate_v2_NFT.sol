// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CertificateRegistry is ERC721, Ownable {
    struct Student {
        uint256 id;
        string name;
        string institution;
        string major;
        uint256 graduationYear;
        uint256[] certificateIds; // IDs de los títulos asociados al estudiante
    }

    struct Certificate {
        uint256 id;
        string title;
        uint256 studentId;
    }

    uint256 public studentCount;
    uint256 public certificateCount;
    mapping(uint256 => Student) public students;
    mapping(uint256 => Certificate) public certificates;
    mapping(string => bool) public isTitleUsed; // Para evitar títulos duplicados
    mapping(uint256 => mapping(string => bool))
        public isStudentCertificateAdded; // Control de títulos por estudiante

    constructor() ERC721("Certificate", "CERT") {}

    // Función para agregar un estudiante
    function addStudent(
        string memory _name,
        string memory _institution,
        string memory _major,
        uint256 _graduationYear
    ) public onlyOwner {
        studentCount++;
        students[studentCount] = Student({
            id: studentCount,
            name: _name,
            institution: _institution,
            major: _major,
            graduationYear: _graduationYear,
            certificateIds: new uint256[](0)
        });

        _mint(msg.sender, studentCount);
    }

    // Función para agregar un título a un estudiante
    function addCertificate(
        uint256 _studentId,
        string memory _title
    ) public onlyOwner {
        /* // Verifica si el estudiante ya tiene un certificado con el mismo certificateName
        for (uint i = 0; i < student_has_certificates[id].length; i++) {
            uint256 certificateId = student_has_certificates[id][i];
            require(
                !Strings.equal(
                    certificates[certificateId].certificateName,
                    certificateName
                ),
                "Ya existe un certificado con el mismo nombre para este estudiante"
            );
        } */

        require(
            _studentId <= studentCount && _studentId > 0,
            "Estudiante no valido"
        );
        require(!isTitleUsed[_title], "El titulo ya ha sido utilizado");
        require(
            !isStudentCertificateAdded[_studentId][_title],
            "Este estudiante ya tiene este titulo"
        );

        certificateCount++;
        Student storage student = students[_studentId];
        certificates[certificateCount] = Certificate({
            id: certificateCount,
            title: _title,
            studentId: _studentId
        });

        // Asocia el título al estudiante
        student.certificateIds.push(certificateCount);

        // Marca el título como utilizado
        isTitleUsed[_title] = true;

        // Marca el título como agregado al estudiante
        isStudentCertificateAdded[_studentId][_title] = true;
    }
}
