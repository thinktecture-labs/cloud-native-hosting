using Dapr.Client;
using Microsoft.OpenApi.Models;
using OrdersService.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Console;
using OrdersService.Data;
using OrdersService.Utils;
using OrdersService.Data.Repositories;
using Microsoft.IdentityModel.Tokens;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

const string ServiceName = "OrdersService";
var builder = WebApplication.CreateBuilder(args);

var cfg = new OrdersServiceConfiguration();
var cfgSection = builder.Configuration.GetSection(OrdersServiceConfiguration.SectionName);

cfgSection.Bind(cfg);
builder.Services.AddSingleton(cfg);

// logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole(options =>
{
    options.FormatterName = ConsoleFormatterNames.Json;
});

if (Utils.IsRunningInAzureAppService())
{
    builder.Logging.AddAzureWebAppDiagnostics();
}

var appInsightsConnectionString = builder.Configuration.GetValue<string>("APPLICATIONINSIGHTS_CONNECTION_STRING") ?? "";
if (!string.IsNullOrWhiteSpace(appInsightsConnectionString))
{
    builder.Logging.AddApplicationInsights(
        configureTelemetryConfiguration: (config) =>
        {
            config.ConnectionString = appInsightsConnectionString;
        },
        configureApplicationInsightsLoggerOptions: (options) => { }
    );
}

//traces
if (cfg != null && !string.IsNullOrWhiteSpace(cfg.ZipkinEndpoint))
{
    builder.Services.AddOpenTelemetryTracing(options =>
    {
        options.SetResourceBuilder(ResourceBuilder.CreateDefault().AddService(ServiceName))
            .AddAspNetCoreInstrumentation()
            .AddZipkinExporter(options =>
            {
                options.Endpoint = new Uri(cfg.ZipkinEndpoint);
            });
    });
}

// metrics
builder.Services.AddOpenTelemetryMetrics(options =>
{
    options.ConfigureResource(rb =>
        {
            rb.AddService(ServiceName);
        })
        .AddRuntimeInstrumentation()
        .AddHttpClientInstrumentation()
        .AddAspNetCoreInstrumentation()
        .AddPrometheusExporter();
});

// Configure AuthN
if (cfg != null && cfg.IdentityServer.IsConfigured())
{
    builder.Services.AddAuthentication("Bearer")
        .AddJwtBearer("Bearer", options =>
        {
            options.Authority = cfg.IdentityServer.Authority;
            options.RequireHttpsMetadata = cfg.IdentityServer.RequireHttpsMetadata;

            if (!string.IsNullOrWhiteSpace(cfg.IdentityServer.MetadataAddress))
            {
                options.MetadataAddress = cfg.IdentityServer.MetadataAddress;
            }
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = false,
                ValidIssuer = cfg.IdentityServer.Authority
            };
        });

    // Configure AuthZ
    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy("ApiScope", policy =>
        {
            policy.RequireAuthenticatedUser();
            policy.RequireClaim(cfg.Authorization.RequiredClaimName, cfg.Authorization.RequiredClaimValue);
        });
    });
}

builder.Services.AddDbContext<OrdersServiceContext>(options =>
    options.UseInMemoryDatabase(databaseName: "OrdersService"));

builder.Services.AddScoped<IOrdersRepository, OrdersRepository>();
builder.Services.AddScoped<DaprClient>(_ => new DaprClientBuilder().Build()!);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(c =>
{
    c.EnableAnnotations();
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Orders Service",
        Description = "Fairly simple .NET API to interact with orders",
        Contact = new OpenApiContact
        {
            Name = "Thinktecture AG",
            Email = "info@thinktecture.com",
            Url = new Uri("https://thinktecture.com")
        }
    });
});
builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();

var endpointConventionBuilder = app.MapControllers();
if (cfg != null && cfg.IdentityServer.IsConfigured())
{
    endpointConventionBuilder.RequireAuthorization("ApiScope");
}

app.MapHealthChecks("/healthz/readiness");
app.MapHealthChecks("/healthz/liveness");

app.UseOpenTelemetryPrometheusScrapingEndpoint();

app.Run();
