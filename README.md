# ControlPanel

Powershell Module for Windows Control Panel functions

### Version
  - 1.0
  
## Functions

  - **Get-CPFolderOption**
    - Retrieves the Folder Options from the control panel.  Options such as Hide Known file Extensions.
	
	- **`[String[]]`ComputerName** : Name of the computer to retrieve the info from. 

  - **Set-CPFolderOption**
    - Sets the Folder Options in the Control Panel. Including one of the switches toggles the setting.  If it is already 0 then it flips it to 1.  If already 1 then it flips to 0.
	
	- **`[String[]]`ComputerName** :  Name of the computer to configure.
	- **`[Switch]`HideEmptyDrives** : Toggles weather an empty drive is hidden.  Value of 1 is hidden.
	- **`[Switch]`HideFileExt** : Toggles weather or not to hide file extensions.  Value of 1 is hidden.
	- **`[Switch]`ShowSuperHidden** : Toggles weather to hide OS Files.  Value of 1 is hidden.