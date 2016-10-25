---------
|1.8.1|
---------
* Added changelog

---------
|1.8 (10.24.2016)|
---------
* Added EnabledLanPorts test
* Added EnabledSanPorts test

---------
|1.7 (10.23.2016)|
---------
* Fixed issue with not specifying UCS domain name in IT test

---------
|1.6 (10.22.2016)|
---------
* Added Pool Utilization test
* Added Pool Schema test

---------
|1.5 (10.21.2016)|
---------
* Renamed and moved tests into content specific directories

---------
|1.4 (10.20.2016)|
---------
* Added Maintenance Policy test

---------
|1.3 (10.19.2016)|
---------
* Added Invoke-UcsPuptr.ps1 Pester wrapper for ease-of-use
* Fixed remediation on chassis discovery policy test
* Added configuration integration test to create Credential directory

---------
|1.2 (10.15.2016)|
---------
* Modified usage instructions 
* Added Cisco.UcsManager to required Modules
* Added project environment variables to tests and Template
* Split configuration integration tests into their own tagged describe block

---------
|1.1 (10.14.2016)|
---------
* Added Chassis Discovery Policy test

---------
|1.0 (10.13.2016)|
---------
* Forked from Vester
* Removed Vester Tests
* Updated default Config.ps1 file and tests for UCS systems
* Added support for multiple UCS domains
* Added usage of secure credentials
* Added 2 initial tests
    * FaultRetention
    * Faults
* Updated Template
