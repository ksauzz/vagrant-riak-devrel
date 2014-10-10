# vagrant-riak-devrel

This is a vagrant projet to setup a local riak cluster from source using `make devrel DEVNODES=5` , such as [this](http://docs.basho.com/riak/latest/quickstart/).
If you'd like to run local riak nodes on separated virtual machines, you should use [vagrant-riak-cluster](https://github.com/hectcastro/vagrant-riak-cluster).

## Getting started

Start a virtual machine. It might take about 20 min to finish the provisioning.

```
$ git clone https://github.com/ksauzz/vagrant-riak-devrel.git
$ cd vagrant-riak-devrel
$ vagrant up
```

Start the riak nodes.

```
$ vagrant ssh
$ cd riak
$ for dev in dev/dev* ; do $dev/bin/riak start ; done
$ for dev in dev/dev* ; do $dev/bin/riak ping ; done
pong
pong
pong
pong
pong
```

Make a riak cluster.

```
$ for dev in dev/dev{2,3,4,5} ; do $dev/bin/riak-admin cluster join dev1@127.0.0.1 ; done
Success: staged join request for 'dev2@127.0.0.1' to 'dev1@127.0.0.1'
Success: staged join request for 'dev3@127.0.0.1' to 'dev1@127.0.0.1'
Success: staged join request for 'dev4@127.0.0.1' to 'dev1@127.0.0.1'
Success: staged join request for 'dev5@127.0.0.1' to 'dev1@127.0.0.1'
```

```
$ dev/dev1/bin/riak-admin cluster plan
=============================== Staged Changes ================================
Action         Details(s)
-------------------------------------------------------------------------------
join           'dev2@127.0.0.1'
join           'dev3@127.0.0.1'
join           'dev4@127.0.0.1'
join           'dev5@127.0.0.1'
-------------------------------------------------------------------------------


NOTE: Applying these changes will result in 1 cluster transition

###############################################################################
                         After cluster transition 1/1
###############################################################################

================================= Membership ==================================
Status     Ring    Pending    Node
-------------------------------------------------------------------------------
valid     100.0%     20.3%    'dev1@127.0.0.1'
valid       0.0%     20.3%    'dev2@127.0.0.1'
valid       0.0%     20.3%    'dev3@127.0.0.1'
valid       0.0%     20.3%    'dev4@127.0.0.1'
valid       0.0%     18.8%    'dev5@127.0.0.1'
-------------------------------------------------------------------------------
Valid:5 / Leaving:0 / Exiting:0 / Joining:0 / Down:0

Transfers resulting from cluster changes: 51
  12 transfers from 'dev1@127.0.0.1' to 'dev5@127.0.0.1'
  13 transfers from 'dev1@127.0.0.1' to 'dev4@127.0.0.1'
  13 transfers from 'dev1@127.0.0.1' to 'dev3@127.0.0.1'
  13 transfers from 'dev1@127.0.0.1' to 'dev2@127.0.0.1'
```

```
$ dev/dev1/bin/riak-admin cluster commit
Cluster changes committed
```

Test the riak cluster.

```
$ curl localhost:10018/ping
OK
```

