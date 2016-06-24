# README

**NOTE**: this is a test environment and the control repo used is NOT supposed to best practises.

# Introduction

This Vagrant environment sets up a CentOS 7 master with UTF-8 locale, plus numerous nodes to test UTF-8 within Puppet.  An associated [control repo](https://github.com/beergeek/japan_env.git) is utilised that has numerous attributes that are used to test parts of the environment.  An script is also included in this environment that can be used to query various APIs (wip currently)

The following is a list of the current machines:

* master.puppet.vm (CentOS 7)
* node0.puppet.vm (CentOS 6)
* node1.puppet.vm (CentOS 7)
* node2.puppet.vm (Ubuntu 16.04)
* node3.puppet.vm (Debian 8)
* win0.puppet.vm (Windows 2008r2)
* win1.puppet.vm (Windows 2012r2)

# Process

Firstly clone this environment

```shell
git clone https://github.com/beergeek/japan_env.git
```

To start the environment perform the following:

```shell
vagrant up
```

This will bring up the master, plus a CentOS6 and CentOS7 node.

The remaining nodes can be brought up separately as required, e.g.

```shell
vagrant up node3.puppet.vm
```
