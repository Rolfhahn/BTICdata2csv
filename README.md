BeyondTrust(R) Integration Client Archive Data to CSV - File Generator - Version 1.1.
(this script is not supported by BeyondTrust(R) !!  /  Any use is at your own risk)

Author: Rolf Hahn - Microdyn AG Switzerland - www.microdyn.ch 

Reason for this script:
 This Script creates a CSV-file from a collection of "BeyondTrust Integration Client" .XML and .M4V session-files.
 You can import this CSV file in Excel.
 For example, a ciso can get an overview of all sessions from an entire year in just one file. 

How to configure and prepare it:
 A .json control file must be located in the "configs" subdirectory of the script. 
 The .json file is normally given the name of the BeyondTrust site. Example: \control\site_company_org.json
 An example config file can be found under the following link: https://github.com/Rolfhahn/BTICdata2csv/blob/main/Configs/BTSITE_config.json
 The following 4 parameters can be adjusted in the content of the control-file:
    
    "BTXMLPath":"\\\\server\\share\\dir\\ic\\BTsitedir\\2",            - this is the path to the Integration-Client SessionData .xml Files Collection.
    "BTM4VPath":"\\\\server\\share\\dir\\ic\\BTsitedir\\3",            - this is the path to the Integration-Client SessionRecording .m4v Files Collection.
    "MDCSVPath":"\\\\server\\share\\dir\\ic\\BTsitedir\\MDDailyCSV",   - this is the path to the .CSV Output file which the script will generate. 
    "AjustFileDT":0                                                    - Should the date and time of the XML files and the M4V files be adjusted to
                                                                         the actual session time instead of the export time of the Integration Client? 
                                                                         Select 1 here - otherwise 0 .

Parameters to start the script: 
 ./MD-createCSVfromBTXML -CFGFile [nameofyourconfigfile.json]
 
Remarks:
 BeyondTrust(R) is a registered Trademark of BeyondTrust Corporation 
 This script is from MICRODYN AG and is not endorsed by BeyondTrust. !!
