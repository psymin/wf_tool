#!/bin/bash

# wf_tool.sh
#
# A tool for installing warfork servers in a uniform and repeatable manner
# LinuxGSM is far superior in every way, but this gets the job done


USERNAME="anonymous"	# Your steam username
PASSWORD=""		# Your steam password

APPID="1136510"		# The appid of the warfork server (this will change
			# in the future to a dedicated tool that can be fetched
			# anonymously
HOMEDIR=`eval echo ~$USER`
			# set the user's home dir to a variable
INSTALLDIR="${HOMEDIR}/warfork"
			# set INSTALLDIR to the explicit path you want
			# or leave default for /home/steamcmd/wf_server
PLATFORM="linux"	# Valid values are "windows" "macos" or "linux"
STEAMCMD="/usr/games/steamcmd"
UDP="44400"		# UDP port of the server
TCP="44444"		# TCP port of the server

#####
# functions
#####

os_version () {

  # in theory this variable can be set and used
  # to add support for more distros than just Ubuntu 18.04 LTS


  if [[ -f /etc/debian_version ]]
  then
    OS_VERSION=`cat /etc/debian_version`
  else
    OS_VERSION="unsupported"
  fi

}

os_version

wf_update () {

  if [[ -f ${INSTALLDIR}/steamapps/appmanifest_${APPID=}.acf ]]
  then

    BUILDID=`grep buildid ${INSTALLDIR}/steamapps/appmanifest_${APPID=}.acf | awk '{print $2}'` 
    REMOTEBUILDID=`${STEAMCMD} +@sSteamCmdForcePlatformType ${PLATFORM} +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login ${USERNAME} ${PASSWORD} +force_install_dir ${INSTALLDIR} +app_info_update 1 +app_info_print ${APPID} +quit | grep buildid | awk '{print $2}'`

    if [[ ${BUILDID} != ${REMOTEBUILDID} ]]
    then
      echo "Update necessary"
      echo "${BUILDID} != ${REMOTEBUILDID}"

      screen -S warfork -X stuff 'say server updating to latest steam build'$(echo -ne '\015')

      ${STEAMCMD} +@sSteamCmdForcePlatformType ${PLATFORM} +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login ${USERNAME} ${PASSWORD} +force_install_dir ${INSTALLDIR} +app_update ${APPID} validate +quit

      screen -S warfork -X stuff 'say update complete'$(echo -ne '\015')
      screen -S warfork -X stuff 'say manual server restrat required'$(echo -ne '\015')

    fi
  else

    echo "Warfork is not installed (${APPID})"
    echo "Install it with ./wf_tool.sh install"
  fi

}

wf_install () {

  ${STEAMCMD} +@sSteamCmdForcePlatformType ${PLATFORM} +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login ${USERNAME} ${PASSWORD} +force_install_dir ${INSTALLDIR} +app_update ${APPID} validate +quit

}

wf_start () {

  cd ${INSTALLDIR}/Warfork.app/Contents/Resources

  /usr/bin/screen -d -S "warfork" -m  ${INSTALLDIR}/Warfork.app/Contents/Resources/wf_server.x86_64

}

wf_setup () {

  ${STEAMCMD} +@sSteamCmdForcePlatformType ${PLATFORM} +login ${USERNAME} ${PASSWORD} +quit

}

wf_cron () {

  #Add a cronjob to the user to update and start server."
  CRON=`crontab -l`
  if [[ $CRON == "" ]]
  then
    echo "*/5 * * * * ${HOMEDIR}/wf_tool.sh update
@reboot ${HOMEDIR}/wf_tool.sh start" | /usr/bin/crontab
  else
    echo "crontab for your user is not empty"
    echo "manually set your crontab using crontab -e"
    echo
    echo "*/5 * * * * ${HOMEDIR}/wf_tool.sh update"
    echo "@reboot ${HOMEDIR}/wf_tool.sh start"
  fi

}

wf_status () {

  ps uwww -C wf_server.x86_64

  SCREENINFO=`screen -list warfork 2>/dev/null`

  echo
  echo screen info
  echo
  echo ${SCREENINFO}
  echo
  echo UDP info
  echo
  /bin/nc -vz -u localhost ${UDP}
  echo 
  echo TCP info
  echo
  /bin/nc -vz localhost ${TCP}


}

wf_tools () {

  case $OS_VERSION in
    buster/sid)
      sudo apt-get install steamcmd screen
      ;;
    unsupported)
      echo "OS unsupported at this time"
      ;;
    *)
      echo "Only Ubuntu 18.04 (buster/sid) is supported currently."
      echo "Your OS is ${OS_VERSION}"
  esac

}

wf_console () {

  echo "WARNING: to detach from this screen session you need to type CTRL-A D"
  echo "Hold the CTRL key and the D key, then press the A key."
  echo ""
  echo "CTRL-A D to exit the session without killing the server."
  echo ""
  echo -n "Sleeping for 10 seconds"
  for i in `seq 1 10`
  do
    sleep 1 && echo -n .
  done
  
  /usr/bin/screen -r warfork

}

wf_config () {

  cp ${INSTALLDIR}/Warfork.app/Contents/Resources/basewf/dedicated_autoexec.cfg ${HOMEDIR}/.local/share/warfork-2.1/basewf/dedicated_autoexec.cfg

}

wf_usage () {

  echo "Usage: ./wf_update.sh <command>"
  echo "-------------------------------"
  echo "Valid commands:"
  echo "start		(start the server)"
  echo "update		(update/install the server"
  echo "setup		(set up steamcmd for the first time"
  echo "cron		(add cronjob for updates and start on boot)"
  echo "tools		(install steamcmd and other tools)"
  echo "osupdate	(update the host operating system)"
  echo "status		(check status of service)"
  echo "stop		(stops the server)"
  echo "console		(attaches to the wf_server screen)"
  echo "everything	(does everything but start server)"


}

wf_stop () {

  screen -S warfork -X stuff 'quit'$(echo -ne '\015')

}

wf_osupdate () {

  case $OS_VERSION in
    buster/sid)
      sudo apt-get update
      sudo apt-get upgrade
      ;;
    unsupported)
      echo "OS unsupported at this time"
      ;;
    *)
      echo "Only Ubuntu 18.04 (buster/sid) is supported currently."
      echo "Your OS is ${OS_VERSION}"
  esac

}

wf_everything () {

  echo "Operating System Update"
  wf_osupdate
  echo "Tools install"
  wf_tools
  echo "First time setup for steamcmd"
  wf_setup
  echo "Warfork server fetch from steam"
  wf_install
  #echo "Starting the server"
  #wf_start
  #echo "Checking status of server"
  #wf_status
  #echo "Stopping server"
  #wf_stop

  # for some reason starting the server in this function fails

  echo "Adding cronjob for updates and starting on boot"
  wf_cron

  echo "#########################################"
  echo "#					#"
  echo "#  Your server should now be installed  #"
  echo "#  					#"
  echo "#########################################"
  echo
  echo "A default server config was installed here:"
  echo "${HOMEDIR}/.local/share/warfork-2.1/basewf/dedicated_autoexec.cfg"
  echo 
  echo "Edit that config (nano, vi, or copy it from your local machine)"
  echo
  echo "Start the server with ./wf_tool.sh start"
  echo
  echo "Verify status of the server with ./wf_tool.sh status"
  echo 
  echo "Stop the server with ./wf_tool.sh stop"
  echo
  echo "Ask for help on Discord https://discord.gg/VY95TKZ"
  echo 
}



case "$1" in
  start)
    wf_start
    ;;

  stop)
    wf_stop
    ;;

  update)
    wf_update
    ;;

  install)
    wf_install
    ;;

  setup)
    wf_setup
    ;;

  cron)
    wf_cron
    ;;

  boot)
    wf_boot
    ;;

  tools)
    wf_tools
    ;;

  osupdate)
    wf_osupdate
    ;;

  status)
    wf_status
    ;;

  console)
    wf_console
    ;;

  everything)
    wf_everything
    ;;

  *)
    wf_usage
    ;;

esac

