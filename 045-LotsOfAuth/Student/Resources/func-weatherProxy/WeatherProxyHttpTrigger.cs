using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net.Http;
using System.Net.Http.Json;

namespace func_weatherProxy
{
  public class WeatherDayData
  {
    public DateTime Date { get; set; }
    public int Temperature { get; set; }

    public int Windspeed { get; set; }

    public int Humidity { get; set; }
  }
    public static class WeatherProxyHttpTrigger
    {
        private static HttpClient httpClient = new HttpClient();
        [FunctionName("weather")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            var response = await httpClient.GetFromJsonAsync<WeatherDayData>(
              $"{Environment.GetEnvironmentVariable("WEATHER_API_URL")}/api/weather?code={Environment.GetEnvironmentVariable("WEATHER_API_SUBSCRIPTION_KEY")}");

            return new OkObjectResult(response);
        }
    }
}
