MiniSync
========

This small sync-tool has only 2 small files.


s.pl
----

On the remote machine,  it reads a dir and asks *r.pl*,  how many Bytes already synced.
It seeks to this Position and sends till *EOF*.

The complete sourcecode will be transfered via ssh and calls it via **perl -e**,  you may not copy it.


r.pl
----

This programm is the main-part.  It will connect via ssh to the remote machine and
starts *s.pl* remote via **perl -e**.

On the local machine,  it will wait,  till *s.pl* will request,  how many Bytes the local file has.
*r.pl* opens and stats this file and responses.  Every content it will append to this file,
till *s.pl* will announce an other file.


Install
=======

Perl - i think - is already installed on all your machines.

Usally,  there is nothing to do.

Usage
=====

  ./r.pl <MACHINE> DIR/REGEXP DEST

This will copy files,  which match expression REGEXP in DIR on MACHINE to local-dir DEST.
