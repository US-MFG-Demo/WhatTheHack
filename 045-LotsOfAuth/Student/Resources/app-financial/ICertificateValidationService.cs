using System.Security.Cryptography.X509Certificates;

namespace app_financial {
  public interface ICertificateValidationService {
    bool ValidateCertificate(X509Certificate2 clientCertificate);
  }
}