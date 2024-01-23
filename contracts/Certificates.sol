// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.6 <0.9.0;

contract Certificates {
    // Variables.
    uint256 public amountCertificates;

    constructor() {
        amountCertificates = 0;
    }

    // Estudiante.
    struct Student {
        uint256 id;
        string name;
        string lastname;
        string docNumber;
        string docType;
        string sex;
        uint256 registrationNumber;
    }
    // Carrera.
    struct UniversityDegree {
        string universityName;
        string academicUnit; // Facultad
        string degreeProgramName; // Nombre de la carrera
        string degreeProgramCurriculum; // Plan de estudios
        string degreeType; // Tipo de carrara
    }

    // Titulo.
    struct Certificate {
        uint256 id;
        Student student;
        UniversityDegree universityDegree;
        string waferNumber; // Numero de oblea.
        uint256 createdAt;
        uint256 updatedAt;
        bool active; // Activo
    }

    event CertificateCreated(
        uint256 id,
        uint256 date,
        string docNumber,
        uint chainId,
        address origin
    );

    // Titulos (idTitulo => titulo).
    mapping(uint256 => Certificate) private certificates;

    // Obleas (codigo_oblea => idTitulo).
    mapping(string => uint256) private wafers;

    // Estudiantes con titulos. (idEstudiante => idTitulo).
    mapping(uint256 => uint256[]) private student_has_certificates;

    function getCertificatesById(
        uint256 id
    ) public view returns (Certificate memory certificate) {
        return certificates[id];
    }

    function getCertificatesByStudentId(
        uint256 studentId
    ) public view returns (Certificate[] memory) {
        uint256[] memory studentCertificatesids = student_has_certificates[
            studentId
        ];
        Certificate[] memory studentCertificates = new Certificate[](
            studentCertificatesids.length
        );
        for (uint256 i = 0; i < studentCertificatesids.length; i++) {
            // Filtro aquellas activas.
            if (certificates[studentCertificatesids[i]].active) {
                studentCertificates[i] = certificates[
                    studentCertificatesids[i]
                ];
            }
            // studentCertificates[i] = certificates[studentCertificatesids[i]];
        }
        return studentCertificates;
    }

    function createCertificate(Certificate memory _certificate) public {
        // Aumento el indice.
        amountCertificates++;
        // Creo el nuevo Id del titulo.
        uint256 newCertificateId = amountCertificates;

        // Controlo que no exista el codigo de la oblea en el sistema.
        require(
            wafers[_certificate.waferNumber] == 0,
            "El numero de oblea ya existe."
        );

        // Obtengo los ids de los titulos del estudiante.
        uint256[] memory studentCertificatesids = student_has_certificates[
            _certificate.student.id
        ];

        // Verifica si el estudiante ya tiene un certificado asociado a la misma carrera.
        if (studentCertificatesids.length > 0) {
            for (uint i = 0; i < studentCertificatesids.length; i++) {
                uint256 certificateId = studentCertificatesids[i];
                require(
                    keccak256(
                        bytes(
                            certificates[certificateId]
                                .universityDegree
                                .degreeProgramName
                        )
                    ) !=
                        keccak256(
                            bytes(
                                _certificate.universityDegree.degreeProgramName
                            )
                        ),
                    "Ya existe un certificado con el mismo nombre para este estudiante"
                );
            }
        }

        // Creo el titulo con el nuevo id y lo guardo en el mapa.
        certificates[newCertificateId] = Certificate(
            newCertificateId,
            _certificate.student,
            _certificate.universityDegree,
            _certificate.waferNumber,
            block.timestamp,
            block.timestamp,
            true
        );

        // Relaciono la oblea con el titulo.
        wafers[_certificate.waferNumber] = newCertificateId;

        // Creo la relacion entre titulo y el estudiante.

        // Si el estudiante es nuevo. No tiene titulos asociados.
        if (studentCertificatesids.length == 0) {
            // Reutilizo la lista.
            studentCertificatesids = new uint256[](1);
            // Guardo el id del titulo.
            studentCertificatesids[0] = newCertificateId;
            student_has_certificates[
                _certificate.student.id
            ] = studentCertificatesids;

            // todo: realizar controles para no sobreescribir claves.
        } else {
            // Creo la nueva lista de studentCertificatesids.
            uint256[] memory newStudentCertificatesIds = new uint256[](
                studentCertificatesids.length + 1
            );
            for (uint256 i = 0; i < studentCertificatesids.length; i++) {
                newStudentCertificatesIds[i] = studentCertificatesids[i];
            }
            // Agrego el nuevo id del titulo.
            newStudentCertificatesIds[
                studentCertificatesids.length
            ] = newCertificateId;
            student_has_certificates[
                _certificate.student.id
            ] = newStudentCertificatesIds;
        }
        emit CertificateCreated(
            newCertificateId,
            block.timestamp,
            _certificate.student.docNumber,
            block.chainid,
            tx.origin
        );
    }

    function deleteCertificate(uint256 certificateId) public {
        // Obtengo el titulo.
        Certificate memory certificate = certificates[certificateId];
        // Inhabilito el acceso del titulo.
        certificate.active = false;
        certificate.updatedAt = block.timestamp;
        certificates[certificateId] = certificate;

        // Elimino la oblea.
        wafers[certificate.waferNumber] = 0;

        emit CertificateCreated(
            certificate.id,
            block.timestamp,
            certificate.student.docNumber,
            block.chainid,
            tx.origin
        );
    }
}
