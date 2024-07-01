@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'LabTools.psm1'

    # Version number of this module.
    ModuleVersion = '1.0'

    # ID used to uniquely identify this module
    GUID = '12345678-90ab-cdef-1234-567890abcdef'

    # Author of this module
    Author = 'Jonathan David'

    # Description of the functionality provided by this module
    Description = 'Swiss army knife for all Windows functionstoexportrtrtcyber lab needs when dealing in offensive security,
    for the sake of testing defense systems for proper alert/prevention engineering rules, and overall technical 
    product testing to really trigger alerts in great systems accross Windows based environments.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('PSRemoting')

    # Functions to export from this module
    FunctionsToExport = @('Obfuscate_Pack') #, 'Next_Function')


    # List of all files packaged with this module
    FileList = @(
        'LabTools.psd1',
        'LabTools.psm1',
        'Functions\Connect_Remotely.ps1',
        'Functions\Obfuscate_Pack.ps1'
    )

}

