# Security policy

Do not submit Steam credentials, browser cookies, Wi-Fi secrets, SSH private
keys, Proton prefixes, game files, or `/etc/sudoers.d` contents in issues.

The project does not ship a passwordless administrator policy. The Decky
plugin has root capability because the current battery workaround must patch
the user-installed MangoHud runtime. Review `main.py` before installing it.

Report sensitive vulnerabilities privately through GitHub Security Advisories.
