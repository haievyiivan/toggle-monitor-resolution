<# :
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (${%~f0} | out-string)"
exit
#>

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ResChanger {
    [DllImport("user32.dll")]
    public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);
    [DllImport("user32.dll")]
    public static extern bool EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);
    [StructLayout(LayoutKind.Sequential)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int dmFields;
        public int dmPositionX;
        public int dmPositionY;
        public int dmDisplayOrientation;
        public int dmDisplayFixedOutput;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
        public short dmLogPixels;
        public int dmBitsPerPel;
        public int dmPelsWidth;
        public int dmPelsHeight;
        public int dmDisplayFlags;
        public int dmDisplayFrequency;
        public int dmICMMethod;
        public int dmICMIntent;
        public int dmMediaType;
        public int dmDitherType;
        public int dmReserved1;
        public int dmReserved2;
        public int dmPanningWidth;
        public int dmPanningHeight;
    }
}
"@

$currentWidth = (Get-WmiObject -Class Win32_VideoController).CurrentHorizontalResolution

if ($currentWidth -eq 1920) {
    $newWidth = 1280
    $newHeight = 720
} else {
    $newWidth = 1920
    $newHeight = 1080
}

$devmode = New-Object ResChanger+DEVMODE
$devmode.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($devmode)
[ResChanger]::EnumDisplaySettings($null, -1, [ref]$devmode)
$devmode.dmPelsWidth = $newWidth
$devmode.dmPelsHeight = $newHeight
$devmode.dmFields = 0x00080000 -bor 0x00100000 # DM_PELSWIDTH | DM_PELSHEIGHT
[ResChanger]::ChangeDisplaySettings([ref]$devmode, 0)
