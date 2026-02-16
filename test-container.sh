#! /bin/bash

set -Eeuxo pipefail

: "${workspace_location:=software/assurance}"
: "${component_to_analyze:=ardupilot_assurance::ArduPilot.i}"
: "${project_path:=.}"
: "${output_path:=software/assurance/resolute.json}"
: "${validation_only:=}"
: "${csv_output:=}"
: "${exit_on_warning:=}"
: "${supplementary_aadl:=}"
: "${attestation_path:=software/hamr/microkit/attestation}"
: "${GITHUB_WORKSPACE:=/home/runner/work}"

docker run --platform linux/amd64 --rm -v /Users/e40002720/Documents/INSPECTA/INSPECTA-demo:${GITHUB_WORKSPACE} \
    -v ./:/home/runner \
    -e GITHUB_WORKSPACE=${GITHUB_WORKSPACE} \
    -e GITHUB_OUTPUT='/dev/stdout' \
    --entrypoint ./home/runner/entrypoint.sh \
    ghcr.io/loonwerks/inspecta-resolute-ci-action-container:resolute-4_1_202 \
    "${component_to_analyze}" "${output_path}" "${workspace_location}" "${project_path}" \
    "${validation_only}" "${csv_output}" "${exit_on_warning}" "${supplementary_aadl}" "{attestation_path}"