# BindingsSample

A minimal .NET MAUI Android app that references all four bindings and shows how to call each one.

| Button | Binding | What it shows |
|---|---|---|
| CCAvenue: open checkout | `CCAvenue.Android.Binding` | `CCAvenueSDK.Instance.InitTransaction(...)` and the result callback |
| Mobikwik / Zaakpay: open checkout | `Zaakpay.Android.Binding` | `PaymentCheckout.StartPayment(...)` and the payment listener |
| Cashfree: UPI intent | `Cashfree.Android.Binding` | building a session and starting a UPI intent payment with a callback |
| Facebook: log app event | `Facebook.Android.Binding` | initialising the SDK and logging an app event |

## Status

- **Before building, add the two SDK files that are not in this repo:** `sdk-2.1.4.aar` (CCAvenue) and `Mobikwik-Android-SDK-4.5.aar` (Mobikwik/Zaakpay). See the `Jars/README.md` in `bindings/CCAvenue.Android.Binding` and `bindings/Zaakpay.Android.Binding`. Without them the sample does not build.
- Builds with `dotnet build -c Debug` on .NET 10 with the Android workload (produces a debug APK).
- Run on an Android 16 (API 36) x86_64 emulator: the app starts, and each button reaches its native SDK. With placeholder values, CCAvenue returns status code 104, Mobikwik/Zaakpay returns error 10098 (cannot connect), Cashfree opens its SDK screen and loads, and the Facebook event call completes without error.
- All values in `SampleConfig.cs` are placeholders. Without real values from your provider and server, the payment screens will show errors instead of completing a payment. The sample demonstrates the **wiring**, not a live payment.
- Signing, encryption and checksums must be done on **your server**. Never put merchant secrets in the app.

## Run it

With a device or emulator connected, this builds, installs and launches the app:

```powershell
dotnet build samples/BindingsSample -c Debug -t:Run
```

To get a standalone APK that you install yourself with `adb install`, embed the assemblies. A plain Debug APK relies on Fast Deployment and crashes on launch with `No assemblies found ... Fast Deployment`:

```powershell
dotnet build samples/BindingsSample -c Debug -p:EmbedAssembliesIntoApk=true
```

## Things you need when using these bindings in your own app

These are the points that are easy to miss; each one broke this sample's build until it was added.

1. **Result listeners go on the activity.** `MainActivity` implements `PaymentCheckout.IZaakPayPaymentListener` (Mobikwik/Zaakpay) and `ICCAvenueTransactionCallback` (CCAvenue). The SDKs report results to the activity that launched them. See `Platforms/Android/MainActivity.cs`.
2. **CCAvenue needs OkHttp from NuGet plus a cleanup target.** The CCAvenue SDK bundles OkHttp 5.x as raw Java jars, but the managed Retrofit binding still needs the `Square.OkHttp3` assembly. Add `Square.OkHttp3` and the `RemoveDuplicateOkHttpAars` target from `BindingsSample.csproj`, so the Java-level OkHttp versions don't collide. Without this the build fails with `Could not load assembly 'Square.OkHttp3'`.
3. **Declare the CCAvenue activities and theme in your manifest.** `PayOptionsActivity` and `WebViewActivity` need `@style/CCAvenueSdkTheme`, an AppCompat theme defined in `Resources/values/styles.xml`.
4. **Manifest merge conflicts.** The SDK manifests set `allowBackup` and `label`. Add `tools:replace="android:allowBackup,android:label"` on `<application>`.
5. **Facebook needs an app id and client token.** Define `facebook_app_id` and `facebook_client_token` in `strings.xml` (placeholders here) and declare `FacebookActivity` plus the two `<meta-data>` entries.
6. **Verify payments on your server.** The callbacks only tell the app that the SDK finished. Confirm the final payment status server-side.
