library(shiny)

ui <- fluidPage(
  titlePanel("Windows11 Debloater Minimal"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("tasks", "Select tasks to perform:",
                         choices = list(
                           "Remove Bloatware Apps" = "bloatware",
                           "Disable Telemetry" = "telemetry",
                           "Disable Bing & Cortana" = "bing",
                           "Show File Extensions & Hidden Files" = "files",
                           "Disable Widgets & Chat" = "widgets",
                           "Align Taskbar Left" = "taskbar"
                         ),
                         selected = c("bloatware", "telemetry")),
      actionButton("run", "Run Debloat")
    ),
    mainPanel(
      verbatimTextOutput("result")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$run, {
    selectedTasks <- input$tasks
    scriptPath <- tempfile(fileext = ".ps1")
    
    scriptLines <- c(
      "if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { Write-Warning 'Run as Admin!'; exit 1 }"
    )
    
    if ("bloatware" %in% selectedTasks) {
      scriptLines <- c(scriptLines, "
        $bloatwareApps = @(
          'Microsoft.3DBuilder', 'Microsoft.BingNews', 'Microsoft.GetHelp',
          'Microsoft.Getstarted', 'Microsoft.Microsoft3DViewer', 'Microsoft.MicrosoftOfficeHub',
          'Microsoft.MicrosoftSolitaireCollection', 'Microsoft.MicrosoftStickyNotes',
          'Microsoft.MixedReality.Portal', 'Microsoft.MSPaint', 'Microsoft.OneConnect',
          'Microsoft.People', 'Microsoft.Print3D', 'Microsoft.SkypeApp', 'Microsoft.Wallet',
          'Microsoft.WindowsAlarms', 'Microsoft.WindowsCalculator', 'Microsoft.WindowsCamera',
          'Microsoft.WindowsFeedbackHub', 'Microsoft.WindowsMaps', 'Microsoft.WindowsSoundRecorder',
          'Microsoft.Xbox.TCUI', 'Microsoft.XboxApp', 'Microsoft.XboxGameOverlay',
          'Microsoft.XboxGamingOverlay', 'Microsoft.XboxIdentityProvider', 'Microsoft.ZuneMusic',
          'Microsoft.ZuneVideo'
        )
        foreach ($app in $bloatwareApps) {
          Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
          Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
        }
      ")
    }
    
    if ("telemetry" %in% selectedTasks) {
      scriptLines <- c(scriptLines, "
        New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection' -Name 'AllowTelemetry' -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo' -Name 'Enabled' -Value 0 -PropertyType DWord -Force | Out-Null
      ")
    }
    
    if ("bing" %in% selectedTasks) {
      scriptLines <- c(scriptLines, "
        New-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Search' -Name 'BingSearchEnabled' -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Search' -Name 'CortanaConsent' -Value 0 -PropertyType DWord -Force | Out-Null
      ")
    }
    
    if ("files" %in% selectedTasks) {
      scriptLines <- c(scriptLines, "
        Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'HideFileExt' -Value 0 -Force
        Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'Hidden' -Value 1 -Force
      ")
    }
    
    if ("widgets" %in% selectedTasks) {
      scriptLines <- c(scriptLines, "
        New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'TaskbarDa' -Value 0 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'TaskbarMn' -Value 0 -PropertyType DWord -Force | Out-Null
      ")
    }
    
    if ("taskbar" %in% selectedTasks) {
      scriptLines <- c(scriptLines, "
        New-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'TaskbarAl' -Value 0 -PropertyType DWord -Force | Out-Null
      ")
    }
    
    scriptLines <- c(scriptLines, "Write-Host 'All selected tweaks applied. Restart to take full effect.'")
    
    writeLines(scriptLines, scriptPath)
    result <- shell(paste("powershell -ExecutionPolicy Bypass -File", shQuote(scriptPath)), intern = TRUE)
    output$result <- renderPrint({ result })
  })
}

shinyApp(ui, server)
