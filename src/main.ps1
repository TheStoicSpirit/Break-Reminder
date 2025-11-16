#Requires -Version 5.1
<#
.SYNOPSIS
    Break Reminder - GUI Prompt Script
.DESCRIPTION
    Displays a random break reminder message with options to take a break or skip.
.NOTES
    Version: 1.0.0
    License: AGPL-3.0
    Author: The Stoic Spirit
#>

# Import required assemblies for WPF GUI
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

# Configuration paths
$configFile = Join-Path $projectRoot "data\config.ini"
$messagesFile = Join-Path $projectRoot "data\messages.txt"
$logDir = Join-Path $projectRoot "logs"
$logFile = Join-Path $logDir "break-reminder.log"

# Default configuration
$config = @{
    MessagesFile = $messagesFile
    BreakAction = "sleep"
    EnableLogging = $true
    LogFile = $logFile
}

# Ensure log directory exists immediately
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Function to write log entries
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    if ($config.EnableLogging) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Ensure log directory exists
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        
        # Write to log file
        try {
            Add-Content -Path $config.LogFile -Value $logEntry -ErrorAction SilentlyContinue
        } catch {
            # If logging fails, continue silently
        }
    }
}

# Function to load configuration from INI file
function Get-Configuration {
    if (Test-Path $configFile) {
        try {
            $iniContent = Get-Content $configFile
            foreach ($line in $iniContent) {
                if ($line -match '^\s*([^=]+?)\s*=\s*(.+?)\s*$') {
                    $key = $matches[1]
                    $value = $matches[2]
                    
                    # Handle boolean values
                    if ($value -eq "true") { $value = $true }
                    if ($value -eq "false") { $value = $false }
                    
                    # Update config if key exists
                    if ($config.ContainsKey($key)) {
                        # Convert relative paths to absolute
                        if ($key -like "*File" -or $key -like "*Dir") {
                            $value = Join-Path $projectRoot $value
                        }
                        $config[$key] = $value
                    }
                }
            }
            Write-Log "Configuration loaded successfully"
        } catch {
            Write-Log "Error loading configuration: $_" -Level "WARNING"
        }
    } else {
        Write-Log "Configuration file not found, using defaults" -Level "INFO"
    }
}

# Function to execute break action
function Invoke-BreakAction {
    param([string]$Action)
    
    Write-Log "Executing break action: $Action"
    
    try {
        switch ($Action.ToLower()) {
            "sleep" {
                Add-Type -TypeDefinition @"
                    using System;
                    using System.Runtime.InteropServices;
                    public class PowerManagement {
                        [DllImport("powrprof.dll", SetLastError = true)]
                        public static extern bool SetSuspendState(bool hibernate, bool forceCritical, bool disableWakeEvent);
                    }
"@
                [PowerManagement]::SetSuspendState($false, $false, $false) | Out-Null
                Write-Log "System sleep initiated"
            }
            "lock" {
                rundll32.exe user32.dll,LockWorkStation
                Write-Log "Workstation locked"
            }
            "hibernate" {
                Add-Type -TypeDefinition @"
                    using System;
                    using System.Runtime.InteropServices;
                    public class PowerManagement {
                        [DllImport("powrprof.dll", SetLastError = true)]
                        public static extern bool SetSuspendState(bool hibernate, bool forceCritical, bool disableWakeEvent);
                    }
"@
                [PowerManagement]::SetSuspendState($true, $false, $false) | Out-Null
                Write-Log "System hibernation initiated"
            }
            "shutdown" {
                Stop-Computer -Force
                Write-Log "System shutdown initiated"
            }
            default {
                Write-Log "Unknown break action: $Action, defaulting to lock" -Level "WARNING"
                rundll32.exe user32.dll,LockWorkStation
            }
        }
    } catch {
        Write-Log "Error executing break action: $_" -Level "ERROR"
    }
}

# Load configuration
Get-Configuration

# Read messages from file
try {
    if (Test-Path $config.MessagesFile) {
        $messages = Get-Content $config.MessagesFile | Where-Object { $_.Trim() -ne "" }
        Write-Log "Loaded $($messages.Count) messages from file"
    } else {
        Write-Log "Messages file not found: $($config.MessagesFile)" -Level "ERROR"
        $messages = @("Time for a break! Your health matters.")
    }
} catch {
    Write-Log "Error reading messages file: $_" -Level "ERROR"
    $messages = @("Time for a break! Your health matters.")
}

# Select a random message
$randomMessage = $messages | Get-Random
Write-Log "Selected message: $randomMessage"

# XAML for the window with modern styling
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Break Reminder" 
        Height="320" 
        Width="450" 
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="Margin" Value="8"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Effect">
                <Setter.Value>
                    <DropShadowEffect BlurRadius="10" ShadowDepth="2" Opacity="0.3"/>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <!-- Main container with rounded border and shadow -->
    <Border Background="#1A1A2E" 
            CornerRadius="12" 
            BorderBrush="#3D4A6B" 
            BorderThickness="1">
        <Border.Effect>
            <DropShadowEffect BlurRadius="25" ShadowDepth="0" Opacity="0.6" Color="#000000"/>
        </Border.Effect>
        
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            
            <!-- Custom Title Bar -->
            <Border x:Name="TitleBar"
                    Grid.Row="0" 
                    Background="#16213E" 
                    CornerRadius="12,12,0,0"
                    Height="35">
                <Grid>
                    <StackPanel Orientation="Horizontal" 
                                HorizontalAlignment="Left" 
                                VerticalAlignment="Center"
                                Margin="12,0,0,0">
                        <Ellipse Width="10" 
                                 Height="10" 
                                 Fill="#A29BFE"
                                 Margin="0,0,8,0"
                                 VerticalAlignment="Center"/>
                        <TextBlock Text="Break Reminder" 
                                   FontSize="12" 
                                   Foreground="#E0E0E0"
                                   FontWeight="SemiBold"
                                   VerticalAlignment="Center"/>
                    </StackPanel>
                    
                    <Button x:Name="CloseButton"
                            Content="x"
                            HorizontalAlignment="Right"
                            VerticalAlignment="Center"
                            Width="35"
                            Height="35"
                            Background="Transparent"
                            Foreground="#95A5A6"
                            BorderThickness="0"
                            FontSize="20"
                            FontFamily="Segoe UI"
                            Cursor="Hand"
                            Margin="0">
                        <Button.Style>
                            <Style TargetType="Button">
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="Button">
                                            <Border Background="{TemplateBinding Background}" 
                                                    CornerRadius="0,12,0,0">
                                                <ContentPresenter HorizontalAlignment="Center" 
                                                                  VerticalAlignment="Center"/>
                                            </Border>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Background" Value="#E74C3C"/>
                                        <Setter Property="Foreground" Value="White"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>
                    </Button>
                </Grid>
            </Border>
            
            <!-- Content Area -->
            <Grid Grid.Row="1" Margin="25">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Header with gradient background -->
                <Border Grid.Row="0" 
                        CornerRadius="8"
                        Margin="0,0,0,20"
                        Padding="15,10">
                    <Border.Background>
                        <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                            <GradientStop Color="#6C5CE7" Offset="0"/>
                            <GradientStop Color="#A29BFE" Offset="1"/>
                        </LinearGradientBrush>
                    </Border.Background>
                    <TextBlock Text="Time for a Break!" 
                               FontSize="22" 
                               FontWeight="Bold" 
                               Foreground="White"
                               HorizontalAlignment="Center">
                        <TextBlock.Effect>
                            <DropShadowEffect BlurRadius="8" ShadowDepth="2" Opacity="0.4"/>
                        </TextBlock.Effect>
                    </TextBlock>
                </Border>

                <!-- Message with glassmorphism effect -->
                <Border Grid.Row="1" 
                        Background="#16213E" 
                        CornerRadius="10" 
                        Padding="20"
                        BorderBrush="#3D4A6B"
                        BorderThickness="1"
                        MinHeight="80">
                    <Border.Effect>
                        <DropShadowEffect BlurRadius="15" ShadowDepth="3" Opacity="0.4" Color="#000000"/>
                    </Border.Effect>
                    <TextBlock x:Name="MessageText" 
                               TextWrapping="Wrap" 
                               FontSize="16" 
                               VerticalAlignment="Center" 
                               HorizontalAlignment="Center"
                               Foreground="#E0E0E0"
                               TextAlignment="Center"
                               LineHeight="24"
                               MaxWidth="380"/>
                </Border>

                <!-- Buttons with vibrant gradients -->
                <StackPanel Grid.Row="2" 
                            Orientation="Horizontal" 
                            HorizontalAlignment="Center"
                            Margin="0,20,0,0">
                    <Button x:Name="TakeBreakButton" 
                            Content="Take a Break" 
                            Width="150"
                            Height="40"
                            Foreground="White"
                            BorderThickness="0">
                        <Button.Background>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                <GradientStop Color="#00D2FF" Offset="0"/>
                                <GradientStop Color="#3A7BD5" Offset="1"/>
                            </LinearGradientBrush>
                        </Button.Background>
                        <Button.Style>
                            <Style TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="Button">
                                            <Border Background="{TemplateBinding Background}" 
                                                    CornerRadius="8"
                                                    BorderThickness="0">
                                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                            </Border>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Opacity" Value="0.85"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>
                    </Button>
                    
                    <Button x:Name="SkipButton" 
                            Content="Skip" 
                            Width="150"
                            Height="40"
                            Foreground="White"
                            BorderThickness="0">
                        <Button.Background>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                <GradientStop Color="#4A5568" Offset="0"/>
                                <GradientStop Color="#2D3748" Offset="1"/>
                            </LinearGradientBrush>
                        </Button.Background>
                        <Button.Style>
                            <Style TargetType="Button" BasedOn="{StaticResource {x:Type Button}}">
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="Button">
                                            <Border Background="{TemplateBinding Background}" 
                                                    CornerRadius="8"
                                                    BorderThickness="0">
                                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                            </Border>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                                <Style.Triggers>
                                    <Trigger Property="IsMouseOver" Value="True">
                                        <Setter Property="Opacity" Value="0.85"/>
                                    </Trigger>
                                </Style.Triggers>
                            </Style>
                        </Button.Style>
                    </Button>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# Load XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml

try {
    $window = [Windows.Markup.XamlReader]::Load($reader)
    Write-Log "Window loaded successfully"
} catch {
    Write-Log "Error loading XAML: $_" -Level "ERROR"
    exit 1
}

# Get controls
$messageText = $window.FindName("MessageText")
$takeBreakButton = $window.FindName("TakeBreakButton")
$skipButton = $window.FindName("SkipButton")
$closeButton = $window.FindName("CloseButton")
$titleBar = $window.FindName("TitleBar")

# Set the random message
$messageText.Text = $randomMessage

# Enable window dragging from title bar
$titleBar.Add_MouseLeftButtonDown({
    $window.DragMove()
})

# Take Break button click event
$takeBreakButton.Add_Click({
    Write-Log "User chose to take a break"
    $window.DialogResult = $true
    $window.Close()
})

# Skip button click event
$skipButton.Add_Click({
    Write-Log "User skipped the break"
    $window.DialogResult = $false
    $window.Close()
})

# Close button (X) click event - treat as Skip
$closeButton.Add_Click({
    Write-Log "Window closed via close button (treated as skip)"
    $window.DialogResult = $false
    $window.Close()
})

# Handle window closing without button click
$window.Add_Closing({
    if ($null -eq $window.DialogResult) {
        Write-Log "Window closed without selection (treated as skip)"
        $window.DialogResult = $false
    }
})

# Show the window and get result
try {
    $result = $window.ShowDialog()
    
    # If user chose to take a break, execute the configured action
    if ($result) {
        Invoke-BreakAction -Action $config.BreakAction
    }
    
    Write-Log "Script completed successfully"
} catch {
    Write-Log "Error showing dialog: $_" -Level "ERROR"
    exit 1
}