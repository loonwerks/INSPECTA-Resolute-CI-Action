#!/bin/bash -l

echo "component-to-analyze: $1"
echo "output-path: $2"
echo "workspace-location: $3"
echo "project-path: $4"
echo "validation-only: $5"
echo "csv-output: $6"
echo "exit-on-warning: $7"
echo "supplementary-aadl: $8"
echo "attestation_path: $9"

eval $(opam env)

AADL_DIR=${GITHUB_WORKSPACE}/$3

runCommand=(osate -application com.rockwellcollins.atc.resolute.cli.Resolute)

runCommand+=( -noSplash -data ${AADL_DIR} -compImpl $1)

if [[ -n $4 ]]; then
	runCommand+=(-p $4)
	AADL_DIR=${AADL_DIR}/$4
fi

if [ "XX $5" = 'XX "true"' ] ; then
	runCommand+=(-validationOnly)
fi

if [ "XX $6" = 'XX "true"' ]; then
	runCommand+=(-csv)
fi

if [ "XX $7" = 'XX "true"' ]; then
	runCommand+=(-exitOnValidationWarning)
fi

if [[ -n $8 ]]; then
	runCommand+=(-files $8)
fi

if [[ -n $9 ]]; then
     export HAMR_ATTESTATION_ROOT=${GITHUB_WORKSPACE}/$9
fi

runCommand+=(-o ${GITHUB_WORKSPACE}/$2)
runCommand+=(-e)

xvfb-run -e /dev/stdout -s "-screen 0 1280x1024x24 -ac -nolisten tcp -nolisten unix" "${runCommand[@]}"

echo "timestamp=$(jq .date ${GITHUB_WORKSPACE}/$2)" >> $GITHUB_OUTPUT
echo "status=$(jq .status ${GITHUB_WORKSPACE}/$2)" >> $GITHUB_OUTPUT
echo "status-messages=$(jq .statusMessages ${GITHUB_WORKSPACE}/$2)" >> $GITHUB_OUTPUT

exitStatus=1
analysisStatus=$(jq .status ${GITHUB_WORKSPACE}/$2)
echo "analysisStatus: $analysisStatus"
if [ "XX $analysisStatus" = 'XX "Analysis Completed"' ]; then
	claimsTrue=$(jq "[.results[] | .status] | all" ${GITHUB_WORKSPACE}/$2)
	if [ "XX $claimsTrue" = 'XX "true"' ]; then
		exitStatus=0
	fi
fi

echo "exitStatus: $exitStatus"
exit $exitStatus
