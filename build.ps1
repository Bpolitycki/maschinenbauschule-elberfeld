# Set the base directory to the script's directory
$baseDir = $PSScriptRoot

# Define a function for 'clean'
function Clean {
    Write-Host "Cleaning..."
    $buildPath = Join-Path -Path $baseDir -ChildPath "build"
    if (Test-Path $buildPath) {
        Remove-Item $buildPath -Recurse -Force
    }
}

# Define a function for 'copy-assets'
function Copy-Assets {
    Write-Host "Copying assets..."
    $buildPath = Join-Path -Path $baseDir -ChildPath "build"
    if (-not (Test-Path $buildPath)) {
        New-Item -ItemType Directory -Path $buildPath
    }
    $staticPath = Join-Path -Path $baseDir -ChildPath "static"
    Copy-Item -Path $staticPath -Destination $buildPath -Recurse
}

# Define a function for 'html'
function Html {
    Clean
    Copy-Assets
    Write-Host "Processing HTML..."
    $saxonPath = Join-Path -Path $baseDir -ChildPath "lib/saxon/saxon-he-12.4.jar"
    $sourcePath = Join-Path -Path $baseDir -ChildPath "xslt\pages.xml"
    $xslPath = Join-Path -Path $baseDir -ChildPath "xslt\pipeline.xslt"
    java -jar $saxonPath -s:$sourcePath -xsl:$xslPath strip-default-index-name=false
}

# Call the 'html' function to execute the script
Html
