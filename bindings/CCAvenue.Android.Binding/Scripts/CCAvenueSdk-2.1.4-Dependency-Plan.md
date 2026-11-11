# CCAvenue SDK 2.1.4 Dependency Plan

The downloaded `sdk-2.1.4.pom` declares these direct dependencies.

Use NuGet packages first. Then run
`Download-CCAvenueSdkDependencies.ps1 -SkipKnownExistingPackages` to download
only dependencies that are still not covered by the binding
package graph.

## Already Covered

These are already available through `PackageReference`s or restored transitive
packages in the binding:

| Maven coordinate | Existing coverage |
| --- | --- |
| `androidx.core:core-ktx:1.13.1` | `Xamarin.AndroidX.Core.Core.Ktx` restored |
| `androidx.appcompat:appcompat:1.7.0` | `Xamarin.AndroidX.AppCompat` |
| `com.google.android.material:material:1.4.0` | `Xamarin.Google.Android.Material` |
| `androidx.constraintlayout:constraintlayout:2.2.1` | `Xamarin.AndroidX.ConstraintLayout` |
| `androidx.recyclerview:recyclerview:1.4.0` | `Xamarin.AndroidX.RecyclerView` |
| `androidx.navigation:navigation-fragment-ktx:2.8.2` | `Xamarin.AndroidX.Navigation.Fragment.Ktx` |
| `androidx.navigation:navigation-ui-ktx:2.8.2` | `Xamarin.AndroidX.Navigation.UI.Ktx` |
| `com.google.dagger:dagger:2.46` | `Xamarin.Google.Dagger` |
| `org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.0` | `Xamarin.KotlinX.Coroutines.Core` restored |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0` | `Xamarin.KotlinX.Coroutines.Android` restored |
| `androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.5` | `Xamarin.AndroidX.Lifecycle` packages restored |
| `androidx.lifecycle:lifecycle-livedata-ktx:2.8.5` | `Xamarin.AndroidX.Lifecycle` packages restored |
| `androidx.lifecycle:lifecycle-runtime-ktx:2.8.5` | `Xamarin.AndroidX.Lifecycle` packages restored |
| `com.squareup.retrofit2:retrofit:2.9.0` | `Square.Retrofit2` |
| `com.squareup.retrofit2:converter-gson:2.9.0` | `Square.Retrofit2.ConverterGson` |
| `com.airbnb.android:lottie:6.7.1` | `Xamarin.AirBnB.Android.Lottie` |
| `androidx.work:work-runtime-ktx:2.9.0` | `Xamarin.AndroidX.Work.Work.Runtime.Ktx` |
| `androidx.localbroadcastmanager:localbroadcastmanager:1.1.0` | `Xamarin.AndroidX.LocalBroadcastManager` |
| `com.google.android.gms:play-services-auth-api-phone:18.3.0` | `Xamarin.GooglePlayServices.Auth.Api.Phone` |
| `androidx.databinding:viewbinding:8.13.2` | `Xamarin.AndroidX.DataBinding.ViewBinding` |

## Download From Maven

These are not currently covered directly by the binding package graph, or
the declared version materially differs from the existing package:

| Maven coordinate | Note |
| --- | --- |
| `com.squareup.okhttp3:okhttp:5.3.0` | Existing `Square.OkHttp3` is 4.12.x, so do not treat as equivalent |
| `com.squareup.okhttp3:logging-interceptor:5.3.0` | Existing `Square.OkHttp3.LoggingInterceptor` is 4.12.x |
| `io.coil-kt:coil:2.6.0` | Not present |
| `io.coil-kt:coil-svg:2.6.0` | Not present |
| `io.coil-kt:coil-gif:2.6.0` | Not present |
| `in.uvik:displaycardinfo-sdk:0.0.3` | Not present |

## Suggested Commands

Download only missing dependencies:

```powershell
cd bindings\CCAvenue.Android.Binding
.\Scripts\Download-CCAvenueSdkDependencies.ps1 -SkipKnownExistingPackages -SkipExisting
```

Download every dependency listed by the POM, even if the binding already has a
matching Xamarin/.NET package:

```powershell
cd bindings\CCAvenue.Android.Binding
.\Scripts\Download-CCAvenueSdkDependencies.ps1 -SkipExisting
```

Clean the bulk-downloaded dependency folders back down to the Maven-only
artifacts that are not covered by NuGet:

```powershell
cd bindings\CCAvenue.Android.Binding
.\Scripts\Cleanup-CCAvenueSdkDependencies.ps1
```

## Current Maven-Only Keep List

| Artifact | Why it stays local |
| --- | --- |
| `com.squareup.okhttp3:okhttp:5.3.0` | CCAvenue declares OkHttp 5.3.0; existing NuGet is 4.12.x |
| `com.squareup.okhttp3:logging-interceptor:5.3.0` | CCAvenue declares Logging Interceptor 5.3.0; existing NuGet is 4.12.x |
| `com.squareup.okio:okio:3.16.2` | Runtime dependency of OkHttp 5.3.0 |
| `io.coil-kt:coil:2.6.0` | No existing binding NuGet |
| `io.coil-kt:coil-base:2.6.0` | Runtime dependency of Coil artifacts |
| `io.coil-kt:coil-svg:2.6.0` | Direct CCAvenue dependency |
| `io.coil-kt:coil-gif:2.6.0` | Direct CCAvenue dependency |
| `com.caverock:androidsvg-aar:1.4` | Runtime dependency of `coil-svg` |
| `in.uvik:displaycardinfo-sdk:0.0.3` | Direct CCAvenue dependency |
| `com.github.devnied.emvnfccard:library:3.0.1` | Runtime dependency of `displaycardinfo-sdk` |

`displaycardinfo-sdk` also references Compose/test artifacts in its published
POM. Those are intentionally removed from the local artifacts folder because
they are not part of the CCAvenue payment binding surface and would add a large
AndroidX/Compose graph unnecessarily.
