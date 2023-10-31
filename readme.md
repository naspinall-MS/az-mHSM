# Azure mHSM Logging and Alerting Sample

The purpose of this repository is to provide basic guidance and sample code for Azure Managed HSM Key Vault logging and alerting.

## Description

A managed HSM is a single-tenant, Federal Information Processing Standards (FIPS) 140-2 validated, highly available, hardware security module (HSM) that has a customer-controlled security domain. While this script was created with Azure mHSM in mind, much of it can be repurposed for other types of Azure resources including but not limited to other types of Key Vaults.

## Getting Started

### Dependencies

* PowerShell 5.1 or greater
* Az modules 9.7.1 or greater
* Certificate tool (e.g. OpenSSL) or existing certificates for security domain

### Additional Instructions

* After the managed HSM is provisioned, you must create at least three RSA key pairs and send the public keys to the service when you request the security domain download. You also need to specify the minimum number of keys required (the quorum) to decrypt the security domain in the future. You must use a certificate generation tool or existing certificates in order to download the security domain. See helpful links below for more information.

* Query values, alert conditions, etc. are purely for demonstration purposes and should bew modified to suit your individual needs.

### Troubleshooting

* Some services require globally unique names. This sample script appends the current date to these service names and should be unique, but is not guaranteed.

## Authors

Nathan Aspinall  
[@naspinall-MS](https://github.com/naspinall-ms)

## Version History

* 1.0
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Helpful Links

* [Quickstart: Provision and activate a Managed HSM using Azure CLI](https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/quick-create-cli)
* [Security domain in Managed HSM overview](https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/security-domain)