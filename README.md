# lokinet builder

<p align="center">
    <a href="https://github.com/loki-project/lokinet-builder/commits/master"><img alt="pipeline status" src="https://gitlab.com/lokiproject/lokinet-builder/badges/master/pipeline.svg" /></a>
</p>

this repo is a recursive repo for building lokinet with all of the required libraries bundled as git submodules

## usage

to build do:

    $ sudo apt install build-essential libtool autoconf cmake git
    $ git clone --recursive https://github.com/loki-project/lokinet-builder
    $ cd lokinet-builder
    $ make

to run:

    $ ./lokinet
