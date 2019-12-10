#!/usr/bin/env bash
set -e
# Not using -x (tracing) to avoid disclosure of passwords/tokens when
# processing arguments.

# this script exports project templates for OpenDevStack in OpenShift
#
## settings
## functions

save_pvc_json_config() {
  cat <<EOF >${pvc_json_conf_output_path}
        {
            "apiVersion": "v1",
            "kind": "PersistentVolumeClaim",
            "metadata": {
                "name": "$pvc_name"
            },
            "spec": {
                "accessModes": [
                    "$pvc_access_mode"
                ],
                "resources": {
                    "requests": {
                        "storage": "$pvc_size"
                    }
                }
            }
        }
EOF
}

save_is_json_config() {
  cat <<EOF >${is_json_conf_output_path}
		{
			"kind": "List",
			"apiVersion": "v1",
			"metadata": {},
			"items": [
				{
					"kind": "ImageStream",
					"apiVersion": "v1",
					"metadata": {
						"name": "$isname",
						"namespace": "$project-$env",
						"labels": {
							"app": "$project",
							"component": "$isname",
							"env": "$env",
							"template": "component-template"
						},
						"annotations": {
							"description": "Keeps track of changes in the application image"
						}
					},
					"spec": {
						"dockerImageRepository": "$isname"
					}
				}
			]
		}
EOF
}

save_route_json_config() {
  cat <<EOF >${route_json_conf_output_path}
		{
			"kind": "List",
			"apiVersion": "v1",
			"metadata": {},
			"items": [
				{
					"kind": "Route",
					"apiVersion": "v1",
					"metadata": {
						"name": "$routename",
						"namespace": "$namespace",
						"labels": {
							"app": "$app",
							"component": "$routename",
							"env": "$env",
							"template": "component-route-template"
						}
					},
					"spec": {
					    "host": "$host",
                        "path" : "$api_path",
						"to": {
							"kind": "Service",
							"name": "$service",
							"weight": 100
						},
						"tls": {
							"termination": "$termination",
							"insecureEdgeTerminationPolicy": "$policy"
						},
						"wildcardPolicy": "None"
					}
				}
			]
		}
EOF
}

## main
echo " -- started"

while [[ $# -gt 1 ]]; do
  key="$1"

  case $key in
  -p | --project)
    OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG="$2"
    shift # past argument
    ;;
  -t | --ocp_token)
    OD_OCP_SOURCE_TOKEN="$2"
    shift # past argument
    ;;
  -h | --ocp_host)
    OD_OCP_SOURCE_HOST="$2"
    shift # past argument
    ;;
  -e | --env)
    OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES="$2"
    shift # past argument
    ;;
  -g | --git)
    OD_GIT_URL="$2"
    shift # past argument
    ;;
  -gb | --gitbranch)
    OD_GIT_BRANCH="$2"
    shift # past argument
    ;;
  -gt | --gittag)
    OD_GIT_TAG="$2"
    shift # past argument
    ;;
  --force)
    FORCE_PROJECT="$2"
    shift # past argument
    ;;
  -v | --verbose)
    OD_VERBOSE="$2"
    shift # past argument
    ;;
  *)
    # unknown option
    ;;
  esac
  shift # past argument or value
done

# force = true take the project name! (and don't expect a standard structure)
if [[ ${FORCE_PROJECT} == "true" ]]; then
  echo ">>> force project name: "${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}
  OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES=${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}
elif [[ -z ${OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES} ]]; then
  # fallback
  echo ">>> no project envs set - setting cd_test_dev"
  echo
  OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES=cd_test_dev
fi

if [ -z "${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG+x}" -o -z "${OD_GIT_URL+x}" -o -z "${OD_OCP_SOURCE_HOST}" ]; then
  echo "!!!! mandatory params are unset !!! "
  echo "-h|--ocp_host: ${OD_OCP_SOURCE_HOST}"
  echo "-t|--ocp_token: ********"
  echo "-p|--project: ${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}"
  echo "-e|--env: ${OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES}"
  echo "-g|--git: ${OD_GIT_URL}"
  exit 1
else
  echo "USING .... "
  echo "project: ${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}"
  echo "namespaces: ${OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES}"
  echo "git url: ${OD_GIT_URL}"
fi

project_name=$OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG
local_git_repo_fld=${project_name}-occonfig-artifacts

# Test if the login token is provided to execute the login or just use current session
if [ -z "$OD_OCP_SOURCE_TOKEN" ]; then
  echo "Skiping 'oc login'... using current oc '$(oc whoami)' session"
else
  echo " -- login to OpenShift (${OD_OCP_SOURCE_HOST})"
  oc login ${OD_OCP_SOURCE_HOST} --token=${OD_OCP_SOURCE_TOKEN} >&/dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR: could not login into ${OD_OCP_SOURCE_HOST} with oc"
    exit 1
  fi
fi

# Enable tracing only after token would be disclosed
if [[ $OD_VERBOSE != "" ]]; then
  set -x
fi

# checkout git repo (standard naming)
git_repo=$OD_GIT_URL
if [[ $OD_GIT_URL == *".git"* ]]; then
  echo "using overwrite git url"
else
  git_repo=$OD_GIT_URL/scm/${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}/${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}-occonfig-artifacts.git
fi

temp_dir=$(mktemp -d)
cd $temp_dir
echo " -- cloning git repo $git_repo into $temp_dir"
echo
git clone $git_repo
echo
if [ $? -ne 0 ]; then
  # little housekeeping
  rm -rf $temp_dir
  # error
  echo "ERROR: could not clone the git repo $git_repo"
  exit 1
fi
# step inside clonned git repo
basename=$(basename $git_repo)
clonned_git_fld_name=${basename%.*}
cd $clonned_git_fld_name
if [ $? -ne 0 ]; then
  echo "ERROR: could not find a folder $clonned_git_fld_name after cloning git repo."
  exit 1
fi
# switch to another git branch?
git_checkout_expression="git checkout "
# branch set in config
if [[ -z ${OD_GIT_BRANCH// /} ]]; then
  # no -> set to default master branch
  OD_GIT_BRANCH=master
fi

REMOTE_BRANCH_COUNT=$(git ls-remote --heads ${git_repo} ${OD_GIT_BRANCH} | wc -l)

if [[ "$REMOTE_BRANCH_COUNT" -ge "1" ]]; then
  git_checkout_expression="$git_checkout_expression ${OD_GIT_BRANCH}"
else
  git_checkout_expression="$git_checkout_expression -b ${OD_GIT_BRANCH}"
fi

# tag set?
if [[ ! -z ${OD_GIT_TAG// /} ]]; then
  # yes
  git_checkout_expression="$git_checkout_expression tags/${OD_GIT_TAG}"
fi
#
echo " -- check out git for $git_checkout_expression"
eval ${git_checkout_expression}
echo

# create config file with source API OCP hostname ...
echo "export_source_host=${OD_OCP_SOURCE_HOST}" >ocp_config

#
# export templates
echo " -- exporting metadata"
for ocp_proj_namespace_suffix in $(# ${OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES[@]};
  echo $OD_PROJ_OCP_NAMESPACE_SOURCE_SUFFIXES | sed -e 's/_/ /g'
); do

  if [[ ${FORCE_PROJECT} == "true" ]]; then
    curr_ocp_namespace=${project_name}
    ocp_proj_namespace_suffix=${project_name}
  else
    curr_ocp_namespace=${project_name}-${ocp_proj_namespace_suffix}
  fi

  oc project ${curr_ocp_namespace}

  echo " >>>>>>>>>>> -- exporting ocp project namespace ${curr_ocp_namespace} from (${OD_OCP_SOURCE_HOST}) -- <<<<<<<<<<<<<<<<<"
  echo
  mkdir -p ${ocp_proj_namespace_suffix}

  oc export -o yaml secret,sa --namespace $curr_ocp_namespace >${ocp_proj_namespace_suffix}/project.yml
  oc export -o yaml rolebindings --namespace $curr_ocp_namespace >${ocp_proj_namespace_suffix}/rolebindings.yml

  if [ ! -s ${ocp_proj_namespace_suffix}/project.yml ]; then
    echo "!! Project export is empty - as errors occured above, hence aborting - do you have full rights on ${curr_ocp_namespace} ?"
    exit 1
  fi
  mkdir -p ${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}
  #
  echo "    exporting config maps  for $curr_ocp_namespace"
  configmap_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/configmap.tsv
  oc get configmap --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${configmap_file}
  #
  echo "-- generating config map yaml configs"
  mkdir -p ${ocp_proj_namespace_suffix}/config
  while IFS= read line; do
    #echo "    $line"
    cmap_config=($line)
    cmap_name=${cmap_config[0]}
    oc export -o yaml configmap ${cmap_name} >${ocp_proj_namespace_suffix}/config/configmap_${cmap_name}.yml
    echo "   created configurationmap in cmap_${cmap_name}.yml"
  done <"${configmap_file}"
  #
  echo "    exporting service accounts for $curr_ocp_namespace"
  sa_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/serviceaccounts.tsv
  oc get sa --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${sa_file}
  #
  echo "-- generating service account yaml configs"
  mkdir -p ${ocp_proj_namespace_suffix}/sa
  while IFS= read line; do
    #echo "    $line"
    sa_config=($line)
    sa_name=${sa_config[0]}
    oc export -o yaml sa ${sa_name} >${ocp_proj_namespace_suffix}/sa/sa_${sa_name}.yml
    echo "   created service account in sa_${sa_name}.yml"
  done <"${sa_file}"
  #
  echo "    exporting templates for $curr_ocp_namespace"
  template_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/templates.tsv
  oc get template --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${template_file}
  #
  echo "-- generating template yaml configs"
  mkdir -p ${ocp_proj_namespace_suffix}/template
  while IFS= read line; do
    #echo "    $line"
    template_config=($line)
    template_name=${template_config[0]}
    oc export -o yaml template ${template_name} >${ocp_proj_namespace_suffix}/template/template_${template_name}.yml
    echo "   created template in template_${template_name}.yml"
  done <"${template_file}"
  #
  echo "    exporting build configs for $curr_ocp_namespace"
  build_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/buildconfigs.tsv
  oc get bc --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${build_file}
  #
  echo "-- generating build yaml configs"
  mkdir -p ${ocp_proj_namespace_suffix}/bc
  while IFS= read line; do
    #echo "    $line"
    bc_config=($line)
    bc_name=${bc_config[0]}
    oc export -o yaml bc ${bc_name} >${ocp_proj_namespace_suffix}/bc/bc_${bc_name}.yml
    echo "   created bc configuration in bc_${bc_name}.yml"
  done <"${build_file}"
  #
  echo "    exporting deployment configs for $curr_ocp_namespace"
  deploy_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/deployconfigs.tsv
  oc get dc --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${deploy_file}
  #
  echo "-- generating deployment yaml configs"
  mkdir -p ${ocp_proj_namespace_suffix}/dc
  while IFS= read line; do
    #echo "    $line"
    dc_config=($line)
    dc_name=${dc_config[0]}
    oc export -o yaml dc ${dc_name} >${ocp_proj_namespace_suffix}/dc/dc_${dc_name}.yml
    echo "   created dc configuration in dc_${dc_name}.yml"
  done <"${deploy_file}"
  #
  echo "    exporting services for $curr_ocp_namespace"
  service_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/service.tsv
  oc get service --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${service_file}
  #
  echo "-- generating service yaml configs"
  mkdir -p ${ocp_proj_namespace_suffix}/service
  while IFS= read line; do
    #echo "    $line"
    svc_config=($line)
    svc_name=${svc_config[0]}
    oc export -o yaml svc ${svc_name} >${ocp_proj_namespace_suffix}/service/svc_${svc_name}.yml
    echo "   created svc configuration in svc_${svc_name}.yml"
  done <"${service_file}"
  #
  echo "    exporting persistent volume claims for $curr_ocp_namespace"
  tsv_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/pvc.tsv
  oc get pvc --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1,4,5 >${tsv_file}
  #
  echo "-- generating pvc json configs"
  mkdir -p ${ocp_proj_namespace_suffix}/pvc

  while IFS= read line; do
    #echo "    $line"
    pvc_config=($line)
    pvc_name=${pvc_config[0]}
    #echo "pvc_name: $pvc_name"
    pvc_size=${pvc_config[1]}
    #echo "pvc_size: $pvc_size"
    pvc_access_mode=$(echo ${pvc_config[2]} | sed -e 's/ROX/ReadOnlyMany/g' -e 's/RWX/ReadWriteMany/g' -e 's/RWO/ReadWriteOnce/g')
    #echo "pvc_access_mode: $pvc_access_mode"
    pv_name=${curr_ocp_namespace}-${pvc_name}
    # echo "PVolume name - ${pv_name}"
    pvc_json_conf_output_path="${ocp_proj_namespace_suffix}/pvc/pvc_${pvc_name}.json"
    save_pvc_json_config
    echo "   created pvc configuration in $pvc_json_conf_output_path"
  done <"$tsv_file"
  #
  echo "    exporting imagestreams for $curr_ocp_namespace"
  is_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/is.tsv
  oc get is --export=true --no-headers | sed 's/  */ /g' | cut -d ' ' -f1 >${is_file}
  #
  echo "-- generating is json configs"
  mkdir -p ${ocp_proj_namespace_suffix}/imagestream

  while IFS= read line; do
    #echo "    $line"
    is_config=($line)
    isname=${is_config[0]}
    project=${project_name}
    env=${ocp_proj_namespace_suffix}
    is_json_conf_output_path="${ocp_proj_namespace_suffix}/imagestream/is_${isname}.json"
    save_is_json_config
    echo "   created is configuration in $is_json_conf_output_path"
  done <"$is_file"
  #
  echo "    exporting routes for $curr_ocp_namespace"
  route_file=${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/route.tsv
  oc get route --no-headers | sed 's/  */ /g' | cut -d ' ' -f1,2,3,4,5,6,7 >${route_file}
  #
  echo "-- generating route json configs"
  mkdir -p ${ocp_proj_namespace_suffix}/route

  while IFS= read line; do
    #echo "    $line"
    route_config=($line)

    routename=${route_config[0]}
    namespace=${curr_ocp_namespace}
    app=${project_name}
    env=${ocp_proj_namespace_suffix}
    host=${route_config[1]}

    # The size of the array is 7 when we have the path
    if [ "${#route_config[@]}" = "7" ]; then
      termination=$(echo ${route_config[5]} | sed -e 's/edge/edge/g' | cut -d '/' -f1)
      api_path=${route_config[2]}
      service=${route_config[3]}
    else
      termination=$(echo ${route_config[4]} | sed -e 's/edge/edge/g' | cut -d '/' -f1)
      service=${route_config[2]}
    fi

    if [[ "${route_config[4]}" == *"/"* ]]; then
      policy=$(echo ${route_config[4]} | sed -e 's/edge/edge/g' | cut -d '/' -f2)
    else
      policy=
    fi
    route_json_conf_output_path="${ocp_proj_namespace_suffix}/route/route_${routename}.json"
    save_route_json_config
    echo "   created route configuration in $route_json_conf_output_path"

  done \
    <"$route_file"

  echo
  echo " ... DONE exporting project ${curr_ocp_namespace}"
  echo

  temp_dir_with_updated_files=$(mktemp -d)
  if [ "$OD_REPLACE_EXPORTED_DATA_ENABLED" = true ]; then
    cd $temp_dir_with_updated_files

    # checkout git repo
    git_repo=$OD_GIT_URL
    temp_dir=$(mktemp -d)
    cd $temp_dir
    echo " -- cloning git repo $git_repo into $temp_dir"
    echo
    git clone $git_repo
    # step inside clonned git repo
    basename=$(basename $git_repo)
    clonned_git_fld_name=${basename%.*}
    cd $clonned_git_fld_name
    # switch to another git branch?
    git_checkout_expression="git checkout "
    # branch set in config
    if [[ -z ${OD_GIT_BRANCH// /} ]]; then
      # no -> set to default master branch
      OD_GIT_BRANCH=master
    else
      # yes
      git_checkout_expression="$git_checkout_expression -b ${OD_GIT_BRANCH}"
    fi
    # tag set?
    if [[ ! -z ${OD_GIT_TAG// /} ]]; then
      # yes
      git_checkout_expression="$git_checkout_expression tags/${OD_GIT_TAG}"
    fi
    #
    echo " -- check out git for $git_checkout_expression"
    #git checkout -b ${OD_GIT_BRANCH} tags/${OD_GIT_TAG}
    eval ${git_checkout_expression}
    echo
    #
    echo " -- replacing data "
    for yaml_file in ls ${temp_dir}/${clonned_git_fld_name}/${ocp_proj_namespace_suffix}/*.{yml,json}; do
      if [[ -f $yaml_file ]]; then
        cd ${ocp_proj_namespace_suffix}
        yaml_filename=$(basename "$yaml_file")
        output_yaml=${PWD}/${yaml_filename}
        filename_without_extension="${yaml_filename%.*}"
        output_diff=${PWD}/${filename_without_extension}.diff
        echo "    transforming $yaml_file -> $output_yaml"
        cat $yaml_file | sed -e "s/${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}-${ocp_proj_namespace_suffix}/${OD_OCP_PROJECT_NAMESPACE_PREFIX_NEW}-${ocp_proj_namespace_suffix}/g" \
          -e "s/${OD_OCP_APP_SOURCE_DOMAIN}/${OD_OCP_APP_TARGET_DOMAIN}/g" >${output_yaml}
        diff_column_width=260 # because default 130 is too small for yml configs
        diff $yaml_file ${output_yaml} --side-by-side --left-column -W 260 >${output_diff}
        cd ..
      fi
    done
    temp_dir="$temp_dir_with_updated_files"
  fi
done
cd ${temp_dir}/${clonned_git_fld_name} >&/dev/null
#
echo " -- pushing to remote git repo"

git config --local user.email "undefined"
git config --local user.name "CD System"

git add --all >&/dev/null
commit_msg="Automatic export from ${OD_OCP_SOURCE_HOST}"

# allowed to fail
set +e

git commit -m "$commit_msg" -q
#git remote add origin $OD_GIT_URL
git push --set-upstream origin $OD_GIT_BRANCH
cd - >&/dev/null
echo " -- little housekeeping"
rm -rf $temp_dir
rm -rf $temp_dir_with_updated_files
echo " -- finished"
#END
