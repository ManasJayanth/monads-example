
#!/bin/bash

set -e
set -u

BOLD=`tput bold`  || BOLD=''   # Select bold mode
BLACK=`tput setaf 0` || BLACK=''
RED=`tput setaf 1` || RED=''
GREEN=`tput setaf 2` || GREEN=''
YELLOW=`tput setaf 3` || YELLOW=''
RESET=`tput sgr0` || RESET=''

MODE="update"

# On Windows, the 'esy pesy' syntax doesn't work as we want it to -
# our bash environment there is always run with 'noprofile',
# so 'pesy' always runs in build mode instead of update mode.

# To make this command work cross-platform, we add a way to override
# the mode via the 'PESY_MODE' environment variable.

set +u
if [ ! -z "${PESY_MODE}" ]; then
  printf "PESY MODE"
  MODE="$PESY_MODE"
else 
  if [[ $SHELL =~ "noprofile" ]]; then
    MODE="build"
  fi
fi
set -u

LAST_EXE_NAME=""
NOTIFIED_USER="false"
BUILD_STALE_PROBLEM="false"

DEFAULT_MAIN_MODULE_NAME="Index"

function notifyUser() {
  if [ "${NOTIFIED_USER}" == "false" ]; then
    echo ""
    if [ "${MODE}" == "build" ]; then
      printf "  %sAlmost there!%s %sWe just need to prepare a couple of files:%s\\n\\n" "${YELLOW}${BOLD}" "${RESET}" "${BOLD}" "${RESET}"
    else
      printf "  %sPreparing for build:%s\\n\\n" "${YELLOW}${BOLD}" "${RESET}"
    fi
    NOTIFIED_USER="true"
  else
    # do nothing
    true
  fi
}


function printDirectory() {
  DIR=$1
  NAME=$2
  NAMESPACE=$3
  REQUIRE=$4
  IS_LAST=$5
  printf "│\\n"
  PREFIX=""
  if [[ "$IS_LAST" == "last" ]]; then
    printf "└─%s/\\n" "$DIR"
    PREFIX="    "
  else
    printf "├─%s/\\n" "$DIR"
    PREFIX="│   "
  fi
  printf "%s%s\\n" "$PREFIX" "$NAME"
  printf "%s%s\\n" "$PREFIX" "$NAMESPACE"
  if [ -z "$REQUIRE" ]; then
    true
  else
    if [ "$REQUIRE" != " " ]; then
      printf   "%s%s\\n" "$PREFIX" "$REQUIRE"
    fi
  fi
}
PACKAGE_NAME="monads"
PACKAGE_NAME_UPPER_CAMEL="Monads"
NAMESPACE="Monads"
PUBLIC_LIB_NAME="monads.lib"
Executable_NAMESPACE="HEY! You Need To Specify a nameSpace: field for executable"
Executable_INCLUDESUBDIRS=""
#Default Requires
Executable_REQUIRE=""
#Default Flags
Executable_FLAGS=""
Executable_IGNOREDSUBDIRS=""
Executable_OCAMLC_FLAGS=""
Executable_OCAMLOPT_FLAGS=""
Executable_PREPROCESS=""
Executable_C_NAMES=""
Executable_JSOO_FLAGS=""
Executable_JSOO_FILES=""
Executable_IMPLEMENTS=""
Executable_VIRTUALMODULES=""
Executable_RAWBUILDCONFIG=""
Executable_RAWBUILDCONFIGFOOTER=""
Executable_MODES=""
Executable_WRAPPED=""
#Default Namespace
Library_NAMESPACE="Monads"
Library_INCLUDESUBDIRS=""
#Default Requires
Library_REQUIRE=""
#Default Flags
Library_FLAGS=""
Library_IGNOREDSUBDIRS=""
Library_OCAMLC_FLAGS=""
Library_OCAMLOPT_FLAGS=""
Library_PREPROCESS=""
Library_C_NAMES=""
Library_JSOO_FLAGS=""
Library_JSOO_FILES=""
Library_IMPLEMENTS=""
Library_VIRTUALMODULES=""
Library_RAWBUILDCONFIG=""
Library_RAWBUILDCONFIGFOOTER=""
Library_MODES=""
Library_WRAPPED=""
Test_REQUIRE=" monads/library rely.lib "
Executable_REQUIRE=" monads/library "
[ "${MODE}" != "build" ] && 
printDirectory "executable" "name:    Monads.exe" "main:    ${Executable_MAIN_MODULE:-$DEFAULT_MAIN_MODULE_NAME}" "require:$Executable_REQUIRE" not-last
[ "${MODE}" != "build" ] && 
printDirectory "library" "library name: monads.lib" "namespace:    $Library_NAMESPACE" "require:     $Library_REQUIRE" last
BIN_DIR="${cur__root}/executable"
BIN_DUNE_FILE="${BIN_DIR}/dune"
# FOR BINARY IN DIRECTORY Executable
Executable_MAIN_MODULE="${Executable_MAIN_MODULE:-$DEFAULT_MAIN_MODULE_NAME}"

Executable_MAIN_MODULE_NAME="${Executable_MAIN_MODULE%%.*}"
# https://stackoverflow.com/a/965072
if [ "$Executable_MAIN_MODULE_NAME"=="$Executable_MAIN_MODULE" ]; then
  # If they did not specify an extension, we'll assume it is .re
  Executable_MAIN_MODULE_FILENAME="${Executable_MAIN_MODULE}.re"
else
  Executable_MAIN_MODULE_FILENAME="${Executable_MAIN_MODULE}"
fi

if [ -f  "${BIN_DIR}/${Executable_MAIN_MODULE_FILENAME}" ]; then
  true
else
  BUILD_STALE_PROBLEM="true"
  notifyUser
  echo ""
  if [ "${MODE}" == "build" ]; then
    printf "    □  Generate %s main module\\n" "${Executable_MAIN_MODULE_FILENAME}"
  else
    printf "    %s☒%s  Generate %s main module\\n" "${BOLD}${GREEN}" "${RESET}" "${Executable_MAIN_MODULE_FILENAME}"
    mkdir -p "${BIN_DIR}"
    printf "print_endline(\"Hello!\");" > "${BIN_DIR}/${Executable_MAIN_MODULE_FILENAME}"
  fi
fi

if [ -d "${BIN_DIR}" ]; then
  LAST_EXE_NAME="Monads.exe"
  BIN_DUNE_EXISTING_CONTENTS=""
  if [ -f "${BIN_DUNE_FILE}" ]; then
    BIN_DUNE_EXISTING_CONTENTS=$(<"${BIN_DUNE_FILE}")
  else
    BIN_DUNE_EXISTING_CONTENTS=""
  fi
  BIN_DUNE_CONTENTS=""
  BIN_DUNE_CONTENTS=$(printf "%s\\n%s" "${BIN_DUNE_CONTENTS}" "; !!!! This dune file is generated from the package.json file by pesy. If you modify it by hand")
  BIN_DUNE_CONTENTS=$(printf "%s\\n%s" "${BIN_DUNE_CONTENTS}" "; !!!! your changes will be undone! Instead, edit the package.json and then rerun 'esy pesy' at the project root.")
  BIN_DUNE_CONTENTS=$(printf "%s\\n%s %s" "${BIN_DUNE_CONTENTS}" "; !!!! If you want to stop using pesy and manage this file by hand, change pacakge.json's 'esy.build' command to: refmterr dune build -p " "${cur__name}")
  BIN_DUNE_CONTENTS=$(printf "%s\\n%s" "${BIN_DUNE_CONTENTS}" "(executable")
  BIN_DUNE_CONTENTS=$(printf "%s\\n %s" "${BIN_DUNE_CONTENTS}" "  ; The entrypoint module")
  BIN_DUNE_CONTENTS=$(printf "%s\\n %s" "${BIN_DUNE_CONTENTS}" "  (name ${Executable_MAIN_MODULE_NAME})  ;  From package.json main field")
  BIN_DUNE_CONTENTS=$(printf "%s\\n %s" "${BIN_DUNE_CONTENTS}" "  ; The name of the executable (runnable via esy x Monads.exe) ")
  BIN_DUNE_CONTENTS=$(printf "%s\\n %s" "${BIN_DUNE_CONTENTS}" "  (public_name Monads.exe)  ;  From package.json name field")

  if [ -z "${Executable_JSOO_FLAGS}" ] && [ -z "${Executable_JSOO_FILES}" ]; then
    # No jsoo flags whatsoever
    true
  else
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s" "${BIN_DUNE_CONTENTS}" "  (js_of_ocaml ")
    if [ ! -z "${Executable_JSOO_FLAGS}" ]; then
      BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "    (flags (${Executable_JSOO_FLAGS}))  ; From package.json jsooFlags field")
    fi
    if [ ! -z "${Executable_JSOO_FILES}" ]; then
      BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "    (javascript_files ${Executable_JSOO_FILES})  ; From package.json jsooFiles field")
    fi
    BIN_DUNE_CONTENTS=$(printf "%s\\n%s" "${BIN_DUNE_CONTENTS}" "   )")
  fi
  if [ ! -z "${Executable_REQUIRE}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  (libraries ${Executable_REQUIRE}) ;  From package.json require field (array of strings)")
  fi
  if [ ! -z "${Executable_FLAGS}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  (flags (${Executable_FLAGS})) ;  From package.json flags field")
  fi
  if [ ! -z "${Executable_OCAMLC_FLAGS}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  (ocamlc_flags (${Executable_OCAMLC_FLAGS}))  ; From package.json ocamlcFlags field")
  fi
  if [ ! -z "${Executable_OCAMLOPT_FLAGS}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  (ocamlopt_flags (${Executable_OCAMLOPT_FLAGS}))  ; From package.json ocamloptFlags field")
  fi
  if [ ! -z "${Executable_MODES}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  (modes (${Executable_MODES}))  ; From package.json modes field")
  fi
  if [ ! -z "${Executable_RAWBUILDCONFIG}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  ${Executable_RAWBUILDCONFIG} ")
  fi
  if [ ! -z "${Executable_PREPROCESS}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "  (preprocess (${Executable_PREPROCESS}))  ; From package.json preprocess field")
  fi
  BIN_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${BIN_DUNE_CONTENTS}" ")")
  if [ ! -z "${Executable_IGNOREDSUBDIRS}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${BIN_DUNE_CONTENTS}" "(ignored_subdirs (${Executable_IGNOREDSUBDIRS})) ;  From package.json ignoredSubdirs field")
  fi
  if [ ! -z "${Executable_INCLUDESUBDIRS}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${BIN_DUNE_CONTENTS}" "(include_subdirs ${Executable_INCLUDESUBDIRS}) ;  From package.json includeSubdirs field")
  fi

  if [ ! -z "${Executable_RAWBUILDCONFIGFOOTER}" ]; then
    BIN_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${BIN_DUNE_CONTENTS}" "${Executable_RAWBUILDCONFIGFOOTER}")
  fi

  if [ "${BIN_DUNE_EXISTING_CONTENTS}" == "${BIN_DUNE_CONTENTS}" ]; then
    true
  else
    notifyUser
    BUILD_STALE_PROBLEM="true"
    if [ "${MODE}" == "build" ]; then
      printf "    □  Update executable/dune build config\\n"
    else
      printf "    %s☒%s  Update executable/dune build config\\n" "${BOLD}${GREEN}" "${RESET}"
      printf "%s" "${BIN_DUNE_CONTENTS}" > "${BIN_DUNE_FILE}"
      mkdir -p "${BIN_DIR}"
    fi
  fi
else
  BUILD_STALE_PROBLEM="true"
  notifyUser
  if [ "${MODE}" == "build" ]; then
    printf "    □  Generate missing the executable directory described in package.json buildDirs\\n"
  else
    printf "    %s☒%s  Generate missing the executable directory described in package.json buildDirs\\n" "${BOLD}${GREEN}" "${RESET}"
    mkdir -p "${BIN_DIR}"
  fi
fi

# Perform validation:

LIB_DIR="${cur__root}/library"
LIB_DUNE_FILE="${LIB_DIR}/dune"

# TODO: Error if there are multiple libraries all using the default namespace.
if [ -d "${LIB_DIR}" ]; then
  true
else
  BUILD_STALE_PROBLEM="true"
  notifyUser
  if [ "${MODE}" == "build" ]; then
    printf "    □  Your project is missing the library directory described in package.json buildDirs\\n"
  else
    printf "    %s☒%s  Your project is missing the library directory described in package.json buildDirs\\n" "${BOLD}${GREEN}" "${RESET}"
    mkdir -p "${LIB_DIR}"
  fi
fi

LIB_DUNE_CONTENTS=""
LIB_DUNE_EXISTING_CONTENTS=""
if [ -f "${LIB_DUNE_FILE}" ]; then
  LIB_DUNE_EXISTING_CONTENTS=$(<"${LIB_DUNE_FILE}")
fi
LIB_DUNE_CONTENTS=$(printf "%s\\n%s" "${LIB_DUNE_CONTENTS}" "; !!!! This dune file is generated from the package.json file by pesy. If you modify it by hand")
LIB_DUNE_CONTENTS=$(printf "%s\\n%s" "${LIB_DUNE_CONTENTS}" "; !!!! your changes will be undone! Instead, edit the package.json and then rerun 'esy pesy' at the project root.")
LIB_DUNE_CONTENTS=$(printf "%s\\n%s %s" "${LIB_DUNE_CONTENTS}" "; !!!! If you want to stop using pesy and manage this file by hand, change pacakge.json's 'esy.build' command to: refmterr dune build -p " "${cur__name}")
LIB_DUNE_CONTENTS=$(printf "%s\\n%s" "${LIB_DUNE_CONTENTS}" "(library")
LIB_DUNE_CONTENTS=$(printf "%s\\n %s" "${LIB_DUNE_CONTENTS}" "  ; The namespace that other packages/libraries will access this library through")
LIB_DUNE_CONTENTS=$(printf "%s\\n %s" "${LIB_DUNE_CONTENTS}" "  (name ${Library_NAMESPACE})")
LIB_DUNE_CONTENTS=$(printf "%s\\n %s" "${LIB_DUNE_CONTENTS}" "  ; Other libraries list this name in their package.json 'require' field to use this library.")
LIB_DUNE_CONTENTS=$(printf "%s\\n %s" "${LIB_DUNE_CONTENTS}" "  (public_name monads.lib)")
if [ ! -z "${Library_REQUIRE}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (libraries ${Library_REQUIRE})")
fi
if [ ! -z "${Library_WRAPPED}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${LIB_DUNE_CONTENTS}" "   (wrapped ${Library_WRAPPED})  ; From package.json wrapped field")
fi
if [ ! -z "${Library_C_NAMES}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (c_names ${Library_C_NAMES})  ; From package.json cNames field")
fi
if [ -z "${Library_JSOO_FLAGS}" ] && [ -z "${Library_JSOO_FILES}" ]; then
  # No jsoo flags whatsoever
  true
else
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s" "${LIB_DUNE_CONTENTS}" "  (js_of_ocaml ")
  if [ ! -z "${Library_JSOO_FLAGS}" ]; then
    LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "    (flags (${Library_JSOO_FLAGS}))  ; From package.json jsooFlags field")
  fi
  if [ ! -z "${Library_JSOO_FILES}" ]; then
    LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "    (javascript_files ${Library_JSOO_FILES})  ; From package.json jsooFiles field")
  fi
  LIB_DUNE_CONTENTS=$(printf "%s\\n%s" "${LIB_DUNE_CONTENTS}" "   )")
fi
if [ ! -z "${Library_FLAGS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (flags (${Library_FLAGS}))  ; From package.json flags field")
fi
if [ ! -z "${Library_OCAMLC_FLAGS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (ocamlc_flags (${Library_OCAMLC_FLAGS}))  ; From package.json ocamlcFlags field")
fi
if [ ! -z "${Library_OCAMLOPT_FLAGS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (ocamlopt_flags (${Library_OCAMLOPT_FLAGS})) ; From package.json ocamloptFlags")
fi
if [ ! -z "${Library_MODES}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (modes (${Library_MODES}))  ; From package.json modes field")
fi
if [ ! -z "${Library_IMPLEMENTS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (implements ${Library_IMPLEMENTS}) ; From package.json implements")
fi
if [ ! -z "${Library_VIRTUALMODULES}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (virtual_modules ${Library_VIRTUALMODULES}) ; From package.json virtualModules")
fi
if [ ! -z "${Library_RAWBUILDCONFIG}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  ${Library_RAWBUILDCONFIG} ")
fi
if [ ! -z "${Library_PREPROCESS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "  (preprocess (${Library_PREPROCESS}))  ; From package.json preprocess field")
fi
LIB_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${LIB_DUNE_CONTENTS}" ")")

if [ ! -z "${Library_IGNOREDSUBDIRS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${LIB_DUNE_CONTENTS}" "(ignored_subdirs (${Library_IGNOREDSUBDIRS}))  ; From package.json ignoreSubdirs field")
fi
if [ ! -z "${Library_INCLUDESUBDIRS}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n%s\\n" "${LIB_DUNE_CONTENTS}" "(include_subdirs ${Library_INCLUDESUBDIRS})  ; From package.json includeSubdirs field")
fi

if [ ! -z "${Library_RAWBUILDCONFIGFOOTER}" ]; then
  LIB_DUNE_CONTENTS=$(printf "%s\\n %s\\n" "${LIB_DUNE_CONTENTS}" "${Library_RAWBUILDCONFIGFOOTER}")
fi

if [ "${LIB_DUNE_EXISTING_CONTENTS}" == "${LIB_DUNE_CONTENTS}" ]; then
  true
else
  notifyUser
  BUILD_STALE_PROBLEM="true"
  if [ "${MODE}" == "build" ]; then
    printf "    □  Update library/dune build config\\n"
  else
    printf "    %s☒%s  Update library/dune build config\\n" "${BOLD}${GREEN}" "${RESET}"
    printf "%s" "$LIB_DUNE_CONTENTS" > "${LIB_DUNE_FILE}"
  fi
fi
if [ -f  "${cur__root}/dune" ]; then
  true
else
  BUILD_STALE_PROBLEM="true"
  notifyUser
  if [ "${MODE}" == "build" ]; then
    printf "    □  Update ./dune to ignore node_modules\\n"
  else
    printf "    %s☒%s  Update ./dune to ignore node_modules\\n" "${BOLD}${GREEN}" "${RESET}"
    printf "(dirs (:standard \\ node_modules \\ _esy))" > "${cur__root}/dune"
  fi
fi

if [ -f  "${cur__root}/${PACKAGE_NAME}.opam" ]; then
  true
else
  BUILD_STALE_PROBLEM="true"
  notifyUser
  if [ "${MODE}" == "build" ]; then
    printf "    □  Add %s\\n" "${PACKAGE_NAME}.opam"
  else
    printf "    %s☒%s  Add %s\\n" "${BOLD}${GREEN}" "${RESET}" "${PACKAGE_NAME}.opam" 
    touch "${cur__root}/${PACKAGE_NAME}.opam"
  fi
fi

if [ -f  "${cur__root}/dune-project" ]; then
  true
else
  BUILD_STALE_PROBLEM="true"
  notifyUser
  if [ "${MODE}" == "build" ]; then
    printf "    □  Add a ./dune-project\\n"
  else
    printf "    %s☒%s  Add a ./dune-project\\n" "${BOLD}${GREEN}" "${RESET}"
    printf "(lang dune 1.6)\\n (name %s)" "${PACKAGE_NAME}" > "${cur__root}/dune-project"
  fi
fi


if [ "${MODE}" == "build" ]; then
  if [ "${BUILD_STALE_PROBLEM}" == "true" ]; then
    printf "\\n  %sTo perform those updates and build run:%s\n\n" "${BOLD}${YELLOW}" "${RESET}"
    printf "    esy pesy\\n\\n\\n\\n"
    exit 1
  else
    # If you list a refmterr as a dev dependency, we'll use it!
    BUILD_FAILED=""
    if hash refmterr 2>/dev/null; then
      refmterr dune build -p "${PACKAGE_NAME}" || BUILD_FAILED="true"
    else
      dune build -p "${PACKAGE_NAME}" || BUILD_FAILED="true"
    fi
    if [ -z "$BUILD_FAILED" ]; then
      printf "\\n%s  Build Succeeded!%s " "${BOLD}${GREEN}" "${RESET}"
      if [ -z "$LAST_EXE_NAME" ]; then
        printf "\\n\\n"
        true
      else
        # If we built an EXE
        printf "%sTo test a binary:%s\\n\\n" "${BOLD}" "${RESET}"
        printf "      esy x %s\\n\\n\\n" "${LAST_EXE_NAME}"
      fi
      true
    else
      exit 1
    fi
  fi
else
  # In update mode.
  if [ "${BUILD_STALE_PROBLEM}" == "true" ]; then
    printf "\\n  %sUpdated!%s %sNow run:%s\\n\\n" "${BOLD}${GREEN}" "${RESET}" "${BOLD}" "${RESET}"
    printf "    esy build\\n\\n\\n"
  else
    printf "\\n  %sAlready up to date!%s %sNow run:%s\\n\\n" "${BOLD}${GREEN}" "${RESET}" "${BOLD}" "${RESET}"
    printf "      esy build\\n\\n\\n"
  fi
fi

