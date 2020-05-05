#!/bin/bash
set -e
# Not using -x (tracing) to avoid disclosure of passwords/tokens when
# processing arguments.

# this script imports OCP project from metadata file located in a specified Git repo (input)
# for OpenDevStack in OpenShift
#
## settings
#

eval_oc_artifact_status()
{
	local oc_command="oc "

	#remove json and yml file suffixes
	artifact_name=$(basename $artifact_file .yml)
	artifact_name=$(basename $artifact_name .json)

	#extract type from filename <type>_<filename>
	artifact_type=$(basename $artifact_name | cut -d '_' -f1)
	#remove artifact prefix
	artifact_name=$(echo "${artifact_name}" | sed -e "s/${artifact_type}_//g")

	# react to fail
	set +e
	oc get $artifact_type $artifact_name >& /dev/null
	if [ $? -ne 0 ]; then
		oc_command="$oc_command create -f "
	else
		# skip replace set? ...
		if [[ ${skip_replace} == "true" || ${OD_USE_ADDONLY} == "true" ]]; then
			oc_command="echo !!! NOT replacing $artifact_name with "
		else
			oc_command="$oc_command replace -f "
		fi
	fi
	set -e
	#the reason to only return the command here - is that we may use a tmp file later
	#with replaced content
	echo "$oc_command"
}

eval_oc_artifact_name()
{
	local oc_artifact=""

	#remove json and yml file suffixes
	artifact_name=$(basename $artifact_file .yml)
	artifact_name=$(basename $artifact_name .json)

	#extract type from filename <type>_<filename>
	artifact_type=$(basename $artifact_name | cut -d '_' -f1)
	#remove artifact prefix
	artifact_name=$(echo "${artifact_name}" | sed -e "s/${artifact_type}_//g")

	oc_artifact="$artifact_name"

	echo "$oc_artifact"
}
#
echo " -- started"
## main

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -p|--project)
    OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG="$2"
    shift # past argument
    ;;
	-h|--ocp_host)
    OD_OCP_TARGET_HOST="$2"
    shift # past argument
    ;;
    -t|--ocp_token)
    OD_OCP_TARGET_TOKEN="$2"
    shift # past argument
    ;;
    -tr|--ocp_token_registry)
    OD_OCP_SOURCE_TOKEN="$2"
    shift # past argument
    ;;
    -e|--env)
    OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES="$2"
    shift # past argument
    ;;
    -g|--git)
    OD_GIT_URL="$2"
    shift # past argument
    ;;
    -gb|--gitbranch)
    OD_GIT_BRANCH="$2"
    shift # past argument
    ;;
    -gt|--gittag)
    OD_GIT_TAG="$2"
    shift # past argument
    ;;
	-a|--project_admins)
    OD_PRJ_ADMINS="$2"
    shift # past argument
    ;;
	-n|--target_project)
    OD_TO_PROJECT="$2"
    shift # past argument
    ;;
    --apply)
    OD_USE_APPLY="$2"
    shift # past argument
    ;;
    --addonly)
    OD_USE_ADDONLY="$2"
    shift # past argument
    ;;
    --force)
    FORCE_PROJECT="$2"
    shift # past argument
    ;;
    -v|--verbose)
    OD_VERBOSE="$2"
    shift # past argument
    ;;
    --skip-config-validation)
    SKIP_CONF_VALIDATION="$2"
    shift # past argument
    ;;
    *)
    # unknown option
    ;;
esac
shift # past argument or value
done

if [[ -z ${OD_PRJ_ADMINS} ]]; then
    # fallback
	echo ">>> no project admins set - setting clemens :)"
	echo
    OD_PRJ_ADMINS=utschig
else
	# prepend clemens' account
    OD_PRJ_ADMINS=utschig,${OD_PRJ_ADMINS}
fi

if [[ -z ${OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES} ]]; then
    # fallback
	echo ">>> no project envs set - setting cd_test_dev"
	echo
    OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES=cd_test_dev
fi

if [ -z "${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG+x}" -o -z "${OD_GIT_URL+x}" -o -z "${OD_OCP_TARGET_HOST}" ]; then
	echo "!!!! mandatory params are unset !!! ";
	echo "-h|--ocp_host: ${OD_OCP_TARGET_HOST}"
	echo "-t|--ocp_token: ********"
	echo "-p|--project: ${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}"
	echo "-e|--env: ${OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES}"
	echo "-g|--git: ${OD_GIT_URL}"
	echo "-n|--target_project: ${OD_TO_PROJECT}"

	exit 1
else
	echo "USING .... "
	echo "project: ${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}"
	echo "git url: ${OD_GIT_URL}"
	echo "git branch / tag: ${OD_GIT_BRANCH} / ${OD_GIT_TAG}"
	echo "namespaces: ${OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES}"
	echo "admins : ${OD_PRJ_ADMINS}"
	echo "new project name : ${OD_TO_PROJECT}"
	if [[ ${OD_USE_ADDONLY} == "true" ]]; then
		echo "-- adding missing artifacts only"
	fi
	echo ""
fi

# Enable debug mode
if [[ $OD_VERBOSE != "" ]]; then
  set -x
fi

# grab for later - to source configuration
scriptdir=$(pwd)

# find the right configuration to use based on the target API host passed parameter
targetconfig=$(grep -H $OD_OCP_TARGET_HOST $scriptdir/migration_config/ocp_project_config_target* | cut -d ':' -f1)

if [[ -f "$targetconfig" ]]; then
	echo "> sourcing env target config from $targetconfig"
	source $targetconfig
else
	echo "Target cluster config $targetconfig, for cluster $OD_OCP_TARGET_HOST could NOT be located - this is a must to successfully run this script"
	exit 1
fi

if [[ -z ${OD_EXCLUDE_NAMESPACES} ]]; then
    # fallback
	echo ">>> no namespace exclusions set - cd / shared-images / openshift and rhscl"
	echo
    OD_EXCLUDE_NAMESPACES=cd,shared-images,openshift,rhscl
fi

# checkout git repo (standard naming)
git_repo=$OD_GIT_URL
if [[ $OD_GIT_URL == *".git"* ]]; then
  echo "using overwrite git url"
else
  git_repo=$OD_GIT_URL/scm/${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}/${OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG}-occonfig-artifacts.git
fi

temp_dir=$( mktemp -d )
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
if [[ -z ${OD_GIT_BRANCH// } ]]; then
    # no -> set to default master branch
    git_checkout_expression="$git_checkout_expression"
else
    # yes
    git_checkout_expression="$git_checkout_expression ${OD_GIT_BRANCH}"
fi
# tag set?
if [[ !  -z ${OD_GIT_TAG// } ]]; then
    # yes
    git_checkout_expression="$git_checkout_expression tags/${OD_GIT_TAG}"
fi
#
echo " -- check out git for $git_checkout_expression"

eval ${git_checkout_expression}
echo
#
echo
if [ $? -ne 0 ]; then
    echo "ERROR: could not clone the git repo $git_repo - trying with a hot clone"
	# little housekeeping
	rm -rf $temp_dir
fi

# find the right configuration based on the API host source config
if [[ -f "ocp_config" ]]; then
	sourceHost=$(grep export ocp_config | cut -d '=' -f2)
	sourceconfig=$(grep -H $sourceHost $scriptdir/migration_config/ocp_project_config_source | cut -d ':' -f1)

	echo "sourcehost : $sourceHost sourceconfig : $sourceconfig"

	if [[ -f "$sourceconfig" ]]; then
		echo "> sourcing env source config from $sourceconfig"
		source $sourceconfig
	else
		echo "Cannot find $sourceconfig aborting"
		exit  1
	fi
else
	echo "ERROR: no config directory was found"
	exit 1
fi

OD_PRJ_ADMINS=$OD_PRJ_ADMINS,$OD_OCP_CD_SA_TARGET

if [[ ! "$SKIP_CONF_VALIDATION" = "true" ]]; then
    if grep -q $OD_OCP_TARGET_HOST $sourceconfig; then
        echo "Source and Target cluster are the same. Validating configuration..."


        if [[ ! -z "$OD_OCP_SOURCE_APP_DOMAIN" ]]; then
            if [[ -z "$OD_OCP_TARGET_APP_DOMAIN" ]]; then
                echo "Target domain is empty while source is not. It should be to prevent errors"
                exit 1
            fi
        fi

        if [[ ! -z "$OD_OCP_SOURCE_NEXUS_URL" ]]; then
            if [[ -z "$OD_OCP_TARGET_NEXUS_URL" ]]; then
                echo "Target nexus url is empty while source is not. It should be to prevent errors"
                exit 1
            fi
        fi

        if [[ ! -z "$OD_OCP_SOURCE_SQ_URL" ]]; then
            if [[ -z "$OD_OCP_TARGET_SQ_URL" ]]; then
                echo "Target Sonarqube url is empty while source is not. It should be to prevent errors"
                exit 1
            fi
        fi

        if [[ ! -z "$OD_OCP_SOURCE_BITBUCKET_URL" ]]; then
            if [[ -z "$OD_OCP_TARGET_BITBUCKET_URL" ]]; then
                echo "Target bitbucket url is empty while source is not. It should be to prevent errors"
                exit 1
            fi
        fi

        if [[ ! -z "$OD_OCP_CD_SA_SOURCE" ]]; then
            if [[ -z "$OD_OCP_CD_SA_TARGET" ]]; then
                echo "Target service account is empty while source is not. It should be to prevent errors"
                exit 1
            fi
        fi

    else
        echo "Source and Target cluster are NOT the same. Validating configuration..."

        if [[ -z "$OD_OCP_SOURCE_APP_DOMAIN" ]]; then
            echo "Source domain is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ -z "$OD_OCP_TARGET_APP_DOMAIN" ]]; then
            echo "Target domain is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ "$OD_OCP_SOURCE_APP_DOMAIN" = "$OD_OCP_TARGET_APP_DOMAIN" ]]; then
            echo "Source and Target domains are the same. It should be different when importing into a different cluster"
            exit 1
        fi


        if [[ -z "$OD_OCP_SOURCE_NEXUS_URL" ]]; then
            echo "Source nexus url is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ -z "$OD_OCP_TARGET_NEXUS_URL" ]]; then
            echo "Target nexus url is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ "$OD_OCP_SOURCE_NEXUS_URL" = "$OD_OCP_TARGET_NEXUS_URL" ]]; then
            echo "Source and Target nexus urls are the same. It should be different when importing into a different cluster"
            exit 1
        fi


        if [[ -z "$OD_OCP_SOURCE_SQ_URL" ]]; then
            echo "Source Sonarqube url is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ -z "$OD_OCP_TARGET_SQ_URL" ]]; then
            echo "Target Sonarqube url is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ "$OD_OCP_SOURCE_SQ_URL" = "$OD_OCP_TARGET_SQ_URL" ]]; then
            echo "Source and Target Sonarqube urls are the same. It should be different when importing into a different cluster"
            exit 1
        fi

        if [[ -z "$OD_OCP_SOURCE_BITBUCKET_URL" ]]; then
            echo "Source bitbucket url is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ -z "$OD_OCP_TARGET_BITBUCKET_URL" ]]; then
            echo "Target bitbucket url is empty. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ "$OD_OCP_SOURCE_BITBUCKET_URL" = "$OD_OCP_TARGET_BITBUCKET_URL" ]]; then
            echo "Source and Target bitbuckets urls are the same. It should be different when importing into a different cluster"
            exit 1
        fi

        if [[ -z "$OD_OCP_JENKINS_MASTER_IMAGE_SPACE_SOURCE" ]]; then
            "Source space for Jenkins image is not set. It should be set when importing into a different cluster"
            exit 1
        fi

        if [[ ! -z "$OD_OCP_CD_SA_SOURCE" ]]; then
            if [[ -z "$OD_OCP_CD_SA_TARGET" ]]; then
                echo "Target service account is empty while source is not. It should be to prevent errors"
                exit 1
            fi
        fi
    fi
else
    echo "WARNING!!! Validation was skipped"
fi



# Test if the login token is provided to execute the login or just use current session
if [ -z "$OD_OCP_TARGET_TOKEN" ]; then
  echo "Skiping 'oc login'... using current oc '`oc whoami`' session"
else
  echo " -- login to OpenShift (${OD_OCP_TARGET_HOST})"
  oc login ${OD_OCP_TARGET_HOST} --token=${OD_OCP_TARGET_TOKEN} >& /dev/null
  if [ $? -ne 0 ]; then
      echo "ERROR: could not login into ${OD_OCP_TARGET_HOST} with oc"
      exit 1
  fi
fi

# setup 3 OpenShift projects
# HINT: folder name should look like <project_name>-occonfig-artifacts
project_name=$( echo $clonned_git_fld_name | cut -d '-' -f1 )
#
if [ -z $project_name ] && [[ ! ${FORCE_PROJECT} == "true" ]]; then
    echo "ERROR: could not extract project_name from a folder name $clonned_git_fld_name"
    exit 1
fi

# static variables and replacements - source to target
tmp_postfix=.tmp

#
for ocp_proj_namespace_suffix in $(echo $OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES | sed -e 's/_/ /g');
do
	if [[ ${FORCE_PROJECT} == "true" ]]; then
    	curr_ocp_namespace=${ocp_proj_namespace_suffix}
    else
    	curr_ocp_namespace=${project_name}-${ocp_proj_namespace_suffix}
    fi

    cd $ocp_proj_namespace_suffix
    echo "current source folder: ${PWD}"

	if [[ ! -z ${OD_TO_PROJECT} ]]; then
		curr_ocp_namespace=${OD_TO_PROJECT}
		echo " ----> cloning ${project_name}-${ocp_proj_namespace_suffix} into ${curr_ocp_namespace}"
	else
	    echo " -- creating new project ${curr_ocp_namespace} in OpenShift (${OD_OCP_TARGET_HOST})"
	fi

	# react to fail
	set +e
	oc project ${curr_ocp_namespace} >& /dev/null
	result=$?
	set -e

	# assumption : if the project is there - it was created via opendevstack ...
    if [ $result -ne 0 ]; then
        echo "Could not find project ${curr_ocp_namespace} - creating"

		if [ ! -s project.yml ]; then
			echo "!! Project export is empty - as errors occured above, hence aborting"
			exit 1
		fi

		oc new-project ${curr_ocp_namespace} || exit 1
		# create the baseline with service accounts, role bindings - and switch SA account
		cp project.yml project.yml$tmp_postfix
		cp rolebindings.yml rolebindings.yml$tmp_postfix
		if [[ ! -z "$OD_OCP_CD_SA_SOURCE" ]]; then
		    sed -i -e "s|$OD_OCP_CD_SA_SOURCE|$OD_OCP_CD_SA_TARGET|g" project.yml$tmp_postfix
		    sed -i -e "s|$OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG-$OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES|$curr_ocp_namespace|g" project.yml$tmp_postfix

		    sed -i -e "s|$OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG-$OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES|$curr_ocp_namespace|g" rolebindings.yml$tmp_postfix
		else
			echo "OD_OCP_CD_SA_SOURCE is empty! can't continue..."
			exit 1
		fi

		# removing fail on error due to trying to promote cluster deployer role:
		# Error from server (Forbidden): rolebindings.authorization.openshift.io "system:deployers" is forbidden: attempt to grant extra privileges
		set +e
		if [ "$OD_USE_APPLY" = true ]; then
			# https://access.redhat.com/solutions/4272322
			oc apply -f project.yml$tmp_postfix
		else
			oc create --save-config -f project.yml$tmp_postfix
		fi
		oc create --save-config -f rolebindings.yml$tmp_postfix -n ${curr_ocp_namespace} || true
		set -e

		if [[ $ocp_proj_namespace_suffix == "cd" ]]; then
			oc create sa jenkins -n ${project_name}-${ocp_proj_namespace_suffix}
		fi

		# admin for the creating SA and image pull rights
		oc policy add-role-to-user admin system:serviceaccount:${OD_OCP_CD_SA_TARGET}
		oc policy add-role-to-user system:image-puller system:serviceaccount:${OD_OCP_CD_SA_TARGET}
		# everyone authenticated can see
		oc policy add-role-to-group view system:authenticated
		# image-builder for sa default needed to import images from other cluster
		oc policy add-role-to-user system:image-builder -z default -n ${project_name}-${ocp_proj_namespace_suffix}

		# if jenkins CD is NOT part of the import it does not make sense to try to create the linking SA
		if [[ $OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES == *"cd"* ]];
		then
			echo "creating service account jenkins to modify build configs during jenkins build"
			oc policy add-role-to-user admin system:serviceaccount:${project_name}-cd:jenkins -n ${project_name}-${ocp_proj_namespace_suffix}
			echo
		fi

	else
		echo "!!! Project ${curr_ocp_namespace} already exists - skipping creation"
    fi

	SAVED_OPTIONS=$-
	set +x  # switch off tracing to not disclose secrets or token

	# allow it to fail
	set +e
	secretkey=odocp
	secretexists=$(oc get secret | grep "$secretkey")
	set -e

	if [[ ! -z ${OD_OCP_SOURCE_TOKEN} ]] && [[ ! "$ocp_proj_namespace_suffix" == "cd" ]] && [[ ! $secretexists == *"$secretkey"* ]]; then
		echo "Creating OCP OD pull secret for ${OD_OCP_DOCKER_REGISTRY_SOURCE_HOST}"
		oc create secret docker-registry ${secretkey} --docker-server=${OD_OCP_DOCKER_REGISTRY_SOURCE_HOST} --docker-username=cd/cd-integration --docker-password=${OD_OCP_SOURCE_TOKEN} --docker-email=a@b.com
		oc secrets link deployer ${secretkey} --for=pull
		oc secrets link default ${secretkey} --for=pull
	else
		echo "OCP OD Token not set - assuming local build"
	fi
	set $SAVED_OPTIONS

	# add admins
	for admin_user in $(echo $OD_PRJ_ADMINS | sed -e 's/,/ /g');
	do
		oc policy add-role-to-user admin ${admin_user}
	done

	echo
    echo "    importing persistent volume claims"
    for pvc_config_json in ./pvc/pvc_*.json; do
		if [ ! -f "$pvc_config_json" ]
		then
			echo "No artifacts fround that match $pvc_config_json"
			break
		fi

		artifact_file=${pvc_config_json}
		skip_replace=true

		occomm=$(eval_oc_artifact_status)$pvc_config_json

		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $pvc_config_json
        echo
    done

	echo "    importing image streams"
    for is_config_json in ./imagestream/is_*.json; do
		if [ ! -f "$is_config_json" ]
		then
			echo "No artifacts fround that match $is_config_json"
			break
		fi

		artifact_file=${is_config_json}
		skip_replace=true

		cat $is_config_json | sed -e "s|$project_name-$ocp_proj_namespace_suffix|$OD_TO_PROJECT|g" > $is_config_json$tmp_postfix

		occomm=$(eval_oc_artifact_status)$is_config_json$tmp_postfix

		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $is_config_json
        echo
    done

	echo "    importing templates"
    for template_config_json in ./template/template_*.yml; do
		if [ ! -f "$template_config_json" ]
		then
			echo "No artifacts fround that match $template_config_json"
			break
		fi
		artifact_file=${template_config_json}
		skip_replace=false

		# replace hosts
		cp $template_config_json $template_config_json$tmp_postfix
		if [[ ! -z "$OD_OCP_SOURCE_APP_DOMAIN" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_APP_DOMAIN|$OD_OCP_TARGET_APP_DOMAIN|g" $template_config_json$tmp_postfix
		fi

		if [[ ! -z "$OD_OCP_SOURCE_BITBUCKET_URL" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_BITBUCKET_URL|$OD_OCP_TARGET_BITBUCKET_URL|g"  $template_config_json$tmp_postfix
		fi

		occomm=$(eval_oc_artifact_status)$template_config_json$tmp_postfix

		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $template_config_json
        echo
    done

	echo "    importing config maps"
    for cmap_config_json in ./config/configmap_*.yml; do
		if [ ! -f "$cmap_config_json" ]
		then
			echo "No artifacts fround that match $cmap_config_json"
			break
		fi
		artifact_file=${cmap_config_json}
		skip_replace=false

		# replace hosts

		cp $cmap_config_json $cmap_config_json$tmp_postfix
		if [[ ! -z "$OD_OCP_SOURCE_APP_DOMAIN" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_APP_DOMAIN|$OD_OCP_TARGET_APP_DOMAIN|g" $cmap_config_json$tmp_postfix
		fi

		if [[ ! -z "$OD_OCP_SOURCE_BITBUCKET_URL" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_BITBUCKET_URL|$OD_OCP_TARGET_BITBUCKET_URL|g"  $cmap_config_json$tmp_postfix
		fi

		occomm=$(eval_oc_artifact_status)$cmap_config_json$tmp_postfix

		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $cmap_config_json
        echo
    done

	echo "    importing deploy configs"
	# replace nexus host and also an image ns reference to ODjenkins
    for dc_config_json in ./dc/dc_*.yml; do
		if [ ! -f "$dc_config_json" ]
		then
			echo "No artifacts fround that match $dc_config_json"
			break
		fi

		cp  $dc_config_json $dc_config_json$tmp_postfix
		if [[ ! -z "$OD_OCP_SOURCE_NEXUS_URL" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_NEXUS_URL|$OD_OCP_TARGET_NEXUS_URL|g"  $dc_config_json$tmp_postfix
		fi

		if [[ ! -z "$OD_OCP_SOURCE_SQ_URL" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_SQ_URL|$OD_OCP_TARGET_SQ_URL|g"  $dc_config_json$tmp_postfix
		fi

   		sed  -i -e "s|$project_name-$ocp_proj_namespace_suffix|$curr_ocp_namespace|g" $dc_config_json$tmp_postfix


		if [[ ! -z "$OD_OCP_JENKINS_MASTER_IMAGE_SPACE_SOURCE" ]]; then
		    sed  -i -e "s|namespace: $OD_OCP_JENKINS_MASTER_IMAGE_SPACE_SOURCE|namespace: $OD_OCP_SHARED_SPACE_TARGET|g" $dc_config_json$tmp_postfix
		fi

		if [[ ! -z "$OD_OCP_SHARED_SPACE_SOURCE" ]]; then
		    sed  -i -e "s|$OD_OCP_SHARED_SPACE_SOURCE|$OD_OCP_SHARED_SPACE_TARGET|g" $dc_config_json$tmp_postfix
		fi


		artifact_file=${dc_config_json}
		artifactName=$(eval_oc_artifact_name)

		skip_replace=false
		occomm=$(eval_oc_artifact_status)$dc_config_json$tmp_postfix

		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $dc_config_json

		# grab the stream data so we can import later
		ref_imagestreamWithRegistry=$( cat $dc_config_json | grep image: | sed -e 's/ //g' | cut -d ':' -f2,3 | cut -d '@' -f1  | head -1)
		ref_imagestreamOwningProject=$(echo $ref_imagestreamWithRegistry | cut -d '/' -f2)
		ref_imagestreamName=$(echo $ref_imagestreamWithRegistry | cut -d '/' -f3)

		echo " --> checking for referenced project image - stream: $ref_imagestreamWithRegistry"

		exlude_this_namespace=false

		# check for any exclusions
		for exclude_namespace in $(echo $OD_EXCLUDE_NAMESPACES | sed -e 's/,/ /g');
		do
			if [[ $ref_imagestreamOwningProject == $exclude_namespace ]]; then
				exlude_this_namespace=true
				echo "... setting exclusion for image $ref_imagestreamWithRegistry based on $OD_EXCLUDE_NAMESPACES"
			fi
		done

		# dont do any import on shared images from shared-image namespace and from CD
		SAVED_OPTIONS=$-
		set +x  # switch off tracing to not disclose secrets or token
		if [ "$exlude_this_namespace" = false ] && [ ! -z ${OD_OCP_SOURCE_TOKEN// } ] && [[ ! "$ocp_proj_namespace_suffix" == "cd" ]]; then
			echo "Importing remote images ${OD_OCP_DOCKER_REGISTRY_SOURCE_HOST}/${ref_imagestreamOwningProject}/${ref_imagestreamName} into ${ref_imagestreamName}"
			oc import-image ${ref_imagestreamName} --from=${OD_OCP_DOCKER_REGISTRY_SOURCE_HOST}/${ref_imagestreamOwningProject}/${ref_imagestreamName} --confirm
		else
		    echo "Leaving referenced image $ref_imagestreamWithRegistry as is!"
		fi
		set $SAVED_OPTIONS
        echo
    done

	echo "    importing services"
    for svc_config_json in ./service/svc_*.yml; do
		if [ ! -f "$svc_config_json" ]
		then
			echo "No artifacts fround that match $svc_config_json"
			break
		fi

		artifact_file=${svc_config_json}
		skip_replace=true

		occomm=$(eval_oc_artifact_status)$svc_config_json

		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $svc_config_json
        echo
    done

	# for cd this has to be done AFTER the deployment config and services - as it pulls the image straight away and starts a deployment
	# in case nothing else was created yet
	echo "    importing build configs"
    for bc_config_json in ./bc/bc_*.yml; do
		if [ ! -f "$bc_config_json" ]
		then
			echo "No artifacts fround that match $bc_config_json"
			break
		fi

		artifact_file=${bc_config_json}
		skip_replace=false

		cp $bc_config_json $bc_config_json$tmp_postfix
		if [[ ! -z "$OD_OCP_SOURCE_APP_DOMAIN" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_APP_DOMAIN|$OD_OCP_TARGET_APP_DOMAIN|g" $bc_config_json$tmp_postfix
		fi

		if [[ ! -z "$OD_OCP_SOURCE_BITBUCKET_URL" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_BITBUCKET_URL|$OD_OCP_TARGET_BITBUCKET_URL|g"  $bc_config_json$tmp_postfix
		fi


		occomm=$(eval_oc_artifact_status)$bc_config_json$tmp_postfix
		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $bc_config_json
		echo
	done

	echo "    importing routes"
    for route_config_json in ./route/route_*.json; do
		if [ ! -f "$route_config_json" ]
		then
			echo "No artifacts fround that match $route_config_json"
			break
		fi

		artifact_file=${route_config_json}
		skip_replace=false

		cp $route_config_json $route_config_json$tmp_postfix
		if [[ ! -z "$OD_OCP_SOURCE_APP_DOMAIN" ]]; then
		     sed -i -e "s|$OD_OCP_SOURCE_APP_DOMAIN|$OD_OCP_TARGET_APP_DOMAIN|g" $route_config_json$tmp_postfix
		fi

		if [ ! -z "$OD_TO_PROJECT" ]; then
			sed -i -e "s|$OD_OCP_PROJECT_NAMESPACE_PREFIX_ORG-$OD_PROJ_OCP_NAMESPACE_TARGET_SUFFIXES|$OD_TO_PROJECT|g" $route_config_json$tmp_postfix
		fi

		occomm=$(eval_oc_artifact_status)$route_config_json$tmp_postfix
		eval ${occomm}
		git log -n 1 --format="commit: %H by: %aN on: %aD" -- $route_config_json
        echo
    done

    cd ..
done
cd - >& /dev/null
# little housekeeping in host OS
echo " -- removing temp directory ${temp_dir}"
rm -rf ${temp_dir}
echo " -- finished"
#END
