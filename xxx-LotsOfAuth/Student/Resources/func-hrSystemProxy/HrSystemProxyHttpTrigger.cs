using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using System.Net.Http.Json;
using System.Net.Http.Headers;
using Microsoft.Identity.Client;
using System.Linq;

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
      HttpClient client;
        public HrSystemProxyHttpTrigger() {
          ConfidentialClientApplicationOptions confidentialClientApplicationOptions = new ConfidentialClientApplicationOptions(){
            Instance = Environment.GetEnvironmentVariable("AzureAd__Instance"),
            TenantId = Environment.GetEnvironmentVariable("AzureAd__TenantId"),
            ClientId = Environment.GetEnvironmentVariable("AzureAd__ClientId"),
            ClientSecret = Environment.GetEnvironmentVariable("AzureAd__ClientSecret")
          };
          confidentialClientApplication = ConfidentialClientApplicationBuilder.CreateWithApplicationOptions(confidentialClientApplicationOptions)
            .Build();
            client = new HttpClient();
        }
        [FunctionName("user")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var result = await confidentialClientApplication.AcquireTokenOnBehalfOf(new string[]{"access_as_user"}, 
              new UserAssertion(req.HttpContext.User.Identities.First().BootstrapContext.ToString(), 
                "urn:ietf:params:oauth:grant-type:jwt-bearer")).ExecuteAsync();

            UserData returnData;

            client.DefaultRequestHeaders.Clear();
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            returnData = await client.GetFromJsonAsync<UserData>($"{Environment.GetEnvironmentVariable("HR_SYSTEM_API_URL")}/api/user");

            return new OkObjectResult(returnData);
        }
    }
}
