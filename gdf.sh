#!/bin/bash
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# gdf is a bash script that displays disk usage using text graphics
# 
# Written by Silviu Vulcan - http://www.silviuvulcan.ro/


WDTH=80         # fixing width in case tput is missing
MPMAX=1         # get the longest mount point name

function repeat {
    if [ "$1" == "SP" ]; then 
        for ((i=0;i<$2;++i)); do echo -n " " ; done
    else 
        for ((i=0;i<$2;++i)); do echo -n $1 ; done
    fi

}

if [ `command -v tput` ]; then
    WDTH=$(`command -v tput` cols)
fi

# get the longest mountpoint, horrible
while read LINE; do
    MPNT=$(echo $LINE | awk '{print $6}')
    if [ ${#MPNT} -gt "$MPMAX" ]; then
        MPMAX=${#MPNT}
    fi
done < <(df -h | sed 1d)

while read LINE; do
    FS=$(echo $LINE | awk '{print $1}')
    USE=$(echo $LINE | awk '{print $5}' | awk -F\% '{print $1}')
    MPNT=$(echo $LINE | awk '{print $6}')

#    if [ $MPNT == "/" ]; then                  # used to debug
#       USE=100
#    fi

    BARWDTH=$(( WDTH-4-5-MPMAX ))
    SHARP=$(( USE*BARWDTH/100 ))

    echo -n $MPNT
    repeat SP $(( $MPMAX-${#MPNT} ))
    echo -n " ["                                # 2 chars from start
    repeat \# $SHARP
    repeat \- $(( BARWDTH-SHARP ))
    echo -n "] "                                # 2 chars from end
    repeat SP $(( 3-${#USE} ))                  # rigt align
    echo -n "$USE% "                            # max 5 chars on 100%
    echo -ne "\n"                               # done
done < <(df -h | sed 1d)
