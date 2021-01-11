MacOS X install script for FusionInventory
------------------------------------------

This script downloads the lastest version of [Fusion Inventory][l_fusioninv] 
agent and install it on MacOSX.

## HowTo

 1. Download the zip archive and extract it
 2. Open a terminal an go to the previous created director
    ```
    cd directory/to/script
    ```
 3. execute the script with sudo with number of the structure, for Saint-Pierre
    it  will be:
    ```
    sudo ./install.sh -s https://glpi.example.com --u agent -p test -t "passwd"
    ```

That's all. Alternatively, you can clone this repository. 

## Usage

```
./install.sh -t <tag> -t <tag> -s <server> -u <user> -p <password>
```

 * `-s --server`: address to FusionInventory agent
 * `-u --user`: username for authentication
 * `-p --password`: password for authentication
 * `-t --tag`: add an extra tag, can be repeated to add more tags
 * `-h`: dislay help and exit
 * `-v`: version of this script and exit
 
## Default values

You can put your own default values. You need to open the `install.sh` with your
favorite text editor and modify lines 9 to 12 with yours, for example :

```bash
default_tags="web production"
default_password="My@gentP4ssw0rd"
default_user="agent"
default_server="https://agent.server.com"
```

When you give parameters values with command line options, default values will 
be overwrited.

## Licence

This script is released under le [MIT licence][l_mit]

Copyright © 2021 Yorick Barbanneau

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice (including the next
paragraph) shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[l_fusioninv]:http://fusioninventory.org
[l_mit]:https://opensource.org/licenses/mit-license.php
