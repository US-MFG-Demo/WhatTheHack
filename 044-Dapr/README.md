# What The Hack - Dapr

## Introduction
This repository contains several hands-on assignments that will introduce you to Dapr. You will start with a simple ASP.NET Core application that is composed of several microservices. In each assignment, you'll enhance the the application by adding Dapr building blocks and components. At the same time, you'll configure the application to consume Azure-based backing services. When complete, you'll have implemented the following Dapr building blocks:

- Service invocation
- State-management
- Publish / Subscribe
- Bindings
- Secrets management

As Dapr can run on a variety of hosts, you'll start by running Dapr in self-hosted mode on your computer. Then, you'll deploy the Dapr application to run in Azure Kubernetes Service.

## Learning Objectives

The assignments implement a traffic-control camera system that are commonly found on Dutch highways. Here's how the simulation works:

![Speeding cameras](.img/speed-trap-overview.png)

There's 1 entry-camera and 1 exit-camera per lane. When a car passes an entry-camera, a photo of the license plate is taken and the car and the timestamp is registered.

When the car passes an exit-camera, another photo and timestamp are registered. The system then calculates the average speed of the car based on the entry- and exit-timestamp. If a speeding violation is detected, a message is sent to the Central Fine Collection Agency (or CJIB in Dutch). The system retrieves the vehicle information and the vehicle owner is sent a notice for a fine.

### Architecture

The traffic-control application architecture consists of four microservices:

![Services](.img/services.png)

- The **Camera Simulation** is a .NET Core console application that will simulate passing cars.
- The **Traffic Control Service** is an ASP.NET Core WebAPI application that offers entry and exit endpoints: `/entrycam` and `/exitcam`.
- The **Fine Collection Service** is an ASP.NET Core WebAPI application that offers 1 endpoint: `/collectfine` for collecting fines.
- The **Vehicle Registration Service** is an ASP.NET Core WebAPI application that offers 1 endpoint: `/getvehicleinfo/{license-number}` for retrieving vehicle- and owner-information of a vehicle.

These services compose together to simulate a traffic control scenario.

The following sequence diagram describes how the application works:

<img src=".img/sequence.png" alt="Sequence diagram" style="zoom:67%;" />

1. The Camera Simulation generates a random license plate number and sends a *VehicleRegistered* message (containing this license plate number, a random entry-lane (1-3) and the timestamp) to the `/entrycam` endpoint of the TrafficControlService.
1. The TrafficControlService stores the *VehicleState* (license plate number and entry-timestamp).
1. After a random interval, the Camera Simulation sends a follow-up *VehicleRegistered* message to the `/exitcam` endpoint of the TrafficControlService. It contains the license plate number generated in step 1, a random exit-lane (1-3), and the exit timestamp.
1. The TrafficControlService retrieves the previously-stored *VehicleState*.
1. The TrafficControlService calculates the average speed of the vehicle using the entry- and exit-timestamp. It also stores the *VehicleState* with the exit timestamp for audit purposes, which is left out of the sequence diagram for clarity.
1. If the average speed is above the speed-limit, the TrafficControlService calls the `/collectfine` endpoint of the FineCollectionService. The request payload will be a *SpeedingViolation* containing the license plate number of the vehicle, the identifier of the road, the speeding-violation in KMh, and the timestamp of the violation.
1. The FineCollectionService calculates the fine for the speeding-violation.
1. The FineCollectionService calls the `/vehicleinfo/{license-number}` endpoint of the VehicleRegistrationService with the license plate number of the speeding vehicle to retrieve vehicle and owner information.
1. The FineCollectionService sends a fine notice to the owner of the vehicle by email.

All actions described in the previous sequence are logged to the console during execution so you can follow the flow.

The `../Student/Resources` folder in the repo contains the starting project for the workshop. It contains a version of the services that use plain HTTP communication and store state in memory. With each workshop assignment, you'll add a Dapr building block to enhance this application architecture.

> [!IMPORTANT]
> It's important to understand that all calls between services are direct, synchronous HTTP calls using the HttpClient library in .NET Core. While sometimes necessary, this type of synchronous communication [isn't considered a best practice](https://docs.microsoft.com/dotnet/architecture/cloud-native/service-to-service-communication#requestresponse-messaging) for distributed microservice applications. When possible, you should consider decoupling microservices using asynchronous messaging. However, decoupling communication can dramatically increase the architectural and operational complexity of an application. You'll soon see how Dapr reduces the inherent complexity of distributed microservice applications.

### End-state with Dapr applied

As you complete the lab assignments, you'll evolve the application architecture to work with Dapr and consume Azure-based backing services:

- Azure IoT Hub
- Azure Redis Cache
- Azure Service Bus
- Azure Logic Apps
- Azure Key Vault

The following diagram shows the end-state of the application:

<img src=".img/dapr-setup.png" alt="Dapr setup" style="zoom:67%;" />

1. To retrieve driver information using synchronous request/response communication between the FineCollectionService and VehicleRegistrationService, you'll implement the Dapr **service invocation** building block.
1. To send speeding violations to the FineCollectionService, you'll implement the Dapr **publish and subscribe** building block (asynchronous communication) with the Dapr Azure Service Bus component.
1. To store vehicle state, you'll implement the Dapr **state management** building block with the Dapr Azure Redis Cache component.
1. To send fine notices to the owner of a speeding vehicle by email, you'll implement the HTTP **output binding** building block with the Dapr Azure Logic App component.
1. To send vehicle info to the TrafficControlService, you'll use the Dapr **input binding** for MQTT using Dapr Azure IoT Hub component as the MQTT broker.
1. To retrieve a license key for the fine calculator component and credentials for connecting to the smtp server, you'll implement the Dapr **secrets management** building block with Dapr Azure Key Vault component.

The following sequence diagram shows how the solution will work after implementing Dapr:

<img src=".img/sequence-dapr.png" alt="Sequence diagram with Dapr" style="zoom:67%;" />

> [!NOTE]
> It's helpful to refer back to the preceding sequence diagram as you progress through the workshop assignments.

## Challenges
1. Challenge 0: **[Install tools and Azure pre-requisites](Student/Challenge-00.md)**
   - Install the pre-requisites tools and software as well as create the Azure resources required for the workshop.
2. Challenge 1: **[Run the application](Student/Challenge-01.md)**
   - Run the Traffic Control application to make sure everything works correctly
3. Challenge 2: **[Add Dapr service invocation](Student/Challenge-02.md)**
   - Add Dapr into the mix, using the Dapr service invocation building block.
4. Challenge 3: **[Add pub/sub messaging](Student/Challenge-03.md)**
   - Add Dapr publish/subscribe messaging to send messages from the TrafficControlService to the FineCollectionService.
5. Challenge 4: **[Add Dapr state management](Student/Challenge-04.md)**
   - Add Dapr state management in the TrafficControl service to store vehicle information.
5. Challenge 5: **[Add a Dapr output binding](Student/Challenge-05.md)**
   - Use a Dapr output binding in the FineCollectionService to send an email.
5. Challenge 6: **[Add a Dapr input binding](Student/Challenge-06.md)**
   - Add a Dapr input binding in the TrafficControlService. It'll receive entry- and exit-cam messages over the MQTT protocol.
5. Challenge 7: **[Add secrets management](Student/Challenge-07.md)**
   - Add the Dapr secrets management building block.
5. Challenge 8: **[Deploy to Azure Kubernetes Service (AKS)](Student/Challenge-08.md)**
   - Deploy the Dapr-enabled services you have written locally to an Azure Kubernetes Service (AKS) cluster.

## Prerequisites
- Git ([download](https://git-scm.com/))
- .NET 5 SDK ([download](https://dotnet.microsoft.com/download/dotnet/5.0))
- Visual Studio Code ([download](https://code.visualstudio.com/download)) with the following extensions installed:
  - [C#](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)
  - [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
  - [Install Bicep extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep))
- Docker for desktop ([download](https://www.docker.com/products/docker-desktop))
- Dapr CLI and Dapr runtime ([instructions](https://docs.dapr.io/getting-started/install-dapr-selfhost/))
- Install Azure CLI ([instructions]())
  - Linux ([instructions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#linux))
  - macOS ([instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos))
  - Windows ([instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli))
- Install Azure CLI Bicep tools ([instructions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli))

## Repository Contents
- `../Coach/Guides`
  - Coach's Guide and related files
- `../Student/Guides`
  - Student's Challenge Guide

## Contributors
- Jordan Bean
- Eldon Gormsen
- Sander Molenkamp
- Scott Rutz
- Marcelo Silva
- Rob Vettor
- Edwin van Wijk