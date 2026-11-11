using Com.Mobikwik.Mobikwikpglib;
using Com.Mobikwik.Mobikwikpglib.Lib.Transactional;
using Com.Mobikwik.Mobikwikpglib.Utils;

namespace BindingsSample.Services;

public static class ZaakpayDemo
{
    public static void Start()
    {
        var transaction = new TransactionData
        {
            Amount = new Java.Math.BigInteger("100"), // in paise
            Currency = "INR",
            OrderId = SampleConfig.ZaakpayOrderId,
            UserEmail = "user@example.com",
            UserPhoneNumber = "9999999999",
            ReturnUrl = "https://example.com/payment/return",
            MerchantIconUrl = "https://example.com/logo.png",
            MerchantName = "Sample Merchant",
            MerchantId = SampleConfig.ZaakpayMerchantId,
            Environment = Enums.Environment.Testing,
            Checksum = SampleConfig.ZaakpayChecksum,
            ChecksumPO = SampleConfig.ZaakpayChecksumPO
        };

        // The activity must implement PaymentCheckout.IZaakPayPaymentListener (see MainActivity).
        var checkout = new PaymentCheckout(Platform.CurrentActivity!);
        checkout.StartPayment(transaction);
    }
}
