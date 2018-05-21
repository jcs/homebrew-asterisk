## Installation

    brew tap jcs/homebrew-asterisk-lts
    brew install asterisk

Create `asterisk` user (sharing only) and group in System Preferences.

	sudo chown -R asterisk:asterisk /usr/local/var/{spool,run,log}/asterisk
	sudo brew services start jcs/asterisk/asterisk
