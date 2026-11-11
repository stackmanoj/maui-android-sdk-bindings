using Com.Facebook.Appevents;

namespace BindingsSample.Services;

public static class FacebookDemo
{
    public static void LogSampleEvent()
    {
        var context = Platform.AppContext;
        var logger = AppEventsLogger.NewLogger(context);
        logger?.LogEvent("sample_event");
    }
}
