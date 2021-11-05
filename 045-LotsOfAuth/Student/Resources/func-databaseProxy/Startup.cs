using System;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(func_databaseProxy.Startup))]

namespace func_databaseProxy {
  public class Startup : FunctionsStartup {
    public override void Configure(IFunctionsHostBuilder builder) {
      string connectionString = Environment.GetEnvironmentVariable("SQLAZURECONNSTR_AZURE_SQL");
      builder.Services.AddDbContext<DatabaseContext>(
        options => SqlServerDbContextOptionsExtensions.UseSqlServer(options, connectionString)
      );
    }
  }
}