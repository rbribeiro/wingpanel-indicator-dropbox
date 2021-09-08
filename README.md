![Dropbox Indicator Header](https://github.com/rbribeiro/wingpanel-indicator-dropbox/blob/master/screenshots/top.png)
Just a simple Dropbox indicator for **elementary OS**.
### Features
- ✔️ See Dropbox current status
- 🔎️ Search for files
- 🗃️ Recent Activity (see most recent files)
- 🌍️ Shortcut to Dropbox's website
- 📂️ Shortcut to your Dropbox folder

### Requirements
- ⚠️ The Official Dropbox CLI. You can download it here https://www.dropbox.com/install-linux .
- ⚠️ Your Dropbox setup must be working, that is, you must be signed in with your dropbox account.

### Install 
- ⚙️ Compile from source:

Install the eOS sdk

``sudo apt install elementary-sdk``

Clone the repository

 ``git clone https://github.com/rbribeiro/wingpanel-indicator-dropbox.git``
 
 ``cd wingpanel-indicator-dropbox``
 
 `meson build --prefix=/usr`
 
 `cd build`
 
 `ninja`
 
 `sudo ninja install`
 
 ### Uninstall
 - ⚙️ From source: On the build directory ``sudo ninja uninstall``
