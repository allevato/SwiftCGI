SwiftCGI
========
An implementation of the CGI and FastCGI specifications in Swift.


Motivation
----------
Apple has announced plans to open-source Swift, a language that provides
a nice combination of speed, safety, and expressibility. Why wouldn't someone
want to write web applications in it?

Naturally, it's a bit limited at this time because it will only run on Mac OS
X. This project is still in a very experimental state; I wouldn't recommend it
being used seriously until Swift goes open-source and runs on Linux.


Design choices
--------------
This framework tries to be as idiomatically Swift-y as possible: using
protocol-driven patterns and `struct`s over `class`es whenever appropriate,
algebraic enumerated types, and so forth.

Apple hasn't announced details of its open-source plans for Swift, but I
imagine that it will likely only consist of the core language and standard
libraries. In other words, frameworks like `Foundation` that are specific
to OS X probably won't be available.

Therefore, this library makes a conscious decision to avoid depending on
`Foundation` whenever possible. This means reinventing the wheel in some
situations—for example, providing Swift wrappers around `pthread` threads
and mutexes instead of `NSThread` and `NSLock`, since using C-language types
directly in Swift can be overly verbose.

The SwiftCGI project intentionally does **not** provide a microframework;
from an architectural point of view, such a framework should be separate and
can be implemented on top of SwiftCGI's public interfaces, which provide the
gateway layer between the web server and the application and nothing more.


Usage
-----
This guide covers how to get SwiftCGI up and running quickly with the default
OS X installation of Apache. If you are using another web server, please refer
to its documentation.

_TODO: Once Swift goes open-source and runs on Linux, update these
instructions._

### Usage as a CGI process
1. Edit the Apache config file:

       $ sudo vi /etc/apache2/httpd.conf

2. Find the `LoadModule` line for `cgi_module`, and uncomment it if necessary:

       LoadModule cgi_module libexec/apache2/mod_cgi.so

3. Save your changes.
4. Build an executable using SwiftCGI and copy it into the location where Apache
   on OS X looks for CGI executables. By default, this directory is:

       /Library/WebServer/CGI-Executables

   If you are using SwiftCGI as a framework instead of compiling the sources
   directly into your application, copy the framework into this location as
   well.
5. Restart Apache:

       $ sudo apachectl restart

6. Try the application in your web browser or using `curl`. For example, if your
   application is `SwiftCGIDemo`, use the following URL:

       http://localhost/cgi-bin/SwiftCGIDemo

   You can also add additional path information or query parameters to this URL
   and they will be processed as expected by a CGI application.

### Usage as a FastCGI process
_TODO: Write this section once FastCGI is implemented._


Known issues
------------
If you build an executable that links to SwiftCGI as a framework (as the demo
project is structured), you will see a number of messages similar to the following
dumped into your web server's error log when the CGI/FastCGI process is started:

    Class _SwiftNativeNSSetBase is implemented in both /Library/WebServer/CGI-Executables/SwiftCGI.framework/Versions/A/Frameworks/libswiftCore.dylib
    and /Library/WebServer/CGI-Executables/SwiftCGIDemo.
    One of the two will be used. Which one is undefined.

These are because the Swift core libraries are being linked into the executable
_as well as_ being included as dylibs inside the framework bundle. As long as they
are the same version, the messages are harmless. They can be avoided by including
the SwiftCGI sources directly in your project, rather than building a separate
dynamically-linked framework.
