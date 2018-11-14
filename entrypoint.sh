#!/usr/bin/env bash
#
# Deploy a built rpm(s) to the yum server(s)
# The yum servers have a repo for each environment
# Meant to be called from gitlab ci after a successful rpm build
#
#
# You need to set these ENV vars
#  DEPLOY_USER                    - string: user on yum server to deploy with
#  ${YUM_ENVIRONMENT}_YUM_SSH_KEY - string: private ssh key (use secret variables)
#  DEPLOY_PATH                    - string: file path of repo on yum server
#
set -e

YUM_ENVIRONMENT="${CI_COMMIT_REF_NAME}"
SOURCE_PATH=${SOURCE_PATH:-"rpm/RPMS/x86_64/*.rpm"}
DEPLOY_USER=${DEPLOY_USER:-$YUM_ENVIRONMENT}
DEPLOY_PATH=${DEPLOY_PATH:-"/var/yumrepos/${YUM_ENVIRONMENT}/el7/x86_64"}

case "${CI_COMMIT_REF_NAME}" in
vagrant|esodev|esotst)
  YUM_SERVERS=(
    "uitlyumt01.mcs.miamioh.edu"
  ) ;;
development|test|production|operations|shared_services)
  YUM_SERVERS=(
    "uitlyump01.mcs.miamioh.edu"
  ) ;;
*)
  echo "Not Deploying: ${CI_COMMIT_REF_NAME} is not a YUM_ENVIRONMENT" >&2
  exit 1
esac

# We made it here, so we have a match on branch and environment, so deploy
for YUM_SERVER in "${YUM_SERVERS[@]}"; do
  echo ""
  echo -e "\e[93mDeploying: ${CI_COMMIT_REF_NAME}:${YUM_ENVIRONMENT} to ${YUM_SERVER}\e[m"

  SSH_KEY="${YUM_ENVIRONMENT}_YUM_SSH_KEY"
  if [ -n "${!SSH_KEY}" ]; then
    echo -e "${!SSH_KEY}" > id_rsa
    chmod 0600 id_rsa
  else
    echo "You need to set the env var ${YUM_ENVIRONMENT}_YUM_SSH_KEY"
    exit 1
  fi

  scp -o StrictHostKeyChecking=no -i "${PWD}/id_rsa" $SOURCE_PATH "${DEPLOY_USER}@${YUM_SERVER}:${DEPLOY_PATH}"
  echo ""
done

echo -e "\e[92mSuccessfully Deployed\e[m"
