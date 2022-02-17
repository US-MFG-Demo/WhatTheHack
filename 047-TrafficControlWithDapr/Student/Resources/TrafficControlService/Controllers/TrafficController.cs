﻿using System.Data.Common;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using TrafficControlService.Events;
using TrafficControlService.DomainServices;
using TrafficControlService.Models;
using System.Net.Http;
using System.Net.Http.Json;
using TrafficControlService.Repositories;
using Dapr.Client;

namespace TrafficControlService.Controllers
{
    [ApiController]
    [Route("")]
    public class TrafficController : ControllerBase
    {
        private readonly HttpClient _httpClient;
        private readonly IVehicleStateRepository _vehicleStateRepository;
        private readonly ILogger<TrafficController> _logger;
        private readonly ISpeedingViolationCalculator _speedingViolationCalculator;
        private readonly string _roadId;

        public TrafficController(
            ILogger<TrafficController> logger,
            HttpClient httpClient,
            IVehicleStateRepository vehicleStateRepository,
            ISpeedingViolationCalculator speedingViolationCalculator)
        {
            _logger = logger;
            _httpClient = httpClient;
            _vehicleStateRepository = vehicleStateRepository;
            _speedingViolationCalculator = speedingViolationCalculator;
            _roadId = speedingViolationCalculator.GetRoadId();
        }

        [HttpPost("entrycam")]
        public async Task<ActionResult> VehicleEntry(VehicleRegistered msg)
        {
            try
            {
                // log entry
                _logger.LogInformation($"ENTRY detected in lane {msg.Lane} at {msg.Timestamp.ToString("hh:mm:ss")} " +
                    $"of vehicle with license-number {msg.LicenseNumber}.");

                // store vehicle state
                var vehicleState = new VehicleState
                {
                    LicenseNumber = msg.LicenseNumber,
                    EntryTimestamp = msg.Timestamp
                };
                await _vehicleStateRepository.SaveVehicleStateAsync(vehicleState);

                return Ok();
            }
            catch
            {
                return StatusCode(500);
            }
        }

        [HttpPost("exitcam")]
        public async Task<ActionResult> VehicleExit(VehicleRegistered msg, [FromServices]DaprClient daprClient)
        {
            try
            {
                // get vehicle state
                var vehicleState = await _vehicleStateRepository.GetVehicleStateAsync(msg.LicenseNumber);
                if (vehicleState == null)
                {
                    return NotFound();
                }

                // log exit
                _logger.LogInformation($"EXIT detected in lane {msg.Lane} at {msg.Timestamp.ToString("hh:mm:ss")} " +
                    $"of vehicle with license-number {msg.LicenseNumber}.");

                // update state
                vehicleState.ExitTimestamp = msg.Timestamp;
                await _vehicleStateRepository.SaveVehicleStateAsync(vehicleState);

                // handle possible speeding violation
                int violation = _speedingViolationCalculator.DetermineSpeedingViolationInKmh(
                    vehicleState.EntryTimestamp, vehicleState.ExitTimestamp);
                if (violation > 0)
                {
                    _logger.LogInformation($"Speeding violation detected ({violation} KMh) of vehicle" +
                        $"with license-number {vehicleState.LicenseNumber}.");

                    var speedingViolation = new SpeedingViolation
                    {
                        VehicleId = msg.LicenseNumber,
                        RoadId = _roadId,
                        ViolationInKmh = violation,
                        Timestamp = msg.Timestamp
                    };

                    // publish speedingviolation
                    await daprClient.PublishEventAsync("pubsub", "collectfine", speedingViolation);

                    // code for Dapr declarative approach to pub/sub
                    // var message = JsonContent.Create<SpeedingViolation>(speedingViolation);
                    // // Dapr call to sidecar on port 3600 using built-in HTTP API. 
                    // // The sidecar is responsbile for publishing the message to a message broker.
                    // await _httpClient.PostAsync("http://localhost:3600/v1.0/publish/collectfine", message);


                    // legacy pre-Dapr code
                    // note how endpoint of receiver is hardcoded
                    //await _httpClient.PostAsync("http://localhost:6001/collectfine", message);
                }

                return Ok();
            }
            catch
            {
                return StatusCode(500);
            }
        }
    }
}
