if [ -n "$BASH_VERSION" ]; then
  if [ -f $HOME/.bashrc ]; then
    source $HOME/.bashrc
  fi
fi

if [ -f $HOME/.profile ]; then
  source $HOME/.profile
fi

if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# get current branch in git repo
function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    echo "[${BRANCH}${STAT}]"
  else
    echo ""
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}

test -f ~/.git-completion.bash && . $_

# use either \[...\] or \001...\002 for non-printable sequences
red="\[\e[1;31m\]"
green="\[\e[36m\]"
blue="\[\e[34m\]"
grey="\[\e[1;33m\]"
reset="\[\e[m\]"  # reset between colour changes

PS1="$red\u@\h$reset" # user@host
PS1+="$green\w$reset" # workingdir
PS1+="$blue\`parse_git_branch\`$reset" # git branch
PS1+="$grey\\$ $reset" # dollar sign + space

export PS1
unset red green blue grey reset

ext () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.tar.xz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
       if [ $2 == 'd' ] ; then
           rm -rf $1
       fi 
   else
       echo "'$1' is not a valid file!"
   fi
}

alias izi_ser_h57="JLinkGDBServer -device STM32H573II"
alias izi_gdb_h57="arm-none-eabi-gdb -d STM32H573II"
alias izi_flash_h57='python3 $HOME/Workplace/application/mcu/scripts/tools/icuflash.py -d STM32H573II' 

alias izi_ser_h56="JLinkGDBServer -device STM32H563ZI"
alias izi_gdb_h56="arm-none-eabi-gdb -d STM32H563ZI"
alias izi_flash_h56='python3 $HOME/Workplace/application/mcu/scripts/tools/icuflash.py -d STM32H563ZI' 

alias izi_ser_h7="JLinkGDBServer -device STM32H753II"
alias izi_gdb_h7="arm-none-eabi-gdb -d STM32H753II"
alias izi_flash_h7='python3 $HOME/Workplace/application/mcu/scripts/tools/icuflash.py -d STM32H753II' 



if [ "$(uname)" == "Darwin" ]; then
  export CCACHE_CPP2=yes       
  export CCACHE_SLOPPINESS=time_macros
  export PATH=/usr/local/opt/ccache/libexec:$PATH
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  alias xclip="xclip -selection c"
  alias xpaste="xclip -selection clipboard -o"
  #export PATH=/usr/lib/ccache:$PATH
  export PATH=$HOME/software/dtc-1.6.0:$PATH
  source $HOME/software/git-subrepo/.rc
  alias vncset="sudo x11vnc -usepw -auth /var/lib/lightdm/.Xauthority -display :0"
  alias vncres="sudo xrandr --newmode '2560x1440_75.00'  397.25  2560 2760 3040 3520  1440 1443 1448 1506 -hsync +vsync && sudo xrandr --addmode VGA-1 2560x1440_75.00 && xrandr --output VGA-1 --mode '2560x1440_75.00'"
fi




# Work Related Stuff

#### Generic build alias'
# Clean
alias sbc='rm -rf build'
# Build all (pre mono-repo)
alias sbap='mkdir build && cd build && ../cbt/cbt.py ../ && cmake . -GNinja && ninja'
# Build
alias sbb='ninja'

#### Mcu Update Tool Coombs
alias sbupc='mkdir build && cd build && ../cbt/cbt.py ../ && cmake . -DHOST_RUNTIME_PACKAGING_CMAKE_ARGS="-DINTERNAL_RELEASE=ON" -DGRAPHCORE_TARGET_ACCESS_CMAKE_ARGS="-DINTERNAL_RELEASE=ON" -DMCU_UPDATE_TOOL_CMAKE_ARGS="-DTEST_MODE" -GNinja && ninja'

#### Host runtime
alias sbgcda='mkdir build && cd build && ../cbt/cbt.py ../ && cmake . -DHOST_RUNTIME_PACKAGING_CMAKE_ARGS="-DINTERNAL_RELEASE=ON;-DDO_PACKAGING=ON;-DSWDB_PACKAGE_NAME=ubuntu_18_04_internal_installer" -DGRAPHCORE_TARGET_ACCESS_CMAKE_ARGS="-DINTERNAL_RELEASE=ON"  -GNinja && ninja'

#### Flashing
alias sbfh7='python3 $HOME/application/mcu_view/mcu/scripts/tools/icuflash.py -d STM32H753II' 
alias sbff4='python3 $HOME/application/mcu_view/mcu/scripts/tools/icuflash.py' 

if ! [ "$(uname)" == "Darwin" ]; then
  if [ -d $HOME/drivers/default ]; then
    source $HOME/drivers/default/enable.sh
#    export PYTHONPATH=$HOME/drivers/default/lib/python/
#    export GCDA_LOGGING=1
  fi
fi

### Connect to server
export dev1="gbbrspswemb001.eng.graphcore.ai"
export dev3="gbbrspswemb003.eng.graphcore.ai"
export dev5="gbbrspswemb005.eng.graphcore.ai"
export dev7="gbbrspswemb007.eng.graphcore.ai"
export dev8="gbbrspswemb008.eng.graphcore.ai"
export dev24="hwlab24.eng.graphcore.ai"
export dev25="hwlab25.eng.graphcore.ai"
export dev26="hwlab26.eng.graphcore.ai"
export dev33="hwlab33.eng.graphcore.ai"

### Scp to server
export gb1u="colinm@10.0.128.148:/home/colinm"
export gb1="colinm@gbbrspswemb001.eng.graphcore.ai:/home/colinm"
export gb3="colinm@gbbrspswemb003.eng.graphcore.ai:/home/colinm"
export gb5="colinm@gbbrspswemb005.eng.graphcore.ai:/home/colinm"
export gb7="colinm@gbbrspswemb007.eng.graphcore.ai:/home/colinm"
export gb8="colinm@gbbrspswemb008.eng.graphcore.ai:/home/colinm"
export gb24="colinm@hwlab24.eng.graphcore.ai:/home/colinm"
export gb25="colinm@hwlab25.eng.graphcore.ai:/home/colinm"
export gb26="colinm@hwlab26.eng.graphcore.ai:/home/colinm"
export gb33="colinm@hwlab33.eng.graphcore.ai:/home/colinm"


alias gdbserverf4="JLinkGDBServer -device STM32F446ZE"
alias gdbserverh7="JLinkGDBServer -device STM32H753II"
alias gdbremote="JLinkRemoteServerCLExe -Port 19020"

if [ "$(uname)" == "Darwin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  PATH="/opt/homebrew/bin:$PATH"
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  PATH="/Applications/STMicroelectronics/STM32CubeProgrammer/STM32TrustedPackageCreator.app/Contents/MacOs/bin:$PATH"
  PATH="/Applications/STMicroelectronics/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin:$PATH"
  PATH="/Applications/STMicroelectronics/STM32CubeProgrammer/STM32TrustedPackageCreator.app/Contents/MacOs/bin/Utilities/Mac:$PATH"
  PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  alias view_update="$HOME/application/view/view.py update"
  alias view_force="$HOME/application/view/view.py checkout --force HEAD"
  alias thumprun="cd $HOME/application/thumper/colossus-characterisation.internal.0.0.32-84a2569b9d/colossus-characterisation/tests/thumper/src && ae-env ae-run --elf obj/ipu2/thumper.elf --power-meas 1 --device-id 3 --param w_comp_prda_load0_kernel=66 --params-csv configs/power_sweep.csv"
  alias clkwatch0="watch -n 1 'cat /sys/bus/pci/drivers/ipu/0000\:af\:00.0/tile_clk_speed'"
  alias clkwatch1="watch -n 1 'cat /sys/bus/pci/drivers/ipu/0000\:b0\:00.0/tile_clk_speed'"
fi

export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin

