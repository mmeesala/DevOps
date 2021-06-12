#! /bin/bash
# Author: Murali Meesala <murali.meesala@gmail.com>
# Title: Principal Systems Engineer
# script name: connect-ssh-gke-tunnel.sh
# Version: 1.0
# Functionality: This script will fetch list of your GKE clusters in each GCP project. Based on your inputs, it will establish a secure tunneling via GKE bastion host to perform GKE operations.
# Dependencies: None
# Usage: ./connect-ssh-gke-tunnel.sh


PROJECT_LIST=`gcloud projects list | grep -v PROJECT_ID| awk '{ print $1}'`

rm -rf options.txt
COUNTER=1
PORT_COUNTER=8100
echo "Select one OPTION from below:"
echo "Project Name and GKE Cluster:"
for PROJECT in ${PROJECT_LIST}
do
	GKE_LIST=`gcloud container clusters list --project ${PROJECT} | grep -v NAME | awk '{ print $1}'`
	for GKE in ${GKE_LIST}
	do
		echo "${COUNTER} ) ${PROJECT} ${GKE}" 
		echo "${COUNTER} ${PROJECT} ${GKE} ${PORT_COUNTER}" >> options.txt
		let PORT_COUNTER++
		let COUNTER++

	done
done 

echo "---------------------------------"

read OPTION

CONNECT_INFO=`sed -n ${OPTION}p options.txt`
PROJECT_NAME=`echo ${CONNECT_INFO} | awk '{print $2}'`
GKE_NAME=`echo ${CONNECT_INFO} | awk '{print $3}'`
PORT=`echo ${CONNECT_INFO} | awk '{print $4}'`
BASTION_HOST_LIST=`gcloud compute instances list --project ${PROJECT_NAME} | grep kbt |awk '{ print $1,$2}'`

echo "You have selected below:"

echo "PROJECT=${PROJECT_NAME}"
echo "GKE_NAME=${GKE_NAME}"
echo "PORT=${PORT}"
echo " "
echo "Select one of the Bastion Host and zone you want to connect: "
echo "${BASTION_HOST_LIST}"
echo " "

echo "Your option please: "
read BASTION_OPTION

BASTION_HOST=`echo ${BASTION_OPTION} | awk '{ print $1}'`
BASTION_ZONE=`echo ${BASTION_OPTION} | awk '{ print $2}'`

echo "Establishing SSH tunneling to ${GKE_NAME} via ${BASTION_HOST} host in ${PROJECT_NAME}..."

gcloud config set project ${PROJECT_NAME}
gcloud compute ssh ${BASTION_HOST} --internal-ip --project=${PROJECT_NAME} --zone=${BASTION_ZONE} -- -L ${PORT}:localhost:8888 -N -q -f
gcloud container clusters get-credentials ${GKE_NAME} --internal-ip --region ${BASTION_ZONE}

echo "Established SSH tunnel. You may connect now to ${GKE_NAME} to perform operations." 
echo " "
echo "Set below aliases..."
echo "alias mlpkube='HTTPS_PROXY=localhost:${PORT} kubectl'"
echo "alias mlpargo='HTTPS_PROXY=localhost:${PORT} kubectl --namespace=argocd'"
