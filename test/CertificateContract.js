const Certificate = artifacts.require("Certificates");

contract("Certificate", () => {
    before(async () => {
        this.certificateContract = await Certificate.deployed();
    });

    it('migrate deployed successfully', async () => {
        const address = await this.certificateContract.address;
        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    });

    it('get certificates counter', async () => {
        const certificateCounter = await this.certificateContract.amountCertificates();
        assert.equal(certificateCounter, 0);
    });

    it('create certificate', async () => {
        await this.certificateContract.
            createCertificate(
                'Ingeniero en sistemas',
                'Fernando Vargas',
                412217783028516,
            );
        const certificateCounter = await this.certificateContract.amountCertificates();
        const studentsCounter = await this.certificateContract.amountStudents();
        assert.equal(certificateCounter, 1);
        assert.equal(studentsCounter, 1);
        assert.equal(certificateCounter, 1);
    });

});