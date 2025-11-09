# Snowflake Key-Pair Authentication Setup

This document explains how to set up RSA key-pair authentication for your Snowflake O*NET integration.

## Why Key-Pair Authentication?

Snowflake's SQL API v2 requires **OAuth JWT tokens** or **RSA key-pair JWT tokens** for authentication. The previous session-based authentication was incompatible with the SQL API v2 endpoints. Key-pair authentication is the recommended approach for programmatic access.

## Prerequisites

- OpenSSL installed on your system
- Access to Snowflake with permissions to modify user authentication
- Xcode with access to your APIKeys.plist file

## Setup Steps

### 1. Generate RSA Key Pair

Open Terminal and run:

```bash
# Generate 2048-bit private key (PKCS#8 format, unencrypted)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt

# Generate public key from the private key
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
```

**Files created:**
- `rsa_key.p8` - Your private key (keep this secret!)
- `rsa_key.pub` - Your public key (this goes to Snowflake)

### 2. Get Public Key Fingerprint

Run this command to calculate the SHA256 fingerprint:

```bash
openssl rsa -pubin -in rsa_key.pub -outform DER | openssl dgst -sha256 -binary | openssl enc -base64
```

**Save the output** - this is your `SNOWFLAKE_PUBLIC_KEY_FINGERPRINT`

Example output: `yGNhXBcIoOzDGSomeBase64String==`

### 3. Format Public Key for Snowflake

Extract the key without PEM headers:

```bash
grep -v 'BEGIN PUBLIC KEY' rsa_key.pub | grep -v 'END PUBLIC KEY' | tr -d '\n'
```

**Copy the output** - you'll paste this into Snowflake.

### 4. Assign Public Key in Snowflake

Log into Snowflake (using SnowSQL or web UI) and run:

```sql
ALTER USER <your_username> SET RSA_PUBLIC_KEY='<paste_public_key_here>';
```

Example:

```sql
ALTER USER ONET_USER SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...';
```

**Verify it worked:**

```sql
DESC USER <your_username>;
```

Look for `RSA_PUBLIC_KEY_FP` in the output - it should show your key's fingerprint.

### 5. Update APIKeys.plist

Open `APIKeys.plist` in Xcode and add two new keys:

#### SNOWFLAKE_PRIVATE_KEY
Paste the **entire contents** of `rsa_key.p8` including the headers:

```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC7VJTUt9Us8cKj
...
[multiple lines]
...
-----END PRIVATE KEY-----
```

#### SNOWFLAKE_PUBLIC_KEY_FINGERPRINT
Paste the fingerprint from Step 2:

```
yGNhXBcIoOzDGSomeBase64String==
```

### 6. Secure Your Keys

**Important:** Add these to your `.gitignore`:

```
rsa_key.p8
rsa_key.pub
APIKeys.plist
```

Never commit private keys to version control!

## How It Works

1. **App generates JWT token** with these claims:
   - `iss`: `<ACCOUNT>.<USER>.SHA256:<FINGERPRINT>`
   - `sub`: `<ACCOUNT>.<USER>`
   - `iat`: Current timestamp
   - `exp`: Timestamp + 59 minutes

2. **JWT is signed** using your private key (RS256 algorithm)

3. **JWT is sent** to Snowflake API in Authorization header:
   ```
   Authorization: Bearer <jwt_token>
   X-Snowflake-Authorization-Token-Type: KEYPAIR_JWT
   ```

4. **Snowflake verifies** the JWT signature using the public key you assigned to your user

## Troubleshooting

### "Invalid private key" error
- Make sure you copied the **entire** private key including headers
- Verify the key is in PKCS#8 format (should start with `-----BEGIN PRIVATE KEY-----`)
- Check for extra whitespace or line breaks

### "JWT token is invalid" error
- Verify the public key fingerprint matches what's in Snowflake
- Check that the account identifier is correct and uppercase
- Ensure the username matches exactly (case-sensitive)

### "Public key not assigned" error
- Run `DESC USER <username>;` in Snowflake to verify the public key is set
- Check that you have the right permissions to modify user authentication

## Configuration Summary

Your `APIKeys.plist` should now have:

| Key | Description | Example |
|-----|-------------|---------|
| SNOWFLAKE_ACCOUNT | Account identifier | `abc12345` |
| SNOWFLAKE_USERNAME | Snowflake username | `ONET_USER` |
| SNOWFLAKE_WAREHOUSE | Warehouse name | `ONET_CAREER_AGENT_WH` |
| SNOWFLAKE_DATABASE | Database name | `ONET_CAREER_DB` |
| SNOWFLAKE_SCHEMA | Schema name | `CAREER_SCHEMA` |
| SNOWFLAKE_PRIVATE_KEY | Full private key with headers | `-----BEGIN PRIVATE KEY-----\n...` |
| SNOWFLAKE_PUBLIC_KEY_FINGERPRINT | SHA256 fingerprint | `yGNhXBcIoOzD...` |

**Note:** `SNOWFLAKE_PASSWORD` is no longer used with key-pair authentication.

## Testing

1. Build and run your app in Xcode
2. Check the console for authentication logs:
   ```
   🔧 Snowflake Configuration:
     Account: ✅ Set (abc12345...)
     Username: ✅ Set
     Private Key: ✅ Set (1728 chars)
     Public Key FP: ✅ Set
   ```
3. Test the O*NET integration by completing onboarding
4. Look for successful API calls in the console

## References

- [Snowflake Key-Pair Authentication Guide](https://docs.snowflake.com/en/user-guide/key-pair-auth)
- [Snowflake SQL API Authentication](https://docs.snowflake.com/en/developer-guide/sql-api/authenticating)
