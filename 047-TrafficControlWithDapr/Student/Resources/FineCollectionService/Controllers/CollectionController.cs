using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using FineCollectionService.DomainServices;
using FineCollectionService.Helpers;
using FineCollectionService.Models;
using FineCollectionService.Proxies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace FineCollectionService.Controllers
{
    [ApiController]
    [Route("")]
    public class CollectionController : ControllerBase
    {
        private static string _fineCalculatorLicenseKey;
        private readonly ILogger<CollectionController> _logger;
        private readonly IFineCalculator _fineCalculator;
        private readonly VehicleRegistrationService _vehicleRegistrationService;

        public CollectionController(ILogger<CollectionController> logger,
            IFineCalculator fineCalculator, VehicleRegistrationService vehicleRegistrationService)
        {
            _logger = logger;
            _fineCalculator = fineCalculator;
            _vehicleRegistrationService = vehicleRegistrationService;

            // set finecalculator component license-key
            if (_fineCalculatorLicenseKey == null)
            {
                _fineCalculatorLicenseKey = "HX783-K2L7V-CRJ4A-5PN1G";
            }
        }

        // Programmatic approach to subscribing to pub/sub events
        // Call well known endpoint to retrieve subscriptions for this service: /dapr/subscribe
        [Route("/dapr/subscribe")]
        [HttpGet()]
        public object Subscribe()
        {
            return new object[]
            {
                new
                {
                    pubsubname = "pubsub",
                    topic = "collectfine",
                    route = "/collection"
                }
            };
        }


        // Dapr subscription.yaml file routes messages to "collectfine" route.
        [Route("collectfine")]
        [HttpPost()]
        // Legacy pre-Dapr included speedingViolation parameter
        //public async Task<ActionResult> CollectFine(SpeedingViolation speedingViolation)
        
        public async Task<ActionResult> CollectFine([FromBody] System.Text.Json.JsonDocument cloudevent)
        {

            // Extract and parse raw JSON from request body            
            var data = cloudevent.RootElement.GetProperty("data");
            var speedingViolation = new SpeedingViolation()
            {
                VehicleId = data.GetProperty("vehicleId").GetString(),
                RoadId = data.GetProperty("roadId").GetString(),
                Timestamp = data.GetProperty("timestamp").GetDateTime(),
                ViolationInKmh = data.GetProperty("violationInKmh").GetInt32()
            };
            decimal fine = _fineCalculator.CalculateFine(_fineCalculatorLicenseKey, speedingViolation.ViolationInKmh);

            // get owner info
            var vehicleInfo = await _vehicleRegistrationService.GetVehicleInfo(speedingViolation.VehicleId);

            // log fine
            string fineString = fine == 0 ? "tbd by the prosecutor" : $"{fine} Euro";
            _logger.LogInformation($"Sent speeding ticket to {vehicleInfo.OwnerName}. " +
                $"Road: {speedingViolation.RoadId}, Licensenumber: {speedingViolation.VehicleId}, " +
                $"Vehicle: {vehicleInfo.Brand} {vehicleInfo.Model}, " +
                $"Violation: {speedingViolation.ViolationInKmh} Km/h, Fine: {fineString}, " +
                $"On: {speedingViolation.Timestamp.ToString("dd-MM-yyyy")} " +
                $"at {speedingViolation.Timestamp.ToString("hh:mm:ss")}.");

            // send fine by email
            // TODO

            return Ok();
        }
    }
}
