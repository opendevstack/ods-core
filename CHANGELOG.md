# Changelog

## 0.1.0 (2018-07-27)

Initial release.

## 0.2RC *current master*

1. Overall architecture changes
   1. jenkins-slava-base can be built on either centos7 or rhel7 configurable via buildconfig (#5)
   1. jenkins-slave-base now grabs root ca to provide to all other slaves (including rundeck's OC container) (#18, #20)
   1. nexus also contains a backup pvc (for the backup of db task)
   
1. Other (bugfixes)   
   1. secrets for authproxy container (in shared images) was missing (#6)
   
