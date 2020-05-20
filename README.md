![Dropbox Indicator Header](https://github.com/rbribeiro/wingpanel-indicator-dropbox/blob/master/screenshots/top.png)
Just a simple Dropbox indicator for **elementary OS**.
### Features
- ✔️ See Dropbox current status
- 🔎️ Search for files
- 🗃️ Recent Activity (see most recent files)
- 🌍️ Shortchut to Dropbox's website
- 📂️ Shortcut to your Dropbox folder

### Requirements
- ⚠️ The Official Dropbox CLI. You can download it here https://www.dropbox.com/install-linux .
- ⚠️ Your Dropbox setup must be working, that is, you must be signed in with your dropbox account.

### Install 
- 📦️ [Download](https://github.com/rbribeiro/wingpanel-indicator-dropbox/blob/master/packages/com.github.rbribeiro.wingpanel-indicator-dropbox_0.1_amd64.deb) .deb package and run

``sudo dpkg -i com.github.rbribeiro.wingpanel-indicator-dropbox_0.1_amd64.deb``

- ⚙️ Compile from source:

 ``git clone https://github.com/rbribeiro/wingpanel-indicator-dropbox.git``
 
 ``cd wingpanel-indicator-dropbox``
 
 `meson build --prefix=/usr`
 
 `cd build`
 
 `ninja`
 
 `sudo ninja install`
 
 ### Uninstall
 - 📦️ From package: `sudo dpkg -r com.github.rbribeiro.wingpanel-indicator-dropbox`
 - ⚙️ From source: On the build directory ``sudo ninja uninstall``
