using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Identity.Client;
using System.Net.Http;
using System.Net.Http.Headers;

namespace func_hrSystemProxy
{
  public class UserData {
    public int UserId { get; set; }

    public string Username { get; set; }
    public int Salary { get; set; }

  }
    public class HrSystemProxyHttpTrigger
    {
      IConfidentialClientApplication confidentialClientApplication;
        public HrSystemProxyHttpTrigger() {
          ConfidentialClientApplicationOptions confidentialClientApplicationOptions = new ConfidentialClientApplicationOptions(){
            Instance = Environment.GetEnvironmentVariable("AzureAd__Instance"),
            TenantId = Environment.GetEnvironmentVariable("AzureAd__TenantId"),
            ClientId = Environment.GetEnvironmentVariable("AzureAd__ClientId"),
            ClientSecret = Environment.GetEnvironmentVariable("AzureAd__ClientSecret")
          };
          confidentialClientApplication = ConfidentialClientApplicationBuilder.CreateWithApplicationOptions(confidentialClientApplicationOptions)
            .Build();
        }
        [FunctionName("user")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var accessToken = confidentialClientApplication.AcquireTokenOnBehalfOf("", req.HttpContext.User);

            UserData returnData;

            using(HttpRequestMessage httpRequestMessage = new HttpRequestMessage()) {
              httpRequestMessage.Headers.Authorization = new AuthenticationHeader("Bearer", accessToken);

              returnData = await confidentialClientApplication.GetFromJsonAsync<UserData>($"{Environment.GetEnvironmentVariable("HR_SYSTEM_API_URL")}/api/user");
            }
            return new OkObjectResult(returnData);
        }
    }
}
