# Snowflake RSA Key-Pair Authentication Issue

## Issue Summary

**Problem**: iOS app cannot create a valid `SecKey` from a PKCS#8 RSA private key for Snowflake JWT authentication, despite successful key generation and configuration.

**Symptom**: App falls back to sample career data instead of fetching real data from Snowflake O*NET database.

**Error**: `SecKeyCreate init(RSAPrivateKey) failed: -50` followed by `❌ Failed to get SecKey reference from keychain`

---

## Timeline

### Initial State
- App was configured to use Snowflake with username/password authentication
- Snowflake SQL API v2 was added, which requires JWT-based key-pair authentication
- Missing credentials: `SNOWFLAKE_PRIVATE_KEY` and `SNOWFLAKE_PUBLIC_KEY_FINGERPRINT`

### Setup Process
1. Generated 2048-bit RSA key pair using OpenSSL:
   ```bash
   openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
   openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
   ```

2. Calculated public key fingerprint:
   ```bash
   openssl rsa -pubin -in rsa_key.pub -outform DER | openssl dgst -sha256 -binary | openssl enc -base64
   ```
   Result: `BkjUSXetuERyBbPbqLc+jgEaxcFhm6th9O6QK1iat7k=`

3. Assigned public key to Snowflake user:
   ```sql
   ALTER USER MINTUSEDDY SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiqfHRR7pp3OSGvsGW3y93A4imVLftb7+EoK6LhQNzO7Jx7lj4Bw438NXYjnAistlwt7GvS/3Rjyu0wisu+j2wRxj+7HBbn4BytfRzia+Mvc+qNUsPVXmrvRZXO4rxag0O4qiBPvRcG5RR+0AauIZFzq9XNDVWdfPSAtbdY1hLb0UdsZNqpm/WTswpovz3jAOsRHzweo8NrZZIEnkW8HTiGb/8cONlYijqVK14yG+2xOFi7EdsfxV/+JxAbwhI7GVMcEsM0zwzit4GmiGzrVVUSdTXxujMoIdX3VUxMd7hxewOfJ9H+66YcAqZgUNLKRO/PHIcGy5L+4U9XY3ZW8/9wIDAQAB';
   ```

4. Updated `APIKeys.plist` with:
   - `SNOWFLAKE_PRIVATE_KEY`: Full PKCS#8 private key (single-line format)
   - `SNOWFLAKE_PUBLIC_KEY_FINGERPRINT`: `BkjUSXetuERyBbPbqLc+jgEaxcFhm6th9O6QK1iat7k=`

---

## Systems Involved

### 1. Snowflake Configuration
- **Account**: WAB63663
- **Username**: MINTUSEDDY
- **Warehouse**: ONET_CAREER_AGENT_WH
- **Database**: ONET_CAREER_DB
- **Schema**: CAREER_SCHEMA
- **Authentication Method**: RSA key-pair with JWT tokens

### 2. iOS Application
- **Platform**: iOS (macOS Darwin 23.5.0)
- **Language**: Swift
- **Security Framework**: Apple's Security framework (SecKey, SecKeychain)
- **File**: `carrer/Services/Networking/SnowflakeService.swift`

### 3. Key Format
- **Private Key Format**: PKCS#8 (begins with `-----BEGIN PRIVATE KEY-----`)
- **Key Size**: 2048 bits
- **Decoded Size**: 1217 bytes (DER format)
- **DER Header**: `308204bd...` (valid PKCS#8 structure)

---

## Current Code Implementation

### Location
**File**: `/Users/eddym/Downloads/app/carrer/carrer/Services/Networking/SnowflakeService.swift`
**Method**: `signWithPrivateKey(data: Data) throws -> Data`
**Lines**: ~218-292

### Code (Current Implementation)

```swift
/// Sign data with RSA private key
private func signWithPrivateKey(data: Data) throws -> Data {
    // Parse private key from PEM format
    let privateKeyString = privateKey
        .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
        .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
        .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
        .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
        .replacingOccurrences(of: "\n", with: "")
        .replacingOccurrences(of: "\r", with: "")
        .replacingOccurrences(of: " ", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    guard let keyData = Data(base64Encoded: privateKeyString, options: .ignoreUnknownCharacters) else {
        print("❌ Failed to decode base64 private key")
        throw SnowflakeError.invalidConfiguration
    }

    print("🔑 Decoded key data length: \(keyData.count) bytes")

    // Import key using Keychain (workaround for PKCS#8 support)
    let tag = "com.carrer.snowflake.privatekey".data(using: .utf8)!

    // First, delete any existing key with this tag
    let deleteQuery: [CFString: Any] = [
        kSecClass: kSecClassKey,
        kSecAttrApplicationTag: tag
    ]
    SecItemDelete(deleteQuery as CFDictionary)

    // Import the key into the keychain temporarily
    let importQuery: [CFString: Any] = [
        kSecClass: kSecClassKey,
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass: kSecAttrKeyClassPrivate,
        kSecAttrApplicationTag: tag,
        kSecValueData: keyData,
        kSecReturnRef: true
    ]

    var item: CFTypeRef?
    let importStatus = SecItemAdd(importQuery as CFDictionary, &item)

    print("🔑 Keychain import status: \(importStatus) (0 = success)")

    guard importStatus == errSecSuccess else {
        print("❌ Failed to import key to keychain: \(importStatus)")
        throw SnowflakeError.invalidConfiguration
    }

    guard let secKey = item as! SecKey? else {
        print("❌ Failed to get SecKey reference from keychain")
        throw SnowflakeError.invalidConfiguration
    }

    print("✅ Successfully imported SecKey via keychain")

    // Sign using SHA256withRSA
    var signError: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(
        secKey,
        .rsaSignatureMessagePKCS1v15SHA256,
        data as CFData,
        &signError
    ) as Data? else {
        if let error = signError?.takeRetainedValue() {
            print("❌ Failed to create signature: \(error)")
        }
        // Clean up the keychain entry
        SecItemDelete(deleteQuery as CFDictionary)
        throw SnowflakeError.authenticationFailed
    }

    // Clean up the keychain entry after signing
    SecItemDelete(deleteQuery as CFDictionary)

    print("✅ Successfully signed data with RSA key")
    return signature
}
```

---

## Debug Output

```
🔧 Snowflake Configuration:
  Account: ✅ Set (WAB63663...)
  Username: ✅ Set
  Private Key: ✅ Set (1676 chars)
  Public Key FP: ✅ Set
  Warehouse: ONET_CAREER_AGENT_WH
  Database: ONET_CAREER_DB
  Schema: CAREER_SCHEMA
🔑 Decoded key data length: 1217 bytes
SecKeyCreate init(RSAPrivateKey) failed: -50
🔑 Keychain import status: 0 (0 = success)
❌ Failed to get SecKey reference from keychain
❌ Error generating career suggestions: Snowflake credentials not configured properly
```

---

## Analysis

### What Works ✅
1. Private key is successfully read from `APIKeys.plist` (1676 chars including PEM headers)
2. Base64 decoding succeeds (1217 bytes of DER-encoded key data)
3. DER data has correct PKCS#8 header (`308204bd`)
4. Keychain import returns `errSecSuccess` (status code 0)
5. Public key successfully assigned to Snowflake user

### What Fails ❌
1. **Initial attempt**: `SecKeyCreateWithData` fails with error -50 (`errSecParam`)
   - This is expected - iOS has poor PKCS#8 support via direct `SecKeyCreateWithData`

2. **Keychain workaround**: `SecItemAdd` succeeds but doesn't return a `SecKey` reference
   - Status code: 0 (success)
   - But `item` (CFTypeRef) is `nil` or cannot be cast to `SecKey`
   - This suggests the key was added but the reference wasn't returned

### Root Cause Hypothesis

The issue is that `SecItemAdd` with `kSecReturnRef: true` is **not returning the SecKey reference** even though the import succeeds. This could be due to:

1. **iOS Keychain Limitation**: PKCS#8 keys may not support `kSecReturnRef` during import
2. **Missing Attribute**: May need additional attributes like `kSecAttrCanSign: true`
3. **Platform Limitation**: iOS may require a two-step process (add, then query)

---

## Attempted Solutions

### Attempt 1: Direct `SecKeyCreateWithData`
```swift
let keyDict: [CFString: Any] = [
    kSecAttrKeyType: kSecAttrKeyTypeRSA,
    kSecAttrKeyClass: kSecAttrKeyClassPrivate,
    kSecAttrKeySizeInBits: 2048
]
SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error)
```
**Result**: ❌ Error -50 (errSecParam)

### Attempt 2: Keychain Import with `kSecReturnRef`
```swift
let importQuery: [CFString: Any] = [
    kSecClass: kSecClassKey,
    kSecAttrKeyType: kSecAttrKeyTypeRSA,
    kSecAttrKeyClass: kSecAttrKeyClassPrivate,
    kSecAttrApplicationTag: tag,
    kSecValueData: keyData,
    kSecReturnRef: true
]
SecItemAdd(importQuery as CFDictionary, &item)
```
**Result**: ❌ Import succeeds (status 0) but `item` is nil/cannot be cast to SecKey

---

## Questions for Expert Review

1. **Is `SecItemAdd` with `kSecReturnRef` the correct approach for PKCS#8 keys on iOS?**
   - Should we use a two-step process (add, then query with `SecItemCopyMatching`)?

2. **Are there missing attributes needed for signing?**
   - Should we add `kSecAttrCanSign: true`, `kSecAttrKeyType: kSecAttrKeyTypeRSA`, etc.?

3. **Is there a better way to import PKCS#8 keys on iOS?**
   - Should we convert PKCS#8 to PKCS#1 format instead?
   - Should we use `SecKeyCreateWithData` with different attributes?

4. **Platform-specific issue?**
   - Does this work differently on iOS vs macOS?
   - Is there a minimum iOS version requirement for PKCS#8 support?

5. **Alternative approaches?**
   - Use a third-party crypto library (SwiftCrypto, CryptoKit)?
   - Convert key format server-side?
   - Use a different signing algorithm?

---

## Expected Behavior

The app should:
1. Read PKCS#8 private key from `APIKeys.plist`
2. Create a `SecKey` from the key data
3. Generate JWT token with claims (iss, sub, iat, exp)
4. Sign JWT with RS256 algorithm using the private key
5. Send authenticated requests to Snowflake SQL API v2
6. Receive and display real O*NET career data

---

## Related Files

### Configuration
- `/Users/eddym/Downloads/app/carrer/APIKeys.plist` - Contains credentials
- `/Users/eddym/Downloads/app/carrer/rsa_key.p8` - Private key file (PKCS#8)
- `/Users/eddym/Downloads/app/carrer/rsa_key.pub` - Public key file

### Code
- `/Users/eddym/Downloads/app/carrer/carrer/Services/Networking/SnowflakeService.swift` - Main authentication logic
- `/Users/eddym/Downloads/app/carrer/carrer/Services/Networking/APIConfig.swift` - Reads APIKeys.plist

### Documentation
- `/Users/eddym/Downloads/app/carrer/SNOWFLAKE_KEYPAIR_SETUP.md` - Setup guide

---

## References

- [Snowflake Key-Pair Authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth)
- [Snowflake SQL API v2](https://docs.snowflake.com/en/developer-guide/sql-api/authenticating)
- [Apple SecKey Documentation](https://developer.apple.com/documentation/security/seckey)
- [Apple Keychain Services](https://developer.apple.com/documentation/security/keychain_services)

---

## Contact

For questions about this issue, please contact the development team or review the Snowflake and iOS Security Framework documentation.
