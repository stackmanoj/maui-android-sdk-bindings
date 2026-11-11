# maui-android-sdk-bindings

.NET MAUI / .NET for Android binding libraries for native Android SDKs, targeting `net10.0-android`.

| Binding | Wraps | Official SDK source |
|---|---|---|
| [CCAvenue.Android.Binding](bindings/CCAvenue.Android.Binding) | CCAvenue Android SDK 2.1.4 + its Maven dependencies | [CCAvenue GitHub Packages](https://github.com/InfibeamAvenues/CCAvenue_SDK_2.0) |
| [Zaakpay.Android.Binding](bindings/Zaakpay.Android.Binding) | Mobikwik Android SDK 4.5 | [JitPack: Mobikwik/Android-SDK](https://jitpack.io/#Mobikwik/Android-SDK) (needs a token from Mobikwik) |
| [Cashfree.Android.Binding](bindings/Cashfree.Android.Binding) | Cashfree PG SDK modules (api, core, ui, ...) | [Maven Central: com.cashfree.pg](https://repo1.maven.org/maven2/com/cashfree/pg/) |
| [Facebook.Android.Binding](bindings/Facebook.Android.Binding) | `facebook-core` 18.0.3 | [Maven Central: com.facebook.android](https://repo1.maven.org/maven2/com/facebook/android/facebook-core/) |

## SDK files

Each binding needs the vendor's native `.aar`/`.jar` files in its `Jars/` folder.

| Binding | SDK file in this repo? |
|---|---|
| Cashfree | **Included** (MIT-licensed by Cashfree) |
| Facebook | **Included** (Meta's license permits redistribution with its notice; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)) |
| CCAvenue | **Not included.** CCAvenue distributes its SDK to merchants. Get `sdk-2.1.4.aar` from CCAvenue (see the binding's `Jars/README.md`). Open-source dependencies are included. |
| Mobikwik / Zaakpay | **Not included.** The SDK needs a token from Mobikwik/Zaakpay (see the binding's `Jars/README.md`). |

Each binding's `Jars/README.md` gives exact file names, versions and official download sources. The SDKs belong to their vendors and keep their own licenses.

## Building

1. Install the .NET 10 SDK with the Android workload (`dotnet workload install android`).
2. `dotnet build bindings/<Name>.Android.Binding`

## Sample app

[samples/BindingsSample](samples/BindingsSample) is a minimal MAUI Android app that uses all four bindings, including the manifest, OkHttp and callback setup each one needs. See its README for the integration notes. It uses placeholder values, so it demonstrates the wiring and not a live payment.

## Status

Android only. All four bindings and the sample app build on .NET 10 (`net10.0-android`); the sample has not been run against live merchant accounts. Payment SDKs change often, so check the SDK version each binding was built against before relying on it. Not affiliated with or endorsed by CCAvenue, Mobikwik/Zaakpay, Cashfree or Meta.
