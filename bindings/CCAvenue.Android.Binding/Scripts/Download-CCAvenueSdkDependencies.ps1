<#
.SYNOPSIS
Downloads the CCAvenue SDK AAR and its Maven dependency artifacts.

.DESCRIPTION
This script reads the CCAvenue SDK POM, resolves dependency POMs recursively,
and downloads dependency AAR/JAR files into a local folder. It uses Google
Maven, Maven Central, JitPack, and the private CCAvenue GitHub Packages Maven
repository.

Credentials for the private CCAvenue repository are read from
CCAVENUE_MAVEN_USERNAME and CCAVENUE_MAVEN_PASSWORD when set. If either value
is missing and the private repository is needed, the script prompts for it.
Credentials are never written to this repository.

.EXAMPLE
.\Scripts\Download-CCAvenueSdkDependencies.ps1

.EXAMPLE
$env:CCAVENUE_MAVEN_USERNAME = "your-username"
$env:CCAVENUE_MAVEN_PASSWORD = "your-password-or-token"
.\Scripts\Download-CCAvenueSdkDependencies.ps1 -Version 2.1.4
#>

param(
    [string]$Version = "2.1.4",
    [string]$Username = $env:CCAVENUE_MAVEN_USERNAME,
    [string]$Password = $env:CCAVENUE_MAVEN_PASSWORD,
    [string]$OutputDirectory = "",
    [switch]$DirectOnly,
    [switch]$SkipKnownExistingPackages,
    [switch]$SkipExisting
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptRoot "..")

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $projectRoot "Jars\Maven\Dependencies"
}

$pomDirectory = Join-Path $OutputDirectory "poms"
$artifactDirectory = Join-Path $OutputDirectory "artifacts"
New-Item -ItemType Directory -Path $pomDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $artifactDirectory -Force | Out-Null

$repositories = @(
    @{
        Name = "Google"
        Url = "https://dl.google.com/dl/android/maven2"
        RequiresAuth = $false
    },
    @{
        Name = "MavenCentral"
        Url = "https://repo1.maven.org/maven2"
        RequiresAuth = $false
    },
    @{
        Name = "JitPack"
        Url = "https://jitpack.io"
        RequiresAuth = $false
    },
    @{
        Name = "CCAvenue"
        Url = "https://maven.pkg.github.com/InfibeamAvenues/CCAvenue_SDK_2.0"
        RequiresAuth = $true
    }
)

$knownExistingPackages = @{
    "androidx.core:core-ktx" = "Covered by Xamarin.AndroidX.Core.Core.Ktx already restored by the binding."
    "androidx.appcompat:appcompat" = "Covered by Xamarin.AndroidX.AppCompat in CCAvenue.Android.Binding."
    "com.google.android.material:material" = "Covered by Xamarin.Google.Android.Material in CCAvenue.Android.Binding."
    "androidx.constraintlayout:constraintlayout" = "Covered by Xamarin.AndroidX.ConstraintLayout in CCAvenue.Android.Binding."
    "androidx.recyclerview:recyclerview" = "Covered by Xamarin.AndroidX.RecyclerView in CCAvenue.Android.Binding."
    "androidx.navigation:navigation-fragment-ktx" = "Covered by Xamarin.AndroidX.Navigation.Fragment.Ktx in CCAvenue.Android.Binding."
    "androidx.navigation:navigation-ui-ktx" = "Covered by Xamarin.AndroidX.Navigation.UI.Ktx in CCAvenue.Android.Binding."
    "com.google.dagger:dagger" = "Covered by Xamarin.Google.Dagger in CCAvenue.Android.Binding."
    "androidx.lifecycle:lifecycle-viewmodel-ktx" = "Covered by restored Xamarin.AndroidX.Lifecycle packages."
    "androidx.lifecycle:lifecycle-livedata-ktx" = "Covered by restored Xamarin.AndroidX.Lifecycle packages."
    "androidx.lifecycle:lifecycle-runtime-ktx" = "Covered by restored Xamarin.AndroidX.Lifecycle packages."
    "org.jetbrains.kotlinx:kotlinx-coroutines-core" = "Covered by restored Xamarin.KotlinX.Coroutines.Core."
    "org.jetbrains.kotlinx:kotlinx-coroutines-android" = "Covered by restored Xamarin.KotlinX.Coroutines.Android."
    "com.squareup.retrofit2:retrofit" = "Covered by Square.Retrofit2 in CCAvenue.Android.Binding."
    "com.squareup.retrofit2:converter-gson" = "Covered by Square.Retrofit2.ConverterGson in CCAvenue.Android.Binding."
    "com.airbnb.android:lottie" = "Covered by Xamarin.AirBnB.Android.Lottie in CCAvenue.Android.Binding."
    "androidx.work:work-runtime-ktx" = "Covered by Xamarin.AndroidX.Work.Work.Runtime.Ktx in CCAvenue.Android.Binding."
    "androidx.localbroadcastmanager:localbroadcastmanager" = "Covered by Xamarin.AndroidX.LocalBroadcastManager in CCAvenue.Android.Binding."
    "com.google.android.gms:play-services-auth-api-phone" = "Covered by Xamarin.GooglePlayServices.Auth.Api.Phone in CCAvenue.Android.Binding."
    "androidx.databinding:viewbinding" = "Covered by Xamarin.AndroidX.DataBinding.ViewBinding in CCAvenue.Android.Binding."
}

function Get-PlainTextPassword {
    param([string]$ExistingPassword)

    if (-not [string]::IsNullOrWhiteSpace($ExistingPassword)) {
        return $ExistingPassword
    }

    $securePassword = Read-Host "CCAvenue Maven password/token" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function Get-RepositoryHeaders {
    param([hashtable]$Repository, [string]$Accept)

    if (-not $Repository.RequiresAuth) {
        return @{ Accept = $Accept }
    }

    if ([string]::IsNullOrWhiteSpace($script:Username)) {
        $script:Username = Read-Host "CCAvenue Maven username"
    }

    $script:Password = Get-PlainTextPassword $script:Password

    if ([string]::IsNullOrWhiteSpace($script:Username) -or [string]::IsNullOrWhiteSpace($script:Password)) {
        throw "CCAvenue repository credentials are required."
    }

    $authBytes = [Text.Encoding]::UTF8.GetBytes("${script:Username}:${script:Password}")
    return @{
        Authorization = "Basic " + [Convert]::ToBase64String($authBytes)
        Accept = $Accept
    }
}

function Get-MavenPath {
    param(
        [string]$GroupId,
        [string]$ArtifactId,
        [string]$Version,
        [string]$Extension
    )

    $groupPath = $GroupId.Replace(".", "/")
    return "$groupPath/$ArtifactId/$Version/$ArtifactId-$Version.$Extension"
}

function Get-LocalName {
    param(
        [string]$GroupId,
        [string]$ArtifactId,
        [string]$Version,
        [string]$Extension
    )

    return "$GroupId.$ArtifactId-$Version.$Extension"
}

function Try-Download {
    param(
        [string]$GroupId,
        [string]$ArtifactId,
        [string]$Version,
        [string]$Extension,
        [string]$DestinationDirectory,
        [string]$Accept = "application/octet-stream"
    )

    $destination = Join-Path $DestinationDirectory (Get-LocalName $GroupId $ArtifactId $Version $Extension)
    if ($SkipExisting -and (Test-Path -LiteralPath $destination)) {
        return $destination
    }

    foreach ($repository in $repositories) {
        $url = $repository.Url.TrimEnd("/") + "/" + (Get-MavenPath $GroupId $ArtifactId $Version $Extension)
        $temporaryDestination = "$destination.download"

        try {
            $headers = Get-RepositoryHeaders $repository $Accept
            Invoke-WebRequest -Uri $url -Headers $headers -OutFile $temporaryDestination
            Move-Item -LiteralPath $temporaryDestination -Destination $destination -Force
            Write-Host "Downloaded ${GroupId}:${ArtifactId}:${Version}.${Extension} from $($repository.Name)"
            return $destination
        }
        catch {
            if (Test-Path -LiteralPath $temporaryDestination) {
                Remove-Item -LiteralPath $temporaryDestination -Force
            }
        }
    }

    return $null
}

function Read-Pom {
    param([string]$PomPath)

    [xml]$xml = Get-Content -LiteralPath $PomPath -Raw
    return $xml.project
}

function Get-XmlText {
    param($Node, [string]$Name)

    $child = $Node.$Name
    if ($null -eq $child) {
        return ""
    }

    return ([string]$child).Trim()
}

function Get-PomProperties {
    param($Pom)

    $properties = @{}
    $groupId = Get-XmlText $Pom "groupId"
    $artifactId = Get-XmlText $Pom "artifactId"
    $version = Get-XmlText $Pom "version"

    if ([string]::IsNullOrWhiteSpace($groupId) -and $Pom.parent) {
        $groupId = Get-XmlText $Pom.parent "groupId"
    }

    if ([string]::IsNullOrWhiteSpace($version) -and $Pom.parent) {
        $version = Get-XmlText $Pom.parent "version"
    }

    $properties["project.groupId"] = $groupId
    $properties["pom.groupId"] = $groupId
    $properties["project.artifactId"] = $artifactId
    $properties["pom.artifactId"] = $artifactId
    $properties["project.version"] = $version
    $properties["pom.version"] = $version

    if ($Pom.properties) {
        foreach ($property in $Pom.properties.ChildNodes) {
            if ($property.NodeType -eq "Element") {
                $properties[$property.LocalName] = $property.InnerText.Trim()
            }
        }
    }

    return $properties
}

function Resolve-PomValue {
    param([string]$Value, [hashtable]$Properties)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    $resolved = $Value.Trim()
    $guard = 0
    while ($resolved -match "\$\{([^}]+)\}" -and $guard -lt 20) {
        $key = $Matches[1]
        if ($Properties.ContainsKey($key)) {
            $resolved = $resolved.Replace("`${$key}", $Properties[$key])
        }
        else {
            break
        }

        $guard++
    }

    return $resolved
}

function Get-PomDependencies {
    param($Pom)

    $properties = Get-PomProperties $Pom
    $dependencies = @()

    if (-not $Pom.dependencies) {
        return $dependencies
    }

    foreach ($dependency in $Pom.dependencies.dependency) {
        $scope = Resolve-PomValue (Get-XmlText $dependency "scope") $properties
        $optional = Resolve-PomValue (Get-XmlText $dependency "optional") $properties

        if ($scope -in @("test", "provided", "system") -or $optional -eq "true") {
            continue
        }

        $groupId = Resolve-PomValue (Get-XmlText $dependency "groupId") $properties
        $artifactId = Resolve-PomValue (Get-XmlText $dependency "artifactId") $properties
        $version = Resolve-PomValue (Get-XmlText $dependency "version") $properties
        $type = Resolve-PomValue (Get-XmlText $dependency "type") $properties

        if ([string]::IsNullOrWhiteSpace($groupId) -or [string]::IsNullOrWhiteSpace($artifactId) -or [string]::IsNullOrWhiteSpace($version)) {
            Write-Warning "Skipping dependency with unresolved coordinates: ${groupId}:${artifactId}:${version}"
            continue
        }

        if ([string]::IsNullOrWhiteSpace($type)) {
            $type = "jar"
        }

        $dependencies += [pscustomobject]@{
            GroupId = $groupId
            ArtifactId = $artifactId
            Version = $version
            Type = $type
        }
    }

    return $dependencies
}

function Download-Artifact {
    param($Coordinate)

    $extensions = @()
    if ($Coordinate.Type -in @("aar", "jar")) {
        $extensions += $Coordinate.Type
    }

    $extensions += @("aar", "jar") | Where-Object { $_ -notin $extensions }

    foreach ($extension in $extensions) {
        $artifactPath = Try-Download $Coordinate.GroupId $Coordinate.ArtifactId $Coordinate.Version $extension $artifactDirectory
        if ($artifactPath) {
            return $artifactPath
        }
    }

    Write-Warning "Could not download artifact for $($Coordinate.GroupId):$($Coordinate.ArtifactId):$($Coordinate.Version)"
    return $null
}

function Test-ShouldSkipKnownExistingPackage {
    param($Coordinate)

    if (-not $SkipKnownExistingPackages) {
        return $false
    }

    $key = "$($Coordinate.GroupId):$($Coordinate.ArtifactId)"
    if (-not $knownExistingPackages.ContainsKey($key)) {
        return $false
    }

    Write-Host "Skipped ${key}:$($Coordinate.Version) - $($knownExistingPackages[$key])"
    return $true
}

try {
    $rootCoordinate = [pscustomobject]@{
        GroupId = "com.ccavenue.indiasdk"
        ArtifactId = "sdk"
        Version = $Version
        Type = "aar"
    }

    $queue = New-Object System.Collections.Queue
    $visited = @{}
    $downloaded = New-Object System.Collections.Generic.List[string]

    $localRootAar = Join-Path $projectRoot "Jars\Maven\sdk-$Version.aar"
    $localRootPom = Join-Path $projectRoot "Jars\Maven\sdk-$Version.pom"

    if (Test-Path -LiteralPath $localRootAar) {
        Copy-Item -LiteralPath $localRootAar -Destination (Join-Path $artifactDirectory "com.ccavenue.indiasdk.sdk-$Version.aar") -Force
        Write-Host "Reused local CCAvenue SDK AAR: $localRootAar"
    }
    else {
        Download-Artifact $rootCoordinate | Out-Null
    }

    if (Test-Path -LiteralPath $localRootPom) {
        $rootPom = Join-Path $pomDirectory "com.ccavenue.indiasdk.sdk-$Version.pom"
        Copy-Item -LiteralPath $localRootPom -Destination $rootPom -Force
        Write-Host "Reused local CCAvenue SDK POM: $localRootPom"
    }
    else {
        $rootPom = Try-Download $rootCoordinate.GroupId $rootCoordinate.ArtifactId $rootCoordinate.Version "pom" $pomDirectory "application/xml"
    }

    if (-not $rootPom) {
        throw "Could not download CCAvenue SDK POM."
    }

    foreach ($dependency in Get-PomDependencies (Read-Pom $rootPom)) {
        $queue.Enqueue($dependency)
    }

    while ($queue.Count -gt 0) {
        $coordinate = $queue.Dequeue()
        $key = "$($coordinate.GroupId):$($coordinate.ArtifactId):$($coordinate.Version)"

        if ($visited.ContainsKey($key)) {
            continue
        }

        $visited[$key] = $true

        if (Test-ShouldSkipKnownExistingPackage $coordinate) {
            continue
        }

        $artifactPath = Download-Artifact $coordinate
        if ($artifactPath) {
            $downloaded.Add($artifactPath)
        }

        $pomPath = Try-Download $coordinate.GroupId $coordinate.ArtifactId $coordinate.Version "pom" $pomDirectory "application/xml"
        if (-not $pomPath -or $DirectOnly) {
            continue
        }

        foreach ($dependency in Get-PomDependencies (Read-Pom $pomPath)) {
            $queue.Enqueue($dependency)
        }
    }

    Write-Host ""
    Write-Host "Downloaded $($downloaded.Count) dependency artifact(s)."
    Write-Host "Artifacts: $artifactDirectory"
    Write-Host "POMs: $pomDirectory"
}
finally {
    $script:Password = $null
}
