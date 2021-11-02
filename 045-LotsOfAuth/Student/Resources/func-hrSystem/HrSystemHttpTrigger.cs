using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Security.Principal;
using System.Security.Claims;

namespace func_hrSystem
{
  public class UserData {
    public int UserId { get; set; }

    public string Username { get; set; }
    public int Salary { get; set; }

  }
    public static class HrSystemHttpTrigger
    {
        [FunctionName("user")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            Random random = new Random();
            ClaimsPrincipal identity = req.HttpContext.User;

            UserData returnValue = new UserData(){
              Username = identity.Identity.Name,
              Salary = random.Next(100000, 200000),
              UserId = random.Next()
            };

            return new OkObjectResult(returnValue);
        }
    }
}
