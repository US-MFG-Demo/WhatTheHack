using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Authentication.Certificate;
using System.Security.Claims;

namespace app_financial
{
  public class Startup
  {
    public Startup(IConfiguration configuration)
    {
      Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
      services.AddControllers();
      services.Configure<ForwardedHeadersOptions>(options =>
    {
      options.ForwardedHeaders =
              ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    });

      // Configure the application to client certificate forwarded the frontend load balancer
      services.AddCertificateForwarding(options => { options.CertificateHeader = "X-ARR-ClientCert"; });
      services.AddSingleton<CertificateValidationService>();

      // Add certificate authentication so when authorization is performed the user will be created from the certificate
      services.AddAuthentication(CertificateAuthenticationDefaults.AuthenticationScheme).AddCertificate(options => {
        options.AllowedCertificateTypes = CertificateTypes.All; //NOTE: in a real-world app, don't trust self-signed certs
        options.ValidateValidityPeriod = true;
        options.Events = new CertificateAuthenticationEvents{
          OnCertificateValidated = context => {
            var validationService = context.HttpContext.RequestServices.GetRequiredService<CertificateValidationService>();

              if (validationService.ValidateCertificate(context.ClientCertificate)) {
                  var claims = new[]
                       {
                        new Claim(
                            ClaimTypes.NameIdentifier,
                            context.ClientCertificate.Subject,
                            ClaimValueTypes.String,
                            context.Options.ClaimsIssuer),
                        new Claim(
                            ClaimTypes.Name,
                            context.ClientCertificate.Subject,
                            ClaimValueTypes.String,
                            context.Options.ClaimsIssuer)
                    };

                  context.Principal = new ClaimsPrincipal(
                      new ClaimsIdentity(claims, context.Scheme.Name));
                  context.Success();
              }
              else {
                  context.Fail("Incorrect certificate");
              }
              
              return Task.CompletedTask;
          }
        };
      });

      services.AddSwaggerGen(c =>
      {
        c.SwaggerDoc("v1", new OpenApiInfo { Title = "app_financial", Version = "v1" });
      });
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
      if (env.IsDevelopment())
      {
        app.UseDeveloperExceptionPage();
        app.UseSwagger();
        app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "app_financial v1"));
      }
      app.UseForwardedHeaders();
      app.UseCertificateForwarding();
      app.UseHttpsRedirection();

      app.UseRouting();

      app.UseAuthentication();
      app.UseAuthorization();

      app.UseEndpoints(endpoints =>
      {
        endpoints.MapControllers();
      });
    }
  }
}
