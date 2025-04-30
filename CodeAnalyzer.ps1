# Configuration
$ProjectPathGithubRepo = "https://github.com/ThibBer/gamified-testing.git"
$ProjectPathGithubRepoBranch = "no-bug"

$UploadsDirectory = "./generated/uploads"
$ReportsDirectory = "./generated/reports-$ProjectPathGithubRepoBranch"

$LogPath = "./CodeAnalyzer.log"

# Script
Start-Transcript -Path $LogPath -Append | Out-Null

$WorkingDirectoryPath = "$Env:TEMP\GamifiedTestingDataAnalyzer"

$RepoName = ($ProjectPathGithubRepo.Split('/')[-1]).Replace(".git", "")
$ProjectPath = "$WorkingDirectoryPath\$RepoName"

if (Test-Path $WorkingDirectoryPath) {
    Remove-Item -Path $WorkingDirectoryPath -Force -Confirm:$false
}

if (Test-Path $ReportsDirectory) {
    Remove-Item -Path $ReportsDirectory -Force -Confirm:$false
}

New-Item -ItemType Directory -Path $ReportsDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $WorkingDirectoryPath -Force | Out-Null
New-Item -ItemType Directory -Path "$WorkingDirectoryPath\test-classes" -Force | Out-Null

# Clone github project
Push-Location $WorkingDirectoryPath
    Write-Output "Cloning project $RepoName to $ProjectPath"

    git clone $ProjectPathGithubRepo

    # Select branch
    Push-Location $ProjectPath
        git checkout $ProjectPathGithubRepoBranch
    Pop-Location

    Write-Output "Project cloned : $ProjectPath"
Pop-Location

# Get uploads
$Uploads = Get-ChildItem -Path $UploadsDirectory -Directory | ForEach-Object {
    $UserId = $_.Name
    Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {
        [PSCustomObject]@{
            UserId    = $UserId
            Timestamp = $_.Name
        }
    }
}

$Jobs = @()

foreach ($upload in $Uploads) {
    $job = Start-ThreadJob -ScriptBlock {
        param ($Upload, $ProjectPath, $WorkingDirectoryPath, $UploadsDirectory, $ReportsDirectory)

        $UserId = $Upload.UserId
        $Timestamp = $Upload.Timestamp

        Write-Output "🚀 Traitement de $UserId / $Timestamp"

        $UploadPath = Join-Path -Path $UploadsDirectory -ChildPath "$UserId\$Timestamp"
        $TestZip = Join-Path $UploadPath "testClasses.zip"

        if (-Not (Test-Path $TestZip)) {
            Write-Output "❌ Missing file: $TestZip"
            return
        }

        $DestProjet = "$WorkingDirectoryPath\test-classes\$UserId\$Timestamp"
        $RapportDest = "$ReportsDirectory\$UserId\$Timestamp"

        # Copier projet
        Copy-Item -Path $ProjectPath -Destination $DestProjet -Recurse -Force -ErrorAction Stop

        # Dézipper les tests
        Expand-Archive -Path $TestZip -DestinationPath "$DestProjet\src\test" -Force

        # JaCoCo
        Push-Location $DestProjet
            Write-Output "▶️ Running JaCoCo in $DestProjet"
            mvn clean test "-Dmaven.test.failure.ignore=true" | Out-Null
        Pop-Location

        New-Item -ItemType Directory -Path $RapportDest -Force | Out-Null

        # JaCoCo Report
        $JacocoPath = "$DestProjet\target\site\jacoco"

        if (Test-Path $JacocoPath) {
            $JacocoDest = "$RapportDest\JaCoCo"

            New-Item -ItemType Directory -Path $JacocoDest -Force | Out-Null

            Copy-Item "$JacocoPath\*" -Destination $JacocoDest -Recurse -Force
            Write-Output "✅ JaCoCo report generated for $UserId / $Timestamp"
        } else {
            Write-Output "⚠️ No JaCoCo report for $UserId / $Timestamp"
        }

        # Pi Test
        Push-Location $DestProjet
            Write-Output "▶️ Running PiTest in $DestProjet"
            mvn test-compile org.pitest:pitest-maven:mutationCoverage "-Dmaven.testFailureIgnore=true" | Out-Null
        Pop-Location

        # Pi Test Report
        $PitPath = "$DestProjet\target\pit-reports"

        if (Test-Path $PitPath) {
            $PitestDest = "$RapportDest\Pitest"

            New-Item -ItemType Directory -Path $PitestDest -Force | Out-Null

            Copy-Item "$PitPath\*" -Destination $PitestDest -Recurse -Force
            Write-Output "✅ PiTest report generated for $UserId / $Timestamp"
        } else {
            Write-Output "⚠️ No PiTest report for $UserId / $Timestamp"
        }
    } -ArgumentList $upload, $ProjectPath, $WorkingDirectoryPath, $UploadsDirectory, $ReportsDirectory

    $Jobs += $job
}

$duration = Measure-Command {
    Write-Host "Analyzing projets data"
    Write-Output "Analyzing projets data"
    $Jobs | Wait-Job | Receive-Job
    $Jobs | Remove-Job
}

Write-Host "`nReports generated in $($duration.ToString())"

Stop-Transcript | Out-Null