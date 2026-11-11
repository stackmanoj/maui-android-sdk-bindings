using Com.Ccavenue.Indiasdk;

namespace BindingsSample.Services;

public static class CCAvenueDemo
{
    public static void Start()
    {
        var order = new CCAvenueOrder
        {
            AccessCode = SampleConfig.CCAvenueAccessCode,
            EncRequest = SampleConfig.CCAvenueEncRequest,
            PaymentEnvironment = SampleConfig.CCAvenueEnvironment,
            AppColor = "#1F46BD",
            FontColor = "#FFFFFF"
        };

        var activity = Platform.CurrentActivity
            ?? throw new InvalidOperationException("No Android activity is available.");

        // The result arrives in MainActivity (ICCAvenueTransactionCallback).
        CCAvenueSDK.Instance.InitTransaction(activity, order);
    }
}
