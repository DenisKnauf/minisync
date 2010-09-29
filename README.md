MiniSync
========

This small sync-tool has only 3 files with lesser than 1000Byte.

c.rb
----

It will start *s.pl* on a remote machine via ssh and (via exec) *r.pl* local.

s.pl
----

On the remote machine,  it reads a dir and asks *r.pl*,  how many Bytes already synced.
It seeks to this Position and sends till *EOF*.

The complete sourcecode will be transfered via ssh and calls it via **perl -e**,  you may not copy it.

r.pl
----

On the local machine,  it will wait,  till *s.pl* will request,  how many Bytes the local file has.
*r.pl* opens and stats this file and responses.  Every content it will append to this file,
till *s.pl* will announce an other file.

Install
=======

First install ruby on your machine.
Perl - i think - is already installed on all your machines.


Usage
=====


  ./c.rb <MACHINE> DIR/REGEXP DEST

This will copy files,  which match expression REGEXP in DIR on MACHINE to local-dir DEST.
