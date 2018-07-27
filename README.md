# lokinet builder

this repo is a recursive repo for building lokinet with all of the required libraries bundled as git submodules

## usage

to build do:

    $ sudo apt install build-essential libtool autoconf cmake git
    $ git clone --recursive https://github.com/loki-project/lokinet-builder
    $ cd lokinet-builder
    $ make

to run:

    $ ./lokinet
