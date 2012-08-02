#!/bin/bash
#
# createapp.sh
#
#   tasks:   
#       - creates app bundle for Python morinus script
#       - creates dmg volume for distribution
#
#   options:
#       -- clean    cleanes the distribution files
#       -- create   creates the distribution
#
# Created by Vasek (vaclav@spirhanzl.cz) on 2012-07-13.
# Based on bash script template from halfgaar 
#       http://blog.bigsmoke.us/2011/01/05/bash-script-template
#

#
# set -n # Uncomment to check script syntax, without execution.
# set -x # Uncomment to debug this shell script
#
 
# Error codes
wrong_params=5
interrupted=99
default_error=1
 
# Function to echo in color. Don't supply color for normal color.
echo_color()
{
  message="$1"
  color="$2"
 
  red_begin="\033[01;31m"
  green_begin="\033[01;32m"
  yellow_begin="\033[01;33m"
  color_end="\033[00m"
 
  # Set color to normal when there is no color
  [ ! "$color" ] && color_begin="$color_end"
 
  if [ "$color" == "red" ]; then
    color_begin="$red_begin"
  fi
 
  if [ "$color" == "green" ]; then
    color_begin="$green_begin"
  fi
 
  if [ "$color" == "yellow" ]; then
    color_begin="$yellow_begin"
  fi
 
  echo -e "$color_begin" "$message" "$color_end"
}
 
end()
{
  message="$1"
  exit_status="$2"
 
  if [ -z "$exit_status" ]; then
    exit_status="0"
  fi
 
  if [ ! "$exit_status" -eq "0" ]; then
    echo_color "$message" "red"
  else
    echo_color "$message" "green"
  fi
 
  if [ "$exit_status" -eq "$wrong_params" ]; then
    dohelp
  fi
 
  exit $exit_status
}
 
# Define function to call when SIGTERM is received
#   1 - Terminal line hangup
#   2 - Interrupt program
#   3 - Quit program
#  15 - Software termination signal
trap "end 'Interrupted' $interrupted" 1 2 3 15
 
dohelp()
{
  echo ""
  echo "createapp script"
  echo ""
  echo "    creates app bundle for morinus python script"
  echo ""
  echo "    options:"
  echo "       -- clean    cleanes the distribution files"
  echo "       -- create   creates the distribution"
  echo "       -- help     displays help"
  echo "       -- revision revision number"
  echo "       -- rev      revision number"
  echo ""
  echo "    examples:"
  echo "        createapp --create --rev 6.2.0"
  echo "            creates app bundle with revision number 6.2.0"
  echo ""
 
}

doclean()
{
  # clean distribution
  echo "--> cleaning distribution files ..."
  # python setup.py clean
  rm -rfd build dist
}

# options check
prev_params=$* 
while [ -n "$*" ]; do
  flag=$1
  value=$2
 
  case "$flag" in
    "--help")
      dohelp
      exit
    ;;
    "--clean")
      doclean
      exit
    ;;
    "--create")
      opt_create="1"
    ;;
    "--revision" | "--rev")
      opt_revision="$value"
      shift
    ;;
    "--")
      break
    ;;
    *)
      end "unknown option $flag. Type --help" "$wrong_params"
    ;;
  esac
 
  shift
done
 
if [ -z "$opt_create" ]; then
  end "--create or --clean not given" $wrong_params
fi

if [ "$opt_revision" == "" ]; then
  end "no revision value given" $wrong_params
fi

echo "--> creates distribution, revision: $opt_revision"

#
#   --- start of main script ---
#

# here is my invention :-)
if [ ! -f "./setup.py" ]; then
    end "File setup.py does not exist in current working directory" 1
fi


# build distribution
echo "--> setup.py with params = $prev_params"
python setup.py py2app

# copy Python frameworks - dirty hack :-)
echo ""
echo "--> copying Python.framework ..."
cp -Rv /Projects/Frameworks/Python.framework dist/morinus.app/Contents/Frameworks

# rename App bundle
mv dist/morinus.app dist/Morinus.app