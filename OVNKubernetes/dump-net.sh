#!/usr/bin/env bash


if [ "$1" == "" -o "$2" == "" ] ; then
  echo "Please run ./$0 <NODE|--all> <FILE>";
  exit 1;
fi;
DUMP_FILE=$2
if [ "$1" == "--all" ] ; then
  DUMP_FILE=${DUMP_FILE}.$(date +%Y-%m-%d-%H-%M-%S.%s)
  PODS=$(oc get pods -n openshift-ovn-kubernetes  -l app=ovs-node -o go-template='{{range .items}}{{.spec.nodeName}};{{.metadata.name}}{{"\n"}}{{end}}');
else
  PODS=$(oc get pods -n openshift-ovn-kubernetes  -l app=ovs-node -o go-template='{{range .items}}{{.spec.nodeName}};{{.metadata.name}}{{"\n"}}{{end}}' | grep ^${1});
fi

echo -e "Run dump at \n$PODS";

for i in $PODS ; do
    NODE=${i%;*}
    POD=${i#*;}
    for br in br-ex br-int br-local ; do
      echo "Write: ${DUMP_FILE}.${NODE}.OpenFlow13.${br}"
      oc rsh -n openshift-ovn-kubernetes pod/${POD} ovs-ofctl -O OpenFlow13 --no-stats dump-flows ${br} | perl -pe 's/(reg0|reg1)=([^ ,]+)/sprintf("%s=%d",$1, hex($2))/eg' > ${DUMP_FILE}.${NODE}.OpenFlow13.${br}
    done
    echo "Write: ${DUMP_FILE}.${NODE}.iptables"
    oc rsh -n openshift-ovn-kubernetes pod/${POD} iptables-save > ${DUMP_FILE}.${NODE}.iptables
done;
