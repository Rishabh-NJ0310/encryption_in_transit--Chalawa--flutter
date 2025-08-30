import { encrypt, decrypt, generateDHKeyPair, computeSharedSecret, dhEncrypt, dhDecrypt } from '../src';
import { writeFileSync } from 'fs';

// Generate test data for Flutter compatibility testing
function generateCompatibilityTestData() {
    const testData = {
        basic: {
            plainText: "Hello from Node.js!",
            password: "test-password-123",
            encrypted: ""
        },
        diffieHellman: {
            alice: {
                privateKey: "",
                publicKey: ""
            },
            bob: {
                privateKey: "",
                publicKey: ""
            },
            sharedSecret: "",
            plainText: "DH encrypted message from Node.js",
            encrypted: ""
        }
    };

    // Test basic encryption
    testData.basic.encrypted = encrypt({
        plainText: JSON.stringify(testData.basic.plainText),
        password: testData.basic.password
    });

    console.log('Basic encryption test:');
    console.log('Original:', testData.basic.plainText);
    console.log('Encrypted:', testData.basic.encrypted);

    const basicDecrypted = decrypt({
        encryptedText: testData.basic.encrypted,
        password: testData.basic.password
    });
    console.log('Decrypted:', basicDecrypted);
    console.log('Match:', basicDecrypted === testData.basic.plainText);

    // Test Diffie-Hellman
    const aliceKeyPair = generateDHKeyPair();
    const bobKeyPair = generateDHKeyPair();

    testData.diffieHellman.alice.privateKey = aliceKeyPair.privateKey;
    testData.diffieHellman.alice.publicKey = aliceKeyPair.publicKey;
    testData.diffieHellman.bob.privateKey = bobKeyPair.privateKey;
    testData.diffieHellman.bob.publicKey = bobKeyPair.publicKey;

    const aliceSecret = computeSharedSecret({
        privateKey: aliceKeyPair.privateKey,
        otherPublicKey: bobKeyPair.publicKey
    });

    const bobSecret = computeSharedSecret({
        privateKey: bobKeyPair.privateKey,
        otherPublicKey: aliceKeyPair.publicKey
    });

    testData.diffieHellman.sharedSecret = aliceSecret;

    console.log('\nDiffie-Hellman test:');
    console.log('Secrets match:', aliceSecret === bobSecret);
    console.log('Shared secret:', aliceSecret.substring(0, 32) + '...');

    testData.diffieHellman.encrypted = dhEncrypt({
        plainText: JSON.stringify(testData.diffieHellman.plainText),
        sharedSecret: aliceSecret
    });

    console.log('DH Original:', testData.diffieHellman.plainText);
    console.log('DH Encrypted:', testData.diffieHellman.encrypted);

    const dhDecrypted = dhDecrypt({
        encryptedText: testData.diffieHellman.encrypted,
        sharedSecret: bobSecret
    });
    console.log('DH Decrypted:', dhDecrypted);
    console.log('DH Match:', dhDecrypted === testData.diffieHellman.plainText);

    // Save test data for Flutter to use
    writeFileSync('compatibility-test-data.json', JSON.stringify(testData, null, 2));
    console.log('\nTest data saved to compatibility-test-data.json');

    return testData;
}

generateCompatibilityTestData();
