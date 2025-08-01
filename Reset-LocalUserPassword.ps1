# Reset-LocalUserPassword.ps1

# Get all local non-built-in users
$users = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Name -ne "Administrator" -and $_.Name -ne "Guest" }

if ($users.Count -eq 0) {
    Write-Host "❌ No eligible local users found." -ForegroundColor Red
    exit
}

Write-Host "🧑 Available Local Users:"
$users | ForEach-Object { Write-Host " - $($_.Name)" }

$userToReset = Read-Host "🔐 Enter the username you want to reset"
$targetUser = Get-LocalUser -Name $userToReset -ErrorAction SilentlyContinue

if (-not $targetUser) {
    Write-Host "❌ User not found." -ForegroundColor Red
    exit
}

$newPassword = Read-Host "🔑 Enter new password" -AsSecureString

try {
    Set-LocalUser -Name $userToReset -Password $newPassword
    Write-Host "✅ Password for '$userToReset' has been reset."
    
    $log = "$env:USERPROFILE\Desktop\password_reset_log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - Password reset for $userToReset by $env:USERNAME" | Out-File -FilePath $log -Append -Encoding UTF8

    Write-Host "📄 Logged in: $log"
} catch {
    Write-Host "❌ Error resetting password: $_" -ForegroundColor Red
}
