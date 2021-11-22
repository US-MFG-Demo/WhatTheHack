using System;
using System.Collections.Specialized;
using System.Security.Cryptography.X509Certificates;
using System.Web;

namespace app_financial
{
  public class CertificateValidationService : ICertificateValidationService
  {
    public bool ValidateCertificate(X509Certificate2 clientCertificate)
    {
      if(clientCertificate.Thumbprint == Environment.GetEnvironmentVariable("FINANCIAL_CERTIFICATE_THUMBPRINT")) {
        return true;
      }

      return false;
    }
  }
}