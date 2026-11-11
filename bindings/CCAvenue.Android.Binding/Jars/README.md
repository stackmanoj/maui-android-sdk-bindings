# CCAvenue SDK files

**Not included:** the CCAvenue SDK (`sdk-2.1.4.aar`) is distributed by CCAvenue to its merchants and is not redistributed in this repo. You need to download it yourself. The open-source dependencies in `Maven/Dependencies/` (Apache-2.0) are included.

## Get the SDK

- **SDK:** CCAvenue Android SDK `2.1.4` (`sdk-2.1.4.aar`, place in `Jars/Maven/`; the matching `sdk-2.1.4.pom` goes next to it).
- **Official source:** CCAvenue's GitHub Packages Maven repository, `https://maven.pkg.github.com/InfibeamAvenues/CCAvenue_SDK_2.0`. Access requires credentials that CCAvenue provides (contact CCAvenue support), plus a GitHub account/token with `read:packages`.
- **Automated:** run `Scripts/Download-CCAvenueSdk.ps1`, then `Scripts/Download-CCAvenueSdkDependencies.ps1`.
  They read credentials from the `CCAVENUE_MAVEN_USERNAME` / `CCAVENUE_MAVEN_PASSWORD` environment variables (or prompt). Never commit credentials.
- **Patch the AAR after downloading:** run `Scripts/Patch-CCAvenueSdkResources.ps1` (needs a JDK on `PATH` for the `jar` tool). SDK 2.1.4 ships two strings with multiple non-positional `printf` placeholders that Android resource compilation rejects; the script marks them `formatted="false"` and keeps a `.original` backup beside the AAR.
- Transitive dependencies come from Google Maven, Maven Central and JitPack. `Scripts/CCAvenueSdk-2.1.4-Dependency-Plan.md` lists which are needed.
