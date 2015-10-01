SwiftCGI
========
An implementation of the CGI and FastCGI specifications in Swift.


Motivation
----------
Apple has announced plans to open-source Swift, a language that provides
a nice combination of speed, safety, and expressibility. Why wouldn't someone
want to write web applications in it?

Naturally, it's a bit limited at this time because it will only run on Mac OS
X.


Design choices
--------------
Apple hasn't announced details of its open-source plans for Swift, but I
imagine that it will likely only consist of the core language and standard
libraries. In other words, frameworks like Foundation probably won't be
available.

Therefore, this library makes a conscious decision to avoid depending on
Foundation. This means reinventing the wheel in some situations—for example,
providing Swift wrappers around pthread threads and mutexes instead of
`NSThread` and `NSLock`, since using C-language types directly in Swift can
be overly verbose.


Usage
-----
_TODO: Document Apache configuration._
