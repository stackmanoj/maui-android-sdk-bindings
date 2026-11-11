namespace BindingsSample;

/// <summary>
/// Placeholder values only. Real values come from your payment provider and, for
/// anything that needs signing or encryption, from YOUR SERVER. Never ship merchant
/// secrets (working keys, checksum secrets, API secrets) inside the app.
/// </summary>
public static class SampleConfig
{
    // CCAvenue: both values are produced by your backend for each order.
    public const string CCAvenueAccessCode = "YOUR_ACCESS_CODE";
    public const string CCAvenueEncRequest = "ENCRYPTED_REQUEST_FROM_YOUR_SERVER";
    public const string CCAvenueEnvironment = "test"; // "production" for live

    // Cashfree: create the order on your server, then pass the session id to the app.
    public const string CashfreeOrderId = "YOUR_ORDER_ID";
    public const string CashfreePaymentSessionId = "SESSION_ID_FROM_YOUR_SERVER";
    public const bool CashfreeProduction = false;

    // Mobikwik / Zaakpay: the checksums are computed on your server.
    public const string ZaakpayMerchantId = "YOUR_MERCHANT_ID";
    public const string ZaakpayOrderId = "YOUR_ORDER_ID";
    public const string ZaakpayChecksum = "CHECKSUM_FROM_YOUR_SERVER";
    public const string ZaakpayChecksumPO = "CHECKSUM_PO_FROM_YOUR_SERVER";
}
