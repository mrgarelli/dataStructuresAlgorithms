#!/bin/bash

# ToDo: add flag if the config file is read write protected

hr="${HOME}/Code/bash/file/autoEdit"

# __________________________________________________ cntlm wrapper
pwFix="${hr}/awkScripts/pwFix"
getUserName="${hr}/awkScripts/getUserName"

bash='/bin/bash'
cntlm='/usr/sbin/cntlm'
awk='/usr/bin/awk'

# Check for imput arguments
if [ $# -eq 0 ]; then
	echo 'Must enter a username to authenticate'
	exit 1
fi

echo 'Enter Password:'
cntlmOut="$(${cntlm} -H -a 'NTLMv2' -d 'exampleDomain.com' -u "${@}")"

cntlmOut=$(tail -n 3 <(echo "${cntlmOut}"))

pw="$(echo "${cntlmOut}" | cut -d'#' -f 1)"

# fix password and username formatting
userName="$(${awk} -f ${getUserName} <(echo ${cntlmOut}))"
userName="${userName/\'/}"
userName="${userName/\',/}"
userName="Username	${userName}"

echo
echo "${userName}"
echo 
echo "${pw}"
echo

# __________________________________________________ config file password
configEditor="${hr}/configEditor/run.sh"

function replaceInConfig () {
	${bash} ${configEditor}\
	 "${new_section}"\
	 "${begin_marker}"\
	 "${end_marker}"\
	 "${confFile}"

}

confFile="${hr}/testConfig"

new_section="${pw}"
begin_marker='# Password BEGIN AUTOMATICALLY EDITED PART, DO NOT EDIT'
end_marker='# Password END AUTOMATICALLY EDITED PART'

replaceInConfig

# __________________________________________________ config file username
new_section="${userName}"
begin_marker='# UserName BEGIN AUTOMATICALLY EDITED PART, DO NOT EDIT'
end_marker='# UserName END AUTOMATICALLY EDITED PART'

replaceInConfig

# Do any necessary system resets here

echo
echo 'Configuration file successfully updated. Try using the internet.'
