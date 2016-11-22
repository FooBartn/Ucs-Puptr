Ucs-Puptr aims to make management of configurations for your environment very simple.
You can easily import a configuration:

# Import Puptr Configuration

Let's assume we have removed all of our configurations, but we backed up Prod.ps1 to our D: drive:

Running Get-PuptrConfig would show nothing.

If we want to import our Prod configuration from our D: drive, we would run:

```PowerShell
Import-PuptrConfig -Path D:\Prod.ps1
```

Now if we run Get-PuptrConfig

[![Source](images/get-puptrconfig.png)](images/get-puptrconfig.png)