const Certificate = artifacts.require("Certificates");

contract("Certificate", () => {
    before(async () => {
        this.certificateContract = await Certificate.deployed();
    });

    it('migrate deployed successfully', async () => {
        const address = await this.certificateContract.address;
        console.log(address);
        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    });

    it('get certificates counter', async () => {
        const certificateCounter = await this.certificateContract.amountCertificates();
        assert.equal(certificateCounter, 0);
    });

    it("Prueba de idempotencia: No se pueden crear dos titulos iguales (prueba numero de oblea.)", async () => {

        // Datos titulo.
        const certificate1 = {
            student: {
                docNumber: "41221778",
                docType: "DNI",
                name: "Federico",
                lastname: "Verges",
                sex: "Masculino",
                registrationNumber: 3028516,
                id: 412217783028516,
            },
            active: true,
            universityDegree: {
                academicUnit: "Facultad de Ciencias Físico Matemáticas y Naturales",
                degreeProgramName: "Ingeniería en Electrónica",
                degreeProgramCurriculum: "16-10",
                degreeType: "POSGRADO",
                universityName: "Universidad Nacional de San Luis",
            },
            createdAt: 0,
            id: 0,
            updatedAt: 0,
            waferNumber: "123123213",
        };


        // Llama a la función para crear el certificado.
        await this.certificateContract.createCertificate(certificate1);

        // Verifica que el evento "CertificateCreated" haya sido emitido.
        const events = await this.certificateContract.getPastEvents("CertificateCreated");
        assert.equal(events.length, 1, "El evento CertificateCreated no se emitió correctamente.");
        console.log(events);

        // Verifica que el certificado fue creado correctamente.
        const certificates = await this.certificateContract.getCertificatesByStudentId(certificate1.student.id);

        assert.lengthOf(certificates, 1, "Se ha creado el certificado correctamente.");
        try {
            // Vuelvo a cargar el mismo titulo.
            await this.certificateContract.createCertificate(certificate1);

            // Si continua normalmente, arrojo error.
            throw new Error('No se pueden crear dos certificados con el mismo numero de oblea.');

        } catch (error) {
            console.info(
                "Control de idempotencia exitoso. No se pueden cargar dos certificados iguales. Transaccion revertida.",
                error.message);
        }

    });

    it("Prueba de idempotencia con estudiante: Un estudiante no puede tener multiples titulos con el mismo nombre", async () => {


        // Datos del certificado que deseas crear
        const certificate = {
            id: 0,
            student: {
                id: 123453000000,
                name: "Nombre",
                lastname: "Apellido",
                docType: 'DNI',
                docNumber: "3000000",
                sex: "M",
                registrationNumber: 1235,
            },
            universityDegree: {
                universityName: "Universidad",
                academicUnit: "Facultad",
                degreeProgramName: "Ingeniería en Alimentos",
                degreeProgramCurriculum: "12-10",
                degreeType: "Grado",
            },
            waferNumber: "1234ABCDEG",
            createdAt: 0,
            updatedAt: 0,
            active: true
        };

        const certificate2 = {
            id: 0,
            student: {
                id: 123453000000,
                name: "Nombre",
                lastname: "Apellido",
                docType: 'DNI',
                docNumber: "3000000",
                sex: "M",
                registrationNumber: 1235,
            },
            universityDegree: {
                universityName: "Universidad",
                academicUnit: "Facultad",
                degreeProgramName: "Ingeniería en Alimentos",
                degreeProgramCurriculum: "12-10",
                degreeType: "Grado",
            },
            waferNumber: "1234ABCDSFG", // Distinta oblea.
            createdAt: 0,
            updatedAt: 0,
            active: true
        };


        // Llama a la función para crear el certificado.
        await this.certificateContract.createCertificate(certificate);

        // Verifica que el evento "CertificateCreated" haya sido emitido.
        const events = await this.certificateContract.getPastEvents("CertificateCreated");
        assert.equal(events.length, 1, "El evento CertificateCreated no se emitió correctamente.");
        console.log(events)

        // Verifica que el certificado fue creado correctamente.
        const certificates = await this.certificateContract.getCertificatesByStudentId(certificate.student.id);

        // console.log(JSON.stringify(certificate));

        try {
            // Creo el certificado 2.
            await this.certificateContract.createCertificate(certificate2);
            // Si continua normalmente, arrojo error.
            throw new Error('El estudiante ya posee un título con ese nombre');

        } catch (error) {
            console.error("Control de exitoso. Transaccion revertida.", error.message);
        }
    });
});

