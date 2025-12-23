#!/usr/bin/env pwsh
# -*- coding: utf-8, tab-width: 2 -*-

function fail($msg) { Write-Host "E: $msg"; exit 2; }

$destBaseUrls = @()
$files = @()

foreach ($arg in $args) {
  if ($arg -match '://') { $destBaseUrls += $arg; continue; }
  $files += $arg
}


function env_float([string] $key, [float] $def) {
  $val = [float][Environment]::GetEnvironmentVariable($key)
  # Write-Host "env[$key] || ${def}: '$val'"
  # $val = if ($val -gt 0) { $val } else { $def }
  if ($val -gt 0) { return $val }
  return $def
}

$timeout_conn_sec = env_float 'HTTP_CONNECT_TIMEOUT' 3
$timeout_resp_sec = env_float 'HTTP_RESPONSE_TIMEOUT' ($timeout_conn_sec * 10)

if (-not $destBaseUrls) { fail 'No base URLs given!' }
if (-not $files) { fail 'No input filenames given.' }


function uploadOneFileToOneServer($baseUrl, $fileName) {
  $uploadAs = [System.IO.Path]::GetFileName($fileName)

  $dateSuf = $env:HTTP_PUT_DATE_SUFFIX
  if ($dateSuf) {
    # To try date formats: `pwsh -Command Get-Date -Format yyMMdd-HHmmss`
    $dateSuf = $dateSuf.Replace('?ym', 'yyMMdd-HHmm')
    $dateSuf = $dateSuf.Replace('?ys', 'yyMMdd-HHmmss')
    $uploadAs = "$([System.IO.Path]::GetFileNameWithoutExtension($uploadAs))$(
      Get-Date -Format "$dateSuf")$([System.IO.Path]::GetExtension($uploadAs))"
  }

  $destUrl = New-Object System.Uri($baseUrl + $uploadAs)
  Write-Host "D: Uploading: $fileName -> $destUrl"
  $req = [System.Net.HttpWebRequest]::Create($destUrl)
  $req.Method = 'PUT'
  # Write-Host "D: Setting connect timeout to $($timeout_conn_sec * 1e3) ms"
  $req.Timeout = $timeout_conn_sec * 1e3
  # Write-Host "D: Setting response timeout to $($timeout_resp_sec * 1e3) ms"
  $req.ReadWriteTimeout = $timeout_resp_sec * 1e3
  $fileSize = (Get-Item $fileName).Length
  $req.ContentLength = $fileSize
  # Write-Host "D: Uploading $fileSize bytes."

  $body = $req.GetRequestStream()
  $fileStream = [System.IO.File]::OpenRead($fileName)
  $bytesCopied = $fileStream.CopyTo($body)
  if ($bytesCopied -ne $fileSize) {
    $errMsg = "Incomplete upload: Sent $bytesCopied of $fileSize bytes."
    # throw [System.Net.WebException] $errMsg
  }
  $fileStream.Close()
  $body.Close()

  $rsp = $req.GetResponse()
  $codeCateg = [math]::Floor($rsp.StatusCode.value__ / 100)
  if ($codeCateg -eq 2) {
    Write-Host "D: Success: Uploaded $fileName -> $destUrl"
  } elseif ($codeCateg -eq 3) {
    Write-Error "W: Request was redirected (HTTP/$($rsp.StatusCode
      )) unexpectedly: $($rsp.StatusDescription)"
  } else {
    throw [System.Net.WebException] "Request failed with status HTTP/$(
      $rsp.StatusCode): $($rsp.StatusDescription)"
  }

  if ($rsp) { $rsp.Dispose() }
}


$fullDeliveries = 0

foreach ($baseUrl in $destBaseUrls) {
  try {
    foreach ($fileName in $files) {
      uploadOneFileToOneServer $baseUrl $fileName
    }
    $fullDeliveries += 1
  } catch {
    Write-Error "W: Had failures for server '$baseUrl': $($_.Exception.Message)"
  }
}


if ($fullDeliveries -eq 0) {
  fail "Failed to fully deliver all files to any server."
} else {
  Write-Output "D: Success: Uploaded all files to $fullDeliveries server(s)."
}
