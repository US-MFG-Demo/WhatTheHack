using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Web.Http;
using System.Net;

namespace func_weather
{

  public class WeatherDayData
  {
    public DateTime Date { get; set; }
    public int Temperature { get; set; }

    public int Windspeed { get; set; }

    public int Humidity { get; set; }
  }
    public static class WeatherHttpTrigger
    {
        [FunctionName("weather")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            Random random = new Random();
            WeatherDayData weatherDayData = new WeatherDayData(){
              Date = DateTime.Now,
              Temperature = random.Next(0, 100),
              Windspeed = random.Next(0, 100),
              Humidity = random.Next(0, 100)
            };

            return new OkObjectResult(weatherDayData);
        }
    }
}
