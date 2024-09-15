#!/bin/bash

# Set the default values for how the script will run

# These values are divided into three sections based on what part of the process they affect: 

# The first section deals with how the build script runs and interacts with the system you are running it on: the areas of the filesystem used, and output iso file
# The second section deals with how the live system iso will be built: root password, ssh access, OS release to use, inclusion of packages for offline install
# The third section deals with how the systems installed by the iso will be configured


# Section 1: Build script behavior

export runmode=interactive # Define how the script will run: interactive will prompt for values and walk through the options, non-interactive will run immediately using the default values or the values provided by the flags/options (string, set through opional script flag, valid options are interactive/noninteractive)

export workdir=/live-build # Set the directory that the script will work out of, this directory will be created by the script. The script will exit and fail if the directory already exists on the system (string, any valid filesystem path)

export keep_workdir=no # Tells the script to not delete the working directory when finshed (string, set through opional script flag, valid options are yes/no/Yes/No/YES/NO/y/n/Y/N/true/false/True/False/TRUE/FALSE/t/f/T/F)

export scriptdir="$(pwd)" # The directory containing the install script to be run by the live system iso, this defaults to your current directory and assumes that you are running the build script out the repo that also contains the install script (string, any valid filesystem path that contains the "install.sh" file)

export iso_target=~ # The directory to copy the completed live system iso to when finished, will be created if it does not already exist (string, any valid filesystem path)


# Section 2: Live system iso configuration

export codename=bookworm # Set OS release to build the live system with (string, any valid release codename for a Debian based Linux distribution as used in /etc/apt/sources.list)

export liverootpass=changeme # Set the root password for the live system to be built into an iso. The iso is configured to autologin as the root account to run the installation, so this will likely not need to be used unless opening a new tty (any string)

export scriptpath="/root/debian-custom-iso-builder" # Set the filesystem path on the live system to run the install script from (string, any valid filesystem path)

export offline=no # Configure the live system iso for offline installs. Downloads all packages needed for system installation to the live system iso and creates a local repository to install from instead of installing packages over the internet. Warning: using this option will greatly increase the iso size (string, set through opional script flag, valid options are yes/no/Yes/No/YES/NO/y/n/Y/N/true/false/True/False/TRUE/FALSE/t/f/T/F)

export use_wifi=no # Configure the live system iso to connect to a wifi ssid for system installation. (string, set through opional script flag for setting wifi ssid to connect to, valid options are yes/no/Yes/No/YES/NO/y/n/Y/N/true/false/True/False/TRUE/FALSE/t/f/T/F)

# Section 3: Installed system configuration

export rootpass=changeme # Set the root password for the installed system by the built iso, this is set through the bootloader aguments and is viewable by anyone booting the iso. This can be edited and changed when booting the built iso for additional security (any string)

export user=ansible # Set the account to be created for the installed system by the built iso, this is set through the bootloader aguments and is viewable by anyone booting the iso. This can be edited and changed when booting the built iso for additional security (string, valid Linux usernames only)

export userpass=changeme # Set the user password for the installed system by the built iso, this is set through the bootloader aguments and is viewable by anyone booting the iso. This can be edited and changed when booting the built iso for additional security (any string)

export user_sudo=no # Set elevated permissions for the account created for the installed system by the built iso, this is set through the bootloader aguments and is viewable by anyone booting the iso. This can be edited and changed when booting the built iso (string, valid options are yes/no/Yes/No/YES/NO/y/n/Y/N/true/false/True/False/TRUE/FALSE/t/f/T/F)

export encryptionpass=changeme # Set the disk encryption password for the installed system by the built iso, this is set through the bootloader aguments and is viewable by anyone booting the iso. This can be edited and changed when booting the built iso for additional security (any string)

die() { echo "$*" >&2; exit 2; }  # complain to STDERR and exit with error
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

while getopts n-:w:k-:d:t:c:l:s:f-:w:a:i-:r:u:p:o-:e:h- OPT; do
  # support long options: https://stackoverflow.com/a/28466267/519360
  if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$OPT" in
    n | noninteractive) 
      export runmode=noninteractive
    ;;
    w | workdir)
      needs_arg; export workdir="$OPTARG"
      ;;
    k | keep_workdir)
      export keep_workdir=yes
      ;;
    d | scriptdir)
      needs_arg; export scriptdir="$OPTARG"
      ;;
    t | iso_target)
      needs_arg; export iso_target="$OPTARG"
      ;;
    c | codename)
      needs_arg; export codename="$OPTARG"
      ;;
    l | liverootpass)
      needs_arg; export liverootpass="$OPTARG"
      ;;
    s | scriptpath)
      needs_arg; export scriptpath="$OPTARG"
      ;;
    f | offline)
      export offline=yes
      ;;
    w | wifi_ssid)
      needs_arg; export wifi_ssid="$OPTARG"
      ;;
    a | wifi_pass)
      needs_arg; export wifi_pass="$OPTARG"
      ;;
    i | hidden_network)
      export hidden_network=yes
      ;;
    r | rootpass)
      needs_arg; export liverootpass="$OPTARG"
      ;;
    u | user)
      needs_arg; export user="$OPTARG"
      ;;
    p | userpass)
      needs_arg; export user="$OPTARG"
      ;;
    o | user_sudo)
      export user_sudo=yes
      ;;
    e | encryptionpass)
      needs_arg; export encryptionpass="$OPTARG"
      ;;
    h | help)
cat << EOF >&2
script usage: 
./build.sh [options]

build script behavior:
[-n, --noninteractive]                   sets the build script to run
                                         non-interactively using the 
                                         options provided and not 
                                         prompting for further input
[-w, --workdir=</path/to/directory>]     directory that the script 
                                         will work out of, directory 
                                         will be created by script 
                                         (default: /live-build)
[-k, --keep_workdir]                     does not clean up and delete 
                                         the working directory 
[-s, --scriptdir=</path/to/directory>]   the directory containing the 
                                         install script to be run by 
                                         the live system iso, must 
                                         contain the file install.sh 
                                         (default: current directory)
[-t, --iso_target=</path/to/directory>]  the directory to copy the 
                                         live system iso to, will be
                                         created if it does not 
                                         already exist 
                                         (default: home directory)

live system iso configuration:
[-c, --codename=<release>]               the OS release to build the
                                         live system with, can use 
                                         any valid release codename 
                                         for a debian based system 
                                         (default: bookworm)
[-l, --liverootpass=<'any string'>]      root password for the live 
                                         system iso to be built 
                                         (default: changeme)
[-s, --scriptpath=</path/to/directory>]  the filesystem path on the 
                                         live system to find the 
                                         install script to run 
                                         (default: /root/debian-custom-iso-builder)
[-f, --offline]                          download all packages needed
                                         for systems installed by the
                                         iso to allow for offline 
                                         installations, warning: 
                                         this will greatly increase 
                                         the iso size 
                                         (default behavior: install 
                                         packages over the internet)
[-w, --wifi_ssid=<ssid>]                 have the live system connect
                                         to a wifi ssid for installs
                                         (default: unset, does not 
                                         connect to wifi)
[-a, --wifi_pass=<'wifi password']       password of the wifi ssid 
                                         to connect to 
                                         (default: unset, does not 
                                         connect to wifi)
[-i, --hidden]                           connect to hidden wifi ssid 
                                         (default: unset, does not 
                                         connect to wifi)

installed system configuration
[-r, --rootpass=<'any string'>]          root password for installed
                                         systems (default: changeme)
[-u, --user=<username>]                  user account for installed
                                         systems (default: ansible)
[-p, --userpass=<'any string'>]          user password for installed
                                         systems (default: changeme)
[-o, --user_sudo]                        adds the user account
                                         created to the sudo group
[-e, --encryptionpass=<'any string'>]    encryption password for 
                                         installed systems
                                         (default: changeme)
[-h, --help]                             print usage options
EOF
      exit 1
      ;;
    \? ) # bad short option (error reported via getopts)
      echo "Use -h or --help for valid script options"         
      exit 2
      ;;  
    * )
      echo "Use -h or --help for valid script options"            
      die "Illegal option --$OPT" # bad long option
      ;;            
  esac
done

shift $((OPTIND-1)) # remove parsed options and args from $@ list

export tempmount="$workdir/chroot"

export DEBIAN_FRONTEND=noninteractive

export LC_ALL=C

