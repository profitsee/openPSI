## Description

### Folders:

./_unused: files that are not used anymore but might still be useful in the future

./am: ETL scaling tools

./cfgen: cfgen assembles the data from './config' and 'secrets' and builds BTRFS images containing host specific configuration and needed genesis modules.
These images are deployed to each machine.

./config: contains all the templates, scripts and configuration details of the infrastructure.
Each folder corresponds to a genesis Plugin, except 'Cluster', which contains the machine definitions.
The format of the folder contents are defined in cfgen.

./dnssl: used to edit DNS entries (cloudflare) and SSL certs (Letsencrypt)

./doc: contains various usage descriptions

./genesis: all the logic, see 'genesis' below

./Libs/Core: provides a framework for an extensible interface. used by genesis and cfgen

./Libs/PSI: various small helpers that are used throughout the place

./Libs/Tree: Libraries used for Trees. The heart of Core and its extensions

./tools: various devtools 


### genesis

genesis consists of several parts.

'./Config' contains machine specific configuration files generated by cfgen. on devop, this is a symbolic link

'./Plugins' provide all the functionality and executable commands.






