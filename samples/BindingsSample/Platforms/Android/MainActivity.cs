using Android.App;
using Android.Content.PM;
using Android.OS;
using Com.Ccavenue.Indiasdk;
using Com.Ccavenue.Indiasdk.Model;
using Com.Facebook;
using Com.Facebook.Appevents;
using Com.Mobikwik.Mobikwikpglib;
using Com.Mobikwik.Mobikwikpglib.Lib.Transactional;

namespace BindingsSample;

/// <summary>
/// The activity that launches the payment SDKs also receives their results, so it
/// implements the native listener interfaces.
/// </summary>
[Activity(
    Theme = "@style/Maui.SplashTheme",
    MainLauncher = true,
    LaunchMode = LaunchMode.SingleTop,
    ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation | ConfigChanges.UiMode |
                           ConfigChanges.ScreenLayout | ConfigChanges.SmallestScreenSize | ConfigChanges.Density)]
public class MainActivity : MauiAppCompatActivity,
    PaymentCheckout.IZaakPayPaymentListener,
    ICCAvenueTransactionCallback
{
    /// <summary>Raised when any native SDK reports a result. Handlers must marshal to the UI thread.</summary>
    public static event Action<string>? PaymentResult;

    protected override void OnCreate(Bundle? savedInstanceState)
    {
        base.OnCreate(savedInstanceState);

        // Facebook SDK initialisation. Needs facebook_app_id / facebook_client_token in strings.xml.
        FacebookSdk.AutoInitEnabled = true;
        FacebookSdk.FullyInitialize();
        AppEventsLogger.ActivateApp(Application!);
    }

    // Mobikwik / Zaakpay
    void PaymentCheckout.IZaakPayPaymentListener.OnPaymentSuccess(TransactionResponse? response) =>
        PaymentResult?.Invoke("Zaakpay: payment callback received (success). Verify on your server.");

    void PaymentCheckout.IZaakPayPaymentListener.OnPaymentFailure(string? code, string? message) =>
        PaymentResult?.Invoke($"Zaakpay: failure. {code} {message}");

    // CCAvenue
    void ICCAvenueTransactionCallback.OnTransactionResponse(CCAvenueResponseCallback? response)
    {
        if (response == null)
        {
            PaymentResult?.Invoke("CCAvenue: null response.");
            return;
        }

        PaymentResult?.Invoke(
            $"CCAvenue: status code {response.StatusCode}, message {response.StatusMessage}. Verify on your server.");
    }
}
