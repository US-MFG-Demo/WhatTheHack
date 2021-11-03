using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Identity.Web.Resource;

namespace app_financial.Controllers
{
    public class FinancialData {
      public int DailyIncome { get; set; }
      public int DailyProfit { get; set; }
    }

    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class FinancialController : ControllerBase
    {
        private Random random;
        private readonly ILogger<FinancialController> _logger;

        public FinancialController(ILogger<FinancialController> logger)
        {
            _logger = logger;
            random = new Random();
        }

        [HttpGet]
        public FinancialData Get()
        {
          FinancialData financialData = new FinancialData{
            DailyIncome = random.Next(0, 1000000)
          };
          financialData.DailyProfit = random.Next(0, financialData.DailyIncome);

          return financialData;
        }
    }
}
