namespace OrdersService.Utils;

public static class Utils {
    public static bool IsRunningInContainer()
    {
        return Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true";
    }

    public static bool IsRunningInAzureAppService()
    {
        return !String.IsNullOrEmpty(Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME"));
    }
}
