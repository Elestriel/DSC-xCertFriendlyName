enum Ensure {
    Present;
    Absent;
}

[DscResource()]
class xCertFriendlyName {
    [DscProperty(Key)]
    [string] $Thumbprint;

    [DscProperty(Mandatory)]
    [string] $FriendlyName;

    [DscProperty(Mandatory)]
    [string] $CertStore;

    [DscProperty(Mandatory)]
    [Ensure] $Ensure;

    [xCertFriendlyName] Get() {
        $Cert = $this.GetCertificate();

        if ($Cert) {
            if ($Cert.FriendlyName -eq $this.FriendlyName) { 
                $this.Ensure = [Ensure]::Present; 
            }
            else { 
                $this.Ensure = [Ensure]::Absent; 
            }
        }
        else {
            $this.Ensure = [Ensure]::Absent; 
        }

        return $this
    }

    [void] Set() {
        $Cert = $this.GetCertificate();

        if ($Cert) {
            if ($Cert.FriendlyName -ne $this.FriendlyName) {
                Write-Host "Updating certificate Friendly Name to $($this.FriendlyName)"
                $Cert.FriendlyName = $this.FriendlyName
            }
        }
        else {
            Write-Error "A certificate could not be found with thumbprint $($this.Thumbprint)."
        }
    }

    [bool] Test() {
        $Cert = $this.GetCertificate();

        if ($Cert) {
            if ($Cert.FriendlyName -eq $this.FriendlyName) {
                return $true;
            }
        }

        return $false;
    }

    [object] GetCertificate() {
        $CertPath = Join-Path -Path $this.CertStore -ChildPath $this.Thumbprint;
        $Cert = Get-ChildItem $CertPath;

        return $Cert;
    }
}
