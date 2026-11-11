# Mobikwik / Zaakpay SDK file

**Not included:** the Mobikwik SDK is not publicly downloadable and is not redistributed in this repo. You need to obtain it from Mobikwik/Zaakpay.

## Get the SDK

- **SDK:** `com.github.Mobikwik:Android-SDK:4.5`
- **Official source:** Mobikwik's JitPack artifact, https://jitpack.io/#Mobikwik/Android-SDK
- **Access:** the artifact is not anonymously downloadable (JitPack returns HTTP 401 without credentials). You need a JitPack auth token from Mobikwik/Zaakpay, which you get when you onboard as a merchant. Ask them for SDK access.

```powershell
curl.exe -u <YOUR_JITPACK_TOKEN>: -L -o Mobikwik-Android-SDK-4.5.aar "https://jitpack.io/com/github/Mobikwik/Android-SDK/4.5/Android-SDK-4.5.aar"
```

Save it as `Jars/Mobikwik-Android-SDK-4.5.aar`. Never commit your token.
