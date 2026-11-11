using Com.Cashfree.PG.Api;
using Com.Cashfree.PG.Core.Api;
using Com.Cashfree.PG.Core.Api.Callback;
using Com.Cashfree.PG.Core.Api.Utils;
using Com.Cashfree.PG.UI.Api.Upi.Intent;

namespace BindingsSample.Services;

public static class CashfreeDemo
{
    private static CheckoutCallback? _callback;

    public static void StartUpiIntent(Action<string> log)
    {
        var service = CFPaymentGatewayService.Instance
            ?? throw new InvalidOperationException("Cashfree service is not available.");

        _callback = new CheckoutCallback(log);
        service.SetCheckoutCallback(_callback);

        var session = new CFSession.CFSessionBuilder()
            .SetEnvironment(SampleConfig.CashfreeProduction
                ? CFSession.Environment.Production!
                : CFSession.Environment.Sandbox!)!
            .SetPaymentSessionID(SampleConfig.CashfreePaymentSessionId)!
            .SetOrderId(SampleConfig.CashfreeOrderId)!
            .Build()!;

        var upiIntent = new CFUPIIntentCheckout.CFUPIIntentBuilder().Build()!;

        var payment = new CFUPIIntentCheckoutPayment.CFUPIIntentPaymentBuilder()
            .SetSession(session)!
            .SetCfUPIIntentCheckout(upiIntent)!
            .Build()!;

        service.DoPayment(Platform.CurrentActivity!, payment);
    }

    private sealed class CheckoutCallback(Action<string> log) : Java.Lang.Object, ICFCheckoutResponseCallback
    {
        public void OnPaymentFailure(CFErrorResponse? error, string? orderId) =>
            log($"Cashfree failure. Order: {orderId}, message: {error?.Message}");

        public void OnPaymentVerify(string? orderId) =>
            log($"Cashfree payment submitted, verify order on your server: {orderId}");
    }
}
