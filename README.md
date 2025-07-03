
<!--#echo json="package.json" key="name" underline="=" -->
easydav-pwshput-pmb
===================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
PowerShell script to upload (HTTP PUT) files onto a WebDAV or regular HTTP
server.
<!--/#echo -->

The script tries to upload all given files to all given servers.
If an upload fails, the server is considered dead and the script continues
with the next server, if any remain.
The mission is considered successful if at least one server confirmed
receiving all the files.
Even then, all remaining servers will be tried, to achieve maximum spread
of whatever is to be published.

If you need another strategy, give just one file and/or just one server
per invocation and manage the queue yourself.



Installation
------------

#### Ubuntu

You'll need to install [PowerShell][pwsh-rls].
To fix potential missing dependencies after installing the .deb,
run: `sudo apt-get install --fix-broken`

  [pwsh-rls]: https://github.com/PowerShell/PowerShell/releases



#### Windows 10/11

The script should work out of the box.



Configuration
-------------

#### Environment variables

* `HTTP_CONNECT_TIMEOUT`, `HTTP_RESPONSE_TIMEOUT`:
  Optional, in seconds, supports decimal fractions.
* `HTTP_PUT_DATE_SUFFIX`:
  Optional, string, add date to end of file basename (i.e. before final dot).
  There are some pre-defined shorthands that you can use as part of your
  date format template.
  Search the script for the option name for more information.



Usage
-----

#### CLI arguments

* CLI arguments that contain `://` are destination servers.
* All other arguments are filenames to be uploaded.



#### Ubuntu

```text
./http_put.ps1 http://example.net/webdav/ http://upload.test/ package.json README.md
```



#### Windows

```text
set pwsh=powershell.exe -ExecutionPolicy Bypass -File
%pwsh% http_put.ps1 http://example.net/webdav/ http://upload.test/ package.json README.md
```

… or use [`http_put.cmd`](http_put.cmd).

* `-ExecutionPolicy` seems to be a type of noob protection to prevent easy
  double-click execution of email attachments, similar to the
  "I trust this file" checkbox that you have to set on downloaded ZIP files
  before unpacking to make it so you can actually execute files.



<!--#toc stop="scan" -->



Caveats
-------

* The date format template is rendered verbatim, rather than replaced with
  the expected digits. &rarr; There are probably literal double quotes (`"`)
  in the value of the date suffix variable, probably from using Unix-like
  quotes in a Windows `set` command.



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
