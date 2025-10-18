# Parse BASH command lines
## Overview
This repository details the somewhat automated way in which I  have created helper scripts to help myself templatise the parsing of command line arguments (both short and long) in a BASH script. The files it contains are the following:
1. `init.sh`: This script actually is used to create the script `parse-command-line.sh`. It is present just to make life a bit easier. In reality it is the `parse-command-line.sh` which does all the heavy lifting. 
1. `parse-command-line.sh`: This script is the script which parses your command line arguments. When using it, it exposes 4 main variables to be used:
    - `map_long_to_short`: This is an associative array which maps long options to short options (e.g `--aye` => `-a`).
    - `map_short_type`: This is an associative array which maps short options to a "type". In the current implementation the current types I support are "k" and "v". 
        - `"v" type`: This means that the short option **requires** a value. This is similar in concept to getopts when you are specifying the option string and you must put a ":" after the character (e.g `"a:b:c:"`).
        - `"k" type`: This means that the short option **is only** a key. In other words, it functions as a true/false switch.
    - `map_runtime`: This is an associative array which picks up the options we inputted on the command line and the corresponding values for those options. It does this as we run the script (so I thought a fitting name was "runtime").
    - `ARGC`: This is the number of command line arguments which was entered. for example:
        - Entering: `-a a_val -b b_val -c "cee val" -d` would mean that `ARGC` equals 7
        - Entering: `--aye "a long" --bee "b long" --dee --` would mean that `ARGC` equals 6 (because in this case we have the extra `--` which wasn't entered in the previous example).

    Moreover, the script also exports a useful function called `print_array` which you can use to print out (in JSON format) what an associative array looks like.
1. `main.sh`: This is just an example script to show the usage of how to reference `parse-command-line.sh` and the variables and functions which are exposed. the script is the following:

    ```BASH
    #! /usr/bin/bash

    . ./parse-command-line.sh "$@"
    shift $ARGC

    # printing out variables which are defined in parse-command-line.sh
    echo "ARGC: $ARGC"
    print_array "map_long_to_short"
    print_array "map_short_type"
    print_array "map_runtime"
    echo $1
    ```
    You can try running this with the example `-a "short_a" --bee "long bee" --cee "long c" -d -- "hello world"

## Usage
To use the repository by entering quoted positional paramters to the init.sh in the following form: `<optional long parameter>:<required short parameter>:<k or v>`. For example:

```
./init.sh "aye:a:v" "bee:b:v" "cee:c:v" "dee:d:k" ":e:v"
```

This create the `parse-command-line.sh` file with the following meanings:
1. `--aye or -a` requires a value
1. `--bee or -b` requires a value
1. `--cee or -c` requires a value
1. `--dee or -d` is a switch
1. `-e` does not have a long form but requires a value

Generally It might be easier to directly call the maps which are pre-configured for you like in the example `main.sh` above. However, I'm not going to stop you from directly copying the content of the `parse-command-line.sh` into your script! Up to you how you want to use this code.
