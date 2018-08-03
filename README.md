# lokinet builder

<p align="center">
    <a href="https://github.com/loki-project/lokinet-builder/commits/master"><img alt="pipeline status" src="https://gitlab.com/lokiproject/lokinet-builder/badges/master/pipeline.svg" /></a>
</p>

this repo is a recursive repo for building lokinet with all of the required libraries bundled as git submodules

## building on linux for linux

    # or your OS or distro's package manager
    $ sudo apt install build-essential libtool autoconf cmake git
    $ git clone --recursive https://github.com/loki-project/lokinet-builder
    $ cd lokinet-builder
    $ make 

## cross compile on linux for windows
    
    $ sudo apt install build-essential libtool autoconf cmake git mingw-w64
    $ git clone --recursive https://github.com/loki-project/lokinet-builder
    $ cd lokinet-builder
    $ make windows

## building the debian package

    $ sudo apt install devscripts build-essential libtool autoconf cmake git
    $ git clone --recursive https://github.com/loki-project/lokinet-builder
    $ cd lokinet-builder
    $ debuild -b -us -uc
    