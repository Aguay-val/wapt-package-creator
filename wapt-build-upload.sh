#!/bin/bash
#set -x
#trap read debug

cmdname=`basename "$0"`
regex="\((.*)\)\s=\s(.*)"
PRIVATE_KEY=
WAPT_URL=""
CONTROL_VALUE="package version architecture section priority maintainer description depends sources"
URL_WAPT_PSPROJ="https://raw.githubusercontent.com/tranquilit/WAPT/master/templates/wapt.psproj"


#
##
## Functions
##
##########################################################################
wapt_package_creator_usage()
{
echo "Usage:  ${cmdname} -k <key>  -u <url> -l <user> -p <password>"
echo ""
echo "  options:"
echo ""
echo "    -k                   Key to sign package."
echo "    --key"
echo ""
echo "    -u url          WAPT Server URL"
echo "    --url url"
echo ""
echo "    -l login     Login to connect to wapt server."
echo "    --login login"
echo ""
echo "    -p password    password to login wapt server."
echo "    --password password "
echo ""
echo "  Examples:"
echo ""
echo "  Run to localhost wapt server."
echo ""
echo "    ${cmdname} -k path_to_key.pem -u admin -p"
echo "     Password:"
echo ""
echo "  Run to custom server"
echo ""
echo "    ${cmdname} -k path_to_key.pem -u admin -p -u wapt.domain.tld"
echo "    Password:"
echo ""
echo ""
exit 0
}

######################################################################
list_files_directory() {
    find "${PWD}" -type f -printf '%P\n'
}

######################################################################
create_manifest_sha1() {
  printf "[\n"
  lines=""
  while read lines
  do
    line="$(sha1sum --tag "${lines}")"
    if ! [ -z "$line" ]; then
      if [[ ! $line =~ .*manifest.* && ! $line =~ .*signature.* && $line =~ $regex ]]; then
        # Print le pattern pour le fichier manifest.sha1
        # 1er boc : ${BASH_REMATCH[1]//\//\\\\}
        # On récupère le premier groupe de la regex et on remplace "/" par "\\"
        # Puis print dans le premier %s
        # 2em bloc : ${BASH_REMATCH[2]}
        # Juste print dans le deuxième %s
        printf " [\n \"%s\",\n \"%s\"\n ],\n" "${BASH_REMATCH[1]//\//\\\\}" "${BASH_REMATCH[2]}"
      fi
    fi
  done < "${TEMP_FILE}"
  printf "]"
  ## On enlève la virgule à l'avant dernière ligne.
  sed -ni "x;${s/,$//;p;x}; 2,$ p" WAPT/manifest.sha1
  unset lines
}

######################################################################
get_control_value () {
  if [[ -f WAPT/control ]]; then
    for key in $CONTROL_VALUE
    do
      regex_get_control_value="(^${key})\s+:\s(.*)"
      while  read lines
      do
        if ! [ -z "$lines" ]; then
          if [[ $lines =~ $regex_get_control_value ]]; then
            export declare PACKAGE_"${key}"="${BASH_REMATCH[2]}"
          fi
        fi
      done < WAPT/control
      unset lines
      done
    else
      echo "Error, file ${PWD}/WAPT/control does not exist"
      return
  fi
}

######################################################################
sign_manifest () {

  openssl dgst -sha1 -sign ${PRIVATE_KEY}  WAPT/manifest.sha1 | base64
}

######################################################################
zip_to_wapt () {

  zip -r "${PACKAGE_package}_${PACKAGE_version}_${PACKAGE_architecture}".wapt .
}

######################################################################
upload_package () {

  curl -X POST "https://${WAPT_URL}/upload_package/${1}.wapt" -F file=@"${1}".wapt -H "Authorization: Basic ${AUTH_TOKEN}"
}

######################################################################P
ask_password () {
  read -s -p "Password: " mypassword
}

######################################################################P
create_http_token () {
  export AUTH_TOKEN=$(printf "%s:%s" ${wapt_user} ${mypassword} | base64)
}

######################################################################P
control_file_gen () {
  # Init Default Var
  PACKAGE_package=""
  PACKAGE_version=""
  PACKAGE_architecture="all"
  PACKAGE_section="base"
  PACKAGE_priority="optional"
  PACKAGE_maintainer="$(id -n -u)"
  PACKAGE_description="A pretty and enhanced Description for ${PACKAGE_package}"
  PACKAGE_depends=""
  PACKAGE_sources=""
  get_control_value

  for value in $CONTROL_VALUE
    do
      current_var=PACKAGE_${value}
      read -p "Is \"PACKAGE_$value = ${!current_var}\" is right (y/n)? : " answer
    if [[ $answer =~ [nN] ]]; then # Test if var is empty
      read -p "What is the correct value for PACKAGE_value (before : ${!current_var}) " PACKAGE_${value}
      printf "New Value :\t %s => %s\n" PACKAGE_$value "${!current_var}"
    fi
  done
  printf "Resume :\n\n"
  printf "package      : ${PACKAGE_package}\nversion      : ${PACKAGE_version}\narchitecture : ${PACKAGE_architecture}\nsection      : ${PACKAGE_section}\npriority     : ${PACKAGE_priority}\nmaintainer   : ${PACKAGE_maintainer}\ndescription  : ${PACKAGE_description}\ndepends      : ${PACKAGE_depends}\nsources      : ${PACKAGE_sources}\n" | tee WAPT/control
  unset answer
  unset current_var
}


############ MAIN ###############
TEMP_FILE=$(mktemp /tmp/wapt.XXXX)


while [ $# -gt 0 ]
do
  case $1 in
    -k | --key)
      PRIVATE_KEY="${2}";
      shift
      ;;
    -u | --url)
      WAPT_URL=${2};
      shift
      ;;
    -l | --login)
      wapt_user=${2};
      shift
      ;;
    -p | --password)
    ask_password;
    shift
      ;;
		-h | --help)
		wapt_package_creator_usage;
		break
			;;
    *)
    shift
      ;;
  esac
done

create_http_token
# Vérification du dossier en cours
if [ ! -e setup.py ]; then
  printf "Error! Missing \"setup.py\"\nAre you in the wapt-package folder ?\n"
  echo "--------------------------------------------------------"
  echo "Current Folder : ${PWD}"
  echo "--------------------------------------------------------"
  read -p "Is this the right path ? (y/n) : " answer
  if [[ $answer =~ [nN] ]]; then
    read -p  "What is the correct path ? (press enter when finish): " package_path
    cd ${package_path}
    ls
  fi
fi
# Vérification de l'état du fichier "control" et si il n'est pas bon alors on le génère.
if [ -e WAPT/control ]; then
  if [ "`cat WAPT/control | wc -l`" -lt "9" ]; then
    control_file_gen
    else
    printf "Printing  WAPT/control\n"
    echo "--------------------------------------------------------"
    cat  WAPT/control
    echo "--------------------------------------------------------"
    read -p "Is the content of WAPT/control ok? (y/n) : " answer
    if [[ $answer =~ [nN] ]]; then # Test if var is empty
      control_file_gen
    else
      get_control_value
    fi
  fi
else
  control_file_gen
fi

# If there is not wapt.psproj file then download it from github repo
if [ ! -e WAPT/wapt.psproj ]; then
  wget ${URL_WAPT_PSPROJ} -o WAPT/wapt.psproj
fi
printf "\n List files from the directory\n"
list_files_directory | tee  "${TEMP_FILE}"
printf "\n Creation of \"manifest.sha1\"\n"
create_manifest_sha1 > WAPT/manifest.sha1
sed -i 'x; ${s/,//;p;x}; 1d' WAPT/manifest.sha1
printf "\n File signature of manifest.sha1 with ${PRIVATE_KEY}\n"
sign_manifest > WAPT/signature
printf "\n Zipping folder as <wapt>.wapt\n"
zip_to_wapt
upload_package "${PACKAGE_package}_${PACKAGE_version}_${PACKAGE_architecture}"
rm -f "${TEMP_FILE}"

printf "\n Package have been build and uploaded \n \n"
