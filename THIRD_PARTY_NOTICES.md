# Third-party notices

This repository contains binding code and some third-party binaries. Each third-party component keeps its own license; this file points to them. It is not legal advice.

## Included SDK binaries

| Component | Location | License |
|---|---|---|
| Cashfree PG Android SDK (`com.cashfree.pg:*`) | `bindings/Cashfree.Android.Binding/Jars` | MIT, as declared in the Maven POM. See https://github.com/cashfree/nextgen-android/blob/master/LICENSE.md. Copyright remains with Cashfree Payments. |
| Facebook Android SDK `facebook-core` 18.0.3 | `bindings/Facebook.Android.Binding/Jars` | Meta Platforms license for the Facebook SDK for Android: https://github.com/facebook/facebook-android-sdk/blob/main/LICENSE.txt. It permits redistribution in binary form with the copyright notice, for use with Facebook's services and subject to the Facebook Platform Policy. Copyright remains with Meta Platforms, Inc. and affiliates. |

## Included open-source dependencies (CCAvenue binding)

Located in `bindings/CCAvenue.Android.Binding/Jars/Maven/Dependencies/`. Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0.txt), as declared in their POMs:

- OkHttp and okhttp-logging-interceptor 5.3.0, Okio 3.16.2 (Square)
- Coil, coil-base, coil-gif, coil-svg 2.6.0
- AndroidSVG (`com.caverock:androidsvg-aar` 1.4)
- `in.uvik:displaycardinfo-sdk` 0.0.3

`com.github.devnied.emvnfccard:library` 3.0.1 is also included. Its POM does not declare a license; check the upstream project for its terms.

## Not included

The CCAvenue SDK and the Mobikwik SDK are not redistributed here. See the `Jars/README.md` in their binding folders.
