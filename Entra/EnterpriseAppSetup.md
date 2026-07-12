# Enterprise App: Intune-Entra-Device-Management

## Successfully Created Resources

### 1. Application Registration
- **Display Name:** Intune-Entra-Device-Management
- **Application ID (Client ID):** `2ca1cd1c-2709-4f44-97b5-d5de4da70aed`
- **Application Object ID:** `ce292370-36e6-4570-9323-034678e4c64b`
- **Tenant:** corpreliablerepairs
- **Tenant ID:** `6d798b83-1769-4a29-9f77-8b9fae1560df`

### 2. Service Principal
- **Service Principal ID:** `5b6d93e4-8fa2-4be2-85a1-d714e4b0b36b`
- **Enabled:** Yes
- **Account Status:** Active

### 3. Client Secret
- **Secret ID:** `0e6ca28d-0d2f-45b8-bbc6-bf8065e4b095`
- **Display Name:** EnterpriseAppSecret-2026
- **Value:** `2ER8Q~KD5a003KRVDu7Wqo3JDF_8PP9GoGnXjbSn`
- **Expires:** 2028-06-26T06:55:30Z
- **⚠️ IMPORTANT:** Save this secret securely - it cannot be retrieved later

### 4. Self-Signed Certificate
- **Thumbprint:** `602B4ADBE69B0D625F93D21ACFA7AFE7F9724324`
- **Subject:** CN=Intune-Entra-Device-Management
- **Issued:** 2026-06-26
- **Expires:** 2028-06-26
- **Files:**
  - **Private Key & Cert:** `C:\Users\udehn\AppData\Local\Temp\IntuneTentureEntraCert.pfx`
  - **Public Cert Only:** `C:\Users\udehn\AppData\Local\Temp\IntuneTentureEntraCert.cer`
  - **Password for PFX:** `TempPassword123!`

## Configured Permissions

The app has been configured to request the following Microsoft Graph permissions:
- ✅ DeviceManagementManagedDevices.ReadWrite.All (Intune Devices)
- ✅ Device.ReadWrite.All (Entra Devices)
- ✅ User.Read.All (Users)
- ✅ Group.Read.All (Groups)

## Next Steps (Required to Complete Setup)

### Option 1: Complete via Azure Portal (Recommended)
1. **Upload Certificate:**
   - Go to Azure Portal → App Registrations → Intune-Entra-Device-Management
   - Select "Certificates & secrets"
   - Click "Upload certificate"
   - Browse to: `C:\Users\udehn\AppData\Local\Temp\IntuneTentureEntraCert.cer`
   - Click "Add"

2. **Grant Admin Consent:**
   - In the same app, go to "API permissions"
   - Review the requested permissions (already configured)
   - Click "Grant admin consent for [Tenant]"
   - Click "Yes" to confirm

### Option 2: Using PowerShell (Admin Rights Required)
```powershell
# Connect to Microsoft Graph
Connect-MgGraph -ClientId "2ca1cd1c-2709-4f44-97b5-d5de4da70aed" -TenantId "6d798b83-1769-4a29-9f77-8b9fae1560df" -CertificatePath "C:\Users\udehn\AppData\Local\Temp\IntuneTentureEntraCert.pfx" -CertificatePassword (ConvertTo-SecureString "TempPassword123!" -AsPlainText -Force)

# Use the connection for Graph API calls
```

## Security Notes

1. **Client Secret:** Store `2ER8Q~KD5a003KRVDu7Wqo3JDF_8PP9GoGnXjbSn` securely (e.g., Azure Key Vault)
2. **Certificate Private Key:** The PFX file contains the private key and should be stored securely
3. **Certificate Password:** Change `TempPassword123!` in production environments
4. **Credentials Rotation:** Plan to rotate certificates and secrets periodically

## Certificate Details

The self-signed certificate includes:
- **Key Usage:** Digital Signature
- **Extended Key Usage:** Server Authentication, Client Authentication
- **Public Key Size:** 2048-bit RSA
- **Signature Algorithm:** sha256RSA

## File Locations

All certificate files are stored in: `C:\Users\udehn\AppData\Local\Temp\`
- `IntuneTentureEntraCert.pfx` - Certificate with private key
- `IntuneTentureEntraCert.cer` - Public certificate only
- `cert_base64.txt` - Base64 encoded certificate

**Note:** These temp files should be backed up or moved to a permanent secure location.

## To Use This App

### For Client Secret Authentication:
```powershell
$credential = New-Object System.Management.Automation.PSCredential(
    "2ca1cd1c-2709-4f44-97b5-d5de4da70aed",
    (ConvertTo-SecureString "2ER8Q~KD5a003KRVDu7Wqo3JDF_8PP9GoGnXjbSn" -AsPlainText -Force)
)
```

### For Certificate Authentication:
```powershell
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq "602B4ADBE69B0D625F93D21ACFA7AFE7F9724324" }
```

---
**Created:** 2026-06-26
**Last Updated:** 2026-06-26
