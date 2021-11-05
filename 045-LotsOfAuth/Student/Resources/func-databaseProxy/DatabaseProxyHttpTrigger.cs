using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Linq;

namespace func_databaseProxy
{
    public class DatabaseProxyHttpTrigger
    {
      private readonly DatabaseContext databaseContext;
      public DatabaseProxyHttpTrigger(DatabaseContext databaseContext) {
        this.databaseContext = databaseContext;
      }

        [FunctionName("database")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var blogs = databaseContext.Blogs.ToList();

            return new OkObjectResult(blogs);
        }
    }
}
