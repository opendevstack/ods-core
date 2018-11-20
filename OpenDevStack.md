
# Table of Contents

1.  [OpenDevStack](#org934dceb)
    1.  [Introduction](#orgfadc273)
    2.  [Requirements](#org7ea47a5)
        -   [Git](#org566c5b5)
        -   [Vagrant](#org62742c1)
        -   [Atlassian tools licenses](#orge4eb735)
        -   [Minishift](#org0c08e64)
        -   [Cygwin / Linux](#org49a64d6)
        -   [Ansible](#org705f4c4)
    3.  [Setup your local environment](#orgf14981b)
        -   [Install tailor Utility](#org945eedb)
        -   [Prepare infrastructure](#orgd3f746d)
            -   [Clone opendevstack Project](#org606ae55)
            -   [Create environment with Vagrant](#org738232d)
            -   [Connect to the Ansible controller **atlcon**](#orgb66fbdb)
    4.  [Install Atlassian Tools and Rundeck](#org8980e3d)
        -   [Crowd Setup](#org111c692)
            -   [Setup Application](#orgca444c6)
            -   [Run Configuration Wizard](#org9c4f284)
            -   [Configure Crowd](#orgf9e3339)
            -   [Add OpenDevStack groups](#org18f6601)
            -   [Add Atlassian groups](#orgc7f0c86)
            -   [Add groups to user](#org37d5fe8)
            -   [Add applications to crowd](#org8462eb6)
        -   [Bitbucket Setup](#org57398b1)
            -   [Setup Application](#org471ee82)
            -   [Run Configuration Wizard](#org300180d)
            -   [Configure Crowd access](#org201ec46)
            -   [Configure user groups](#org4949221)
        -   [Jira Setup](#orgca2cfb3)
            -   [Setup Application](#orgf23b7e9)
            -   [Run Configuration Wizard](#org8de5782)
            -   [Setup application properties](#org0a3ded7)
            -   [Specify your license key](#org6dab2f4)
            -   [Set up administrator account](#org7fb891f)
            -   [Set up email notifications](#org54cfea4)
            -   [Basic configuration](#org0f6f267)
            -   [Configure Crowd access](#org2738219)
        -   [Confluence Setup](#orgfcf1c22)
            -   [Setup Application](#orga96dadf)
            -   [Run Configuration Wizard](#org5abc280)
            -   [Set up Confluence](#orgc6b0518)
            -   [Get add-ons](#org8310ba9)
            -   [License key](#org7a0284d)
            -   [Choose a Database Configuration](#orgff6ea78)
            -   [Configure Database](#orgc6cb425)
            -   [Load Content](#orgca7ed7e)
            -   [Configure User Management](#orge882d70)
            -   [Configure System Administrator account](#orgae4f9f7)
            -   [Configure Crowd access](#org4262b98)
        -   [Create opendevstack project in Bitbucket](#org49324a1)
        -   [Rundeck Setup](#org699964b)
            -   [Setup Application](#org2d6817d)
    5.  [Configure and Start Minishift](#org0f33ff5)
        -   [Configure Minishift](#orgb60477d)
        -   [Create new Minishift Profile - opendevstack](#orgc516ec4)
        -   [Start Minishift](#org6b5b963)
        -   [Configure the path for the OC CLI](#org4f63911)
        -   [Login with the CLI](#org8c945af)
        -   [Setup the base template project](#org8ea23be)
        -   [Adjust user rights for the developer user](#org52753b6)
        -   [Create service account for deployment](#org8ce79a6)
        -   [Install Minishift certificate on Atlassian server](#org0818fdd)
        -   [Clone the ods-project-quickstarters from your Bitbucket server](#orgf5dc849)
    6.  [Prepare environment settings](#orgd8061d6)
    7.  [Setup and Configure Nexus3](#orga5290e5)
        -   [Configure Repository Manager](#org1f7027e)
        -   [Configure repositories](#orgfa7425c)
        -   [Configure user and roles](#org78566fa)
    8.  [Configure CD user](#org7709d1b)
    9.  [Import base templates](#orgd788c87)
        -   [Preparation](#org221fece)
        -   [Upload](#orgfc4e5c2)
    10. [Create secrets inside the CD project](#org4256695)
    11. [Setup and configure Sonarqube](#org6390f16)
    12. [Explain all variables](#org846e683)
    13. [Prepare CD project for Jenkins](#orgc3eec99)
    14. [Prepare Jenkins slave docker images](#org3dcf614)
        -   [Maven](#org0d8fc54)
        -   [Python](#org4e375bc)
        -   [scala](#org84c505a)
        -   [nodejs8-angular](#org447071f)
    15. [Prepare Docker Registry](#org83bdeca)
    16. [Prepare Rundeck and required Dockerfiles](#org0a3d366)
        -   [Create Quickstarters project](#orgf858893)
        -   [Openshift API token](#orge5dce0b)
        -   [CD user private key](#org80c8bd9)
        -   [Configure SCM plugins](#org5cc0557)
            -   [Setup Import plugin](#org6090960)
            -   [Setup Export plugin](#orgd164e8c)
        -   [Update the job properties](#orgdd44709)
    17. [Add shared images](#org8a468c4)
    18. [Configure provisioning application](#orgdd31347)
    19. [Setup within Openshift](#org777104a)
    20. [Try out the OpenDevStack](#orgb66d458)
2.  [Console URLs](#org9b5f23c)
3.  [OpenDevStack - Products and Description](#org6e6b642)
    1.  [Crowd](#orgf64edb4)
        -   [Centralized identity management](#org550df25)
            -   [Single sign-on (SSO)](#org7191086)
            -   [Centralize multiple directories](#org6c276b8)
    2.  [Confluence](#org9d456df)
        -   [Content collaboration software that changes how modern teams work](#orgac035d4)
            -   [Project collaboration](#orgd3365d0)
            -   [Knowledge base](#org514a9cc)
            -   [Team documentation](#org4e3c1b3)
            -   [Document management](#org33dcc5c)
            -   [Page and file versioning](#orgefdad37)
            -   [Templates](#orgd857d45)
            -   [Permissions](#org4b68610)
            -   [Jira](#orgf55d1d8)
    3.  [Jira](#org7330be9)
        -   [Project management tool for agile teams](#org056d0a5)
            -   [Scrum boards](#orgb4ecfc7)
            -   [Kanban boards](#org25d9466)
            -   [Agile reporting](#org44dac16)
            -   [Roadmaps](#org2d213c2)
            -   [Customizable workflows](#orgd161513)
            -   [Developer tool integrations](#org2538304)
            -   [Custom filters](#org787c439)
            -   [Rich APIs](#orga66f003)
    4.  [Jira and Confluence](#org8613ab4)
    5.  [BitBucket](#org46140c7)
        -   [More than just Git code management](#org1ef5e7c)
            -   [Free unlimited private repositories](#orgc58828f)
            -   [Best-in-class Jira & Trello integration](#org9eae5f5)
            -   [Built-in Continuous Delivery](#org66166dd)
            -   [Code Collaboration](#org7635266)
            -   [Continuous Delivery](#orgd736eb2)
            -   [Security](#orgad72c45)
    6.  [Rundeck](#org1af7ce5)
        -   [Manage automation from legacy to cloud services](#orgd2d2d6d)
            -   [Scale Ops.](#org713093d)
            -   [Eliminate the wait.](#orgaed67ac)
            -   [Stay in control.](#org3d8cd96)
            -   [Be audit-ready.](#org6ac8df8)
            -   [Create a job](#orgb9ee7fa)
            -   [Safely hand off the job to others](#orgd76e1cb)
            -   [Enjoy being the Hero.](#org45e8120)
    7.  [Nexus Repository](#org2103913)
        -   [Flow control for binaries, build artifacts, and release candidates.](#org1a727ff)
            -   [The perfect system of record for all your software parts](#org5305682)
            -   [Universal support for all your favorite formats and tools.](#org0892099)
    8.  [SonarQube](#org139f6fd)
        -   [Continuous Code Quality](#orgfb56de7)
            -   [Continuous Inspection](#org9e67863)
            -   [Detect Tricky Issues](#org1067e1a)
            -   [Centralize Quality](#org0a4f05a)
            -   [DevOps Integration](#org43294d8)
4.  [Install convenience environment](#org4608960)
    1.  [atlassian1](#org87d266a)
    2.  [atlcon](#org13c4aee)
5.  [Installation and Runtime Topology](#orgd5ee7ed)
    1.  [Atlassian products](#orgc292999)
        -   [Installation directory (/opt/atlassian)](#org418a62f)
        -   [Crowd](#orgfa1c006)
        -   [Confluence](#org15f026d)
        -   [Jira](#org7bf33bc)
        -   [BitBucket](#org8e35a84)
        -   [Home directory structure (/srv/atlassian)](#orgc4e5d69)
            -   [Atlassian products](#orgec66ecb)
            -   [Crowd](#org12dd7e7)
            -   [Confluence](#org65c5988)
            -   [Jira](#org2f3277c)
            -   [BitBucket](#org84e1f99)
        -   [User home directories](#orgb3f7038)
    2.  [Rundeck](#org5f133e0)
    3.  [Docker](#org470ad84)
        -   [Nexus3](#orgb530457)
        -   [SonarQube](#orgb0b5fce)
            -   [SonarQube-PostGreSQL](#orgb7bb123)
    4.  [PostGreSQL](#org106f383)
    5.  [Processes](#orge023282)
6.  [ToDo](#org1eed050)
    1.  [Configuring Minishift](#org96aacfa)
    2.  [Using Minishift - An OpenShift Origin All-in-One VM](#orga88857b)
    3.  [Problems when starting](#org37597a5)



<a id="org934dceb"></a>

# OpenDevStack

<http://www.opendevstack.org/doc/getting-started>


<a id="orgfadc273"></a>

## Introduction

Welcome to the OpenDevStack. The OpenDevStack is a framework to help in setting
up a project infrastructure and continuous delivery processes on OpenShift and
Atlassian toolstack with one click. This guide shall help you to setup the
OpenDevStack, so you can work with it and test it in a local environment
setup. The steps for the setup can also be adapted for running the OpenDevstack
with an existing OpenShift installation or to connect it with your Atlassian
tools, if you use Atlassian Crowd as SSO provider.

Important: The credentials provided in the guide are only meant to be used
within the local test installation. For use in production you will have to
customize paths, URLs and credentials!


<a id="org7ea47a5"></a>

## Requirements

The following requirements have to be met to setup a local environment


<a id="org566c5b5"></a>

### Git

We use Git as code repository, so you have to be familiar to work with Git.


<a id="org62742c1"></a>

### Vagrant

The OpenDevStack uses **Vagrant** to provide a sample infrastructure for the
**Atlassian tools**, **Rundeck** (an operations management platform) and a so called
**Ansible** controller, a VM, where you can run Ansible scripts against the
Atlassian VM. It is recommended to use the latest Vagrant version available from
the HashiCorp Vagrant page.


<a id="orge4eb735"></a>

### Atlassian tools licenses

To use the Atlassian tools you need a license to run them. For testing and
evaluation Atlassian provides evalutation licenses, which you can get on the My
Atlassian license page. Here you have to keep in mind, that you have to
register, if you don’t have an Atlassian account. The registration is for
free. You need licenses for the following products:

-   Bitbucket
-   Jira
-   Confluence
-   Crowd

The evaluation licenses are valid for 30 days from the date of purchase. If you
need a server id, this will be provided by the tools within the installation, so
you are able to inlcude the licenses within the installation wizards of the
tools, after the base setup provided by the Ansible scripts.


<a id="org0c08e64"></a>

### Minishift

The provided provision application and Rundeck jobs work with links, which are
designed to connect to a installed and configured Minishift instance. Minishift
is a tool provided by Redhat to run OpenShift locally by providing a single-node
OpenShift cluster inside a VM. Information, how to setup Minishift can be found
at the Minishift Getting Started guide. Currently the OpenDevStack works with
Openshift 3.9.0.


<a id="org49a64d6"></a>

### Cygwin / Linux

You must have the possibility to run bash scripts to import the provided
OpenShift templates. On Linux systems you can use these scripts out-of-the box,
on Windows systems you will have to install either a bash port for Windows like
Cygwin. For Windows, our recommendation is to use Cygwin for starting a
minishift cluster and further configuration. Make sure to select the curl
package under the “net” category when installing cygwin.

minishift will use the .kube/config mechanism to configure access to the
kubernetes cluster. Minishift will place the config in the Windows home
directory. To make this work under cygwin, we will point the cygwin home
directory to the Windows Home directory. This can easily be achieved by changing
the db\_home entry in /etc/nsswitch.conf to

dbhome: windows

or

dbhome: /%H

This is described in the cygwin user guide.


<a id="org705f4c4"></a>

### Ansible

The OpenDevStack uses Ansible to install and configure the necessary software
for the enabling stack, so it’s recommended to get familiar with its core
concepts and usage. Also credentials are stored within an Ansible vault, so even
if you commit them in a public repository they are not available unless you know
the vault password.


<a id="orgf14981b"></a>

## Setup your local environment

From now on we assume, you work from a Bash (Cygwin / Linux).


<a id="org945eedb"></a>

### Install tailor Utility

    choco info tailor

    # Chocolatey v0.10.11
    # 0 packages found.

    cd /misc/download

    curl -LO "https://github.com/opendevstack/tailor/releases/download/v0.9.0/tailor_windows_amd64.exe"

    #   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    #                                  Dload  Upload   Total   Spent    Left  Speed
    # 100   615    0   615    0     0   1040      0 --:--:-- --:--:-- --:--:--  1040
    # 100 7673k  100 7673k    0     0  2464k      0  0:00:03  0:00:03 --:--:-- 4858k

We'll be renaming to **oc-tailer** in order to not conflict with the cygwin
version of **tailer**.

    mv /misc/download/tailor_windows_amd64.exe /usr/local/bin/oc-tailor

    chmod 755 /usr/local/bin/oc-tailor

    oc-tailor

    # usage: tailor [<flags>] <command> [<args> ...]
    # 
    # Tailor - Infrastructure as Code for OpenShift
    # 
    # Flags:
    #       --help                   Show context-sensitive help (also try --help-long
    #                                and --help-man).
    #   -v, --verbose                Enable verbose output.
    #   -d, --debug                  Enable debug output (implies verbose).
    #       --non-interactive        Disable interactive mode.
    #   -f, --file="Tailorfile"      Tailorfile with flags.
    #   -n, --namespace=NAMESPACE    Namespace (omit to use current)
    #   -l, --selector=SELECTOR      Selector (label query) to filter on
    #   -t, --template-dir=. ...     Path to local templates
    #   -p, --param-dir=. ...        Path to param files for local templates
    #       --public-key-dir="."     Path to public key files
    #       --private-key="private.key"  
    #                                Path to private key file
    #       --passphrase=PASSPHRASE  Passphrase to unlock key
    # 
    # Commands:
    #   help [<command>...]
    #     Show help.
    # 
    #   version
    #     Show version
    # 
    #   status [<flags>] [<resource>]
    #     Show diff between remote and local
    # 
    #   update [<flags>] [<resource>]
    #     Update remote with local
    # 
    #   export [<resource>]
    #     Export remote state as template
    # 
    #   secrets edit <file>
    #     Edit param file
    # 
    #   secrets re-encrypt [<file>]
    #     Re-Encrypt param file(s)
    # 
    #   secrets reveal <file>
    #     Show param file contents with revealed secrets
    # 
    #   secrets generate-key [<flags>] <email>
    #     Generate new keypair

    oc-tailor version

    # 0.9.0


<a id="orgd3f746d"></a>

### Prepare infrastructure


<a id="org606ae55"></a>

#### Clone opendevstack Project

First you have to clone the ods-core repository.

    mkdir -p /misc/vagrant/opendevstack && cd /misc/vagrant/opendevstack

    git clone https://github.com/opendevstack/ods-core.git

    # Cloning into 'ods-core'...
    # remote: Enumerating objects: 491, done.        
    # remote: Total 491 (delta 0), reused 0 (delta 0), pack-reused 491        
    # Receiving objects: 100% (491/491), 43.58 MiB | 3.15 MiB/s, done.
    # Resolving deltas: 100% (129/129), done.


<a id="org738232d"></a>

#### Create environment with Vagrant

Navigate to the folder **ods-core > infrastructure-setup**. There you will find a
Vagrant file. You can start the infrastructure provisioning and setup by using

    cd /misc/vagrant/opendevstack/ods-core/infrastructure-setup

    vagrant up

    # Handling vm with hostname [atlassian1] and IP [192.168.56.31]
    # Bringing machine 'atlassian1' up with 'virtualbox' provider...
    # Bringing machine 'atlcon' up with 'virtualbox' provider...
    # ==> atlcon: Importing base box 'bento/centos-7.3'...
    # ==> atlcon: Matching MAC address for NAT networking...
    # ==> atlcon: Setting the name of the VM: atlcon
    # ==> atlcon: Fixed port collision for 22 => 2222. Now on port 2200.
    # ==> atlcon: Clearing any previously set network interfaces...
    # ==> atlcon: Preparing network interfaces based on configuration...
    #     atlcon: Adapter 1: nat
    #     atlcon: Adapter 2: hostonly
    # ==> atlcon: Forwarding ports...
    #     atlcon: 22 (guest) => 2200 (host) (adapter 1)
    # ==> atlcon: Running 'pre-boot' VM customizations...
    # ==> atlcon: Booting VM...
    # ==> atlcon: Waiting for machine to boot. This may take a few minutes...
    #     atlcon: SSH address: 127.0.0.1:2200
    #     atlcon: SSH username: vagrant
    #     atlcon: SSH auth method: private key
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: 
    #     atlcon: Vagrant insecure key detected. Vagrant will automatically replace
    #     atlcon: this with a newly generated keypair for better security.
    #     atlcon: 
    #     atlcon: Inserting generated public key within guest...
    #     atlcon: Removing insecure key from the guest if it's present...
    #     atlcon: Key inserted! Disconnecting and reconnecting using new SSH key...
    # ==> atlcon: Machine booted and ready!
    # [atlcon] GuestAdditions versions on your host (5.2.20) and guest (5.1.26) do not match.
    # Loaded plugins: fastestmirror
    # Determining fastest mirrors
    #  * base: mirror.alpha-labs.net
    #  * extras: mirror.alpha-labs.net
    #  * updates: ftp.plusline.net
    # No package kernel-devel-3.10.0-514.26.2.el7.x86_64 available.
    # Package 1:make-3.82-23.el7.x86_64 already installed and latest version
    # Package bzip2-1.0.6-13.el7.x86_64 already installed and latest version
    # Resolving Dependencies
    # --> Running transaction check
    # ---> Package binutils.x86_64 0:2.25.1-22.base.el7 will be updated
    # ---> Package binutils.x86_64 0:2.27-28.base.el7_5.1 will be an update
    # ---> Package gcc.x86_64 0:4.8.5-28.el7_5.1 will be installed
    # --> Processing Dependency: libgomp = 4.8.5-28.el7_5.1 for package: gcc-4.8.5-28.el7_5.1.x86_64
    # --> Processing Dependency: cpp = 4.8.5-28.el7_5.1 for package: gcc-4.8.5-28.el7_5.1.x86_64
    # --> Processing Dependency: libgcc >= 4.8.5-28.el7_5.1 for package: gcc-4.8.5-28.el7_5.1.x86_64
    # --> Processing Dependency: glibc-devel >= 2.2.90-12 for package: gcc-4.8.5-28.el7_5.1.x86_64
    # ---> Package kernel-devel.x86_64 0:3.10.0-862.14.4.el7 will be installed
    # ---> Package perl.x86_64 4:5.16.3-291.el7 will be updated
    # ---> Package perl.x86_64 4:5.16.3-292.el7 will be an update
    # --> Processing Dependency: perl-libs = 4:5.16.3-292.el7 for package: 4:perl-5.16.3-292.el7.x86_64
    # --> Running transaction check
    # ---> Package cpp.x86_64 0:4.8.5-28.el7_5.1 will be installed
    # ---> Package glibc-devel.x86_64 0:2.17-222.el7 will be installed
    # --> Processing Dependency: glibc-headers = 2.17-222.el7 for package: glibc-devel-2.17-222.el7.x86_64
    # --> Processing Dependency: glibc = 2.17-222.el7 for package: glibc-devel-2.17-222.el7.x86_64
    # --> Processing Dependency: glibc-headers for package: glibc-devel-2.17-222.el7.x86_64
    # ---> Package libgcc.x86_64 0:4.8.5-11.el7 will be updated
    # ---> Package libgcc.x86_64 0:4.8.5-28.el7_5.1 will be an update
    # ---> Package libgomp.x86_64 0:4.8.5-11.el7 will be updated
    # ---> Package libgomp.x86_64 0:4.8.5-28.el7_5.1 will be an update
    # ---> Package perl-libs.x86_64 4:5.16.3-291.el7 will be updated
    # ---> Package perl-libs.x86_64 4:5.16.3-292.el7 will be an update
    # --> Running transaction check
    # ---> Package glibc.x86_64 0:2.17-157.el7_3.5 will be updated
    # --> Processing Dependency: glibc = 2.17-157.el7_3.5 for package: glibc-common-2.17-157.el7_3.5.x86_64
    # ---> Package glibc.x86_64 0:2.17-222.el7 will be an update
    # ---> Package glibc-headers.x86_64 0:2.17-222.el7 will be installed
    # --> Processing Dependency: kernel-headers >= 2.2.1 for package: glibc-headers-2.17-222.el7.x86_64
    # --> Processing Dependency: kernel-headers for package: glibc-headers-2.17-222.el7.x86_64
    # --> Running transaction check
    # ---> Package glibc-common.x86_64 0:2.17-157.el7_3.5 will be updated
    # ---> Package glibc-common.x86_64 0:2.17-222.el7 will be an update
    # ---> Package kernel-headers.x86_64 0:3.10.0-862.14.4.el7 will be installed
    # --> Finished Dependency Resolution
    # 
    # Dependencies Resolved
    # 
    # ================================================================================
    #  Package             Arch        Version                     Repository    Size
    # ================================================================================
    # Installing:
    #  gcc                 x86_64      4.8.5-28.el7_5.1            updates       16 M
    #  kernel-devel        x86_64      3.10.0-862.14.4.el7         updates       16 M
    # Updating:
    #  binutils            x86_64      2.27-28.base.el7_5.1        updates      5.9 M
    #  perl                x86_64      4:5.16.3-292.el7            base         8.0 M
    # Installing for dependencies:
    #  cpp                 x86_64      4.8.5-28.el7_5.1            updates      5.9 M
    #  glibc-devel         x86_64      2.17-222.el7                base         1.1 M
    #  glibc-headers       x86_64      2.17-222.el7                base         678 k
    #  kernel-headers      x86_64      3.10.0-862.14.4.el7         updates      7.1 M
    # Updating for dependencies:
    #  glibc               x86_64      2.17-222.el7                base         3.6 M
    #  glibc-common        x86_64      2.17-222.el7                base          11 M
    #  libgcc              x86_64      4.8.5-28.el7_5.1            updates      101 k
    #  libgomp             x86_64      4.8.5-28.el7_5.1            updates      156 k
    #  perl-libs           x86_64      4:5.16.3-292.el7            base         688 k
    # 
    # Transaction Summary
    # ================================================================================
    # Install  2 Packages (+4 Dependent packages)
    # Upgrade  2 Packages (+5 Dependent packages)
    # 
    # Total download size: 77 M
    # Downloading packages:
    # Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
    # --------------------------------------------------------------------------------
    # Total                                              5.6 MB/s |  77 MB  00:13     
    # Running transaction check
    # Running transaction test
    # Transaction test succeeded
    # Running transaction
    #   Updating   : libgcc-4.8.5-28.el7_5.1.x86_64                              1/20 
    #   Updating   : glibc-2.17-222.el7.x86_64                                   2/20 
    # warning: /etc/nsswitch.conf created as /etc/nsswitch.conf.rpmnew
    #   Updating   : glibc-common-2.17-222.el7.x86_64                            3/20 
    #   Updating   : 4:perl-libs-5.16.3-292.el7.x86_64                           4/20 
    #   Updating   : 4:perl-5.16.3-292.el7.x86_64                                5/20 
    #   Updating   : libgomp-4.8.5-28.el7_5.1.x86_64                             6/20 
    #   Installing : cpp-4.8.5-28.el7_5.1.x86_64                                 7/20 
    #   Updating   : binutils-2.27-28.base.el7_5.1.x86_64                        8/20 
    #   Installing : kernel-headers-3.10.0-862.14.4.el7.x86_64                   9/20 
    #   Installing : glibc-headers-2.17-222.el7.x86_64                          10/20 
    #   Installing : glibc-devel-2.17-222.el7.x86_64                            11/20 
    #   Installing : gcc-4.8.5-28.el7_5.1.x86_64                                12/20 
    #   Installing : kernel-devel-3.10.0-862.14.4.el7.x86_64                    13/20 
    #   Cleanup    : 4:perl-libs-5.16.3-291.el7.x86_64                          14/20 
    #   Cleanup    : 4:perl-5.16.3-291.el7.x86_64                               15/20 
    #   Cleanup    : binutils-2.25.1-22.base.el7.x86_64                         16/20 
    #   Cleanup    : libgomp-4.8.5-11.el7.x86_64                                17/20 
    #   Cleanup    : glibc-common-2.17-157.el7_3.5.x86_64                       18/20 
    #   Cleanup    : glibc-2.17-157.el7_3.5.x86_64                              19/20 
    #   Cleanup    : libgcc-4.8.5-11.el7.x86_64                                 20/20 
    #   Verifying  : libgomp-4.8.5-28.el7_5.1.x86_64                             1/20 
    #   Verifying  : glibc-common-2.17-222.el7.x86_64                            2/20 
    #   Verifying  : 4:perl-5.16.3-292.el7.x86_64                                3/20 
    #   Verifying  : libgcc-4.8.5-28.el7_5.1.x86_64                              4/20 
    #   Verifying  : gcc-4.8.5-28.el7_5.1.x86_64                                 5/20 
    #   Verifying  : glibc-devel-2.17-222.el7.x86_64                             6/20 
    #   Verifying  : kernel-devel-3.10.0-862.14.4.el7.x86_64                     7/20 
    #   Verifying  : cpp-4.8.5-28.el7_5.1.x86_64                                 8/20 
    #   Verifying  : glibc-headers-2.17-222.el7.x86_64                           9/20 
    #   Verifying  : kernel-headers-3.10.0-862.14.4.el7.x86_64                  10/20 
    #   Verifying  : 4:perl-libs-5.16.3-292.el7.x86_64                          11/20 
    #   Verifying  : glibc-2.17-222.el7.x86_64                                  12/20 
    #   Verifying  : binutils-2.27-28.base.el7_5.1.x86_64                       13/20 
    #   Verifying  : glibc-2.17-157.el7_3.5.x86_64                              14/20 
    #   Verifying  : glibc-common-2.17-157.el7_3.5.x86_64                       15/20 
    #   Verifying  : 4:perl-5.16.3-291.el7.x86_64                               16/20 
    #   Verifying  : binutils-2.25.1-22.base.el7.x86_64                         17/20 
    #   Verifying  : libgcc-4.8.5-11.el7.x86_64                                 18/20 
    #   Verifying  : libgomp-4.8.5-11.el7.x86_64                                19/20 
    #   Verifying  : 4:perl-libs-5.16.3-291.el7.x86_64                          20/20 
    # 
    # Installed:
    #   gcc.x86_64 0:4.8.5-28.el7_5.1    kernel-devel.x86_64 0:3.10.0-862.14.4.el7   
    # 
    # Dependency Installed:
    #   cpp.x86_64 0:4.8.5-28.el7_5.1                                                 
    #   glibc-devel.x86_64 0:2.17-222.el7                                             
    #   glibc-headers.x86_64 0:2.17-222.el7                                           
    #   kernel-headers.x86_64 0:3.10.0-862.14.4.el7                                   
    # 
    # Updated:
    #   binutils.x86_64 0:2.27-28.base.el7_5.1      perl.x86_64 4:5.16.3-292.el7     
    # 
    # Dependency Updated:
    #   glibc.x86_64 0:2.17-222.el7            glibc-common.x86_64 0:2.17-222.el7     
    #   libgcc.x86_64 0:4.8.5-28.el7_5.1       libgomp.x86_64 0:4.8.5-28.el7_5.1      
    #   perl-libs.x86_64 4:5.16.3-292.el7     
    # 
    # Complete!
    # Copy iso file C:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
    # Mounting Virtualbox Guest Additions ISO to: /mnt
    # mount: /dev/loop0 is write-protected, mounting read-only
    # Installing Virtualbox Guest Additions 5.2.20 - guest version is 5.1.26
    # Verifying archive integrity... All good.
    # Uncompressing VirtualBox 5.2.20 Guest Additions for Linux........
    # VirtualBox Guest Additions installer
    # Removing installed version 5.1.26 of VirtualBox Guest Additions...
    # Copying additional installer modules ...
    # Installing additional modules ...
    # VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel modules.  This may take a while.
    # 
    # This system is currently not set up to build kernel modules.
    # Please install the Linux kernel "header" files matching the current kernel
    # for adding new hardware support to the system.
    # The distribution packages containing the headers are probably:
    #     kernel-devel kernel-devel-3.10.0-514.26.2.el7.x86_64
    # VirtualBox Guest Additions: Running kernel modules will not be replaced until the system is restarted
    # VirtualBox Guest Additions: Starting.
    # VirtualBox Guest Additions: modprobe vboxsf failed
    # An error occurred during installation of VirtualBox Guest Additions 5.2.20. Some functionality may not work as intended.
    # In most cases it is OK that the "Window System drivers" installation failed.
    # Redirecting to /bin/systemctl start  vboxadd.service
    # Redirecting to /bin/systemctl start  vboxadd-service.service
    # Job for vboxadd-service.service failed because the control process exited with error code. See "systemctl status vboxadd-service.service" and "journalctl -xe" for details.
    # Unmounting Virtualbox Guest Additions ISO from: /mnt
    # ==> atlcon: Checking for guest additions in VM...
    #     atlcon: The guest additions on this VM do not match the installed version of
    #     atlcon: VirtualBox! In most cases this is fine, but in rare cases it can
    #     atlcon: prevent things such as shared folders from working properly. If you see
    #     atlcon: shared folder errors, please make sure the guest additions within the
    #     atlcon: virtual machine match the version of VirtualBox you have installed on
    #     atlcon: your host and reload your VM.
    #     atlcon: 
    #     atlcon: Guest Additions Version: 5.1.26
    #     atlcon: VirtualBox Version: 5.2
    # ==> atlcon: Setting hostname...
    # ==> atlcon: Configuring and enabling network interfaces...
    #     atlcon: SSH address: 127.0.0.1:2200
    #     atlcon: SSH username: vagrant
    #     atlcon: SSH auth method: private key
    # ==> atlcon: Mounting shared folders...
    #     atlcon: /vagrant => D:/misc/vagrant/opendevstack/ods-core/infrastructure-setup
    # Vagrant was unable to mount VirtualBox shared folders. This is usually
    # because the filesystem "vboxsf" is not available. This filesystem is
    # made available via the VirtualBox Guest Additions and kernel module.
    # Please verify that these guest additions are properly installed in the
    # guest. This is not a bug in Vagrant and is usually caused by a faulty
    # Vagrant box. For context, the command attempted was:
    # 
    # mount -t vboxsf -o dmode=775,fmode=664,uid=1000,gid=1000 vagrant /vagrant
    # 
    # The error output from the command was:
    # 
    # /sbin/mount.vboxsf: mounting failed with the error: No such device

    cp -v Vagrantfile Vagrantfile.orig

    sed -i '/Vagrant.configure(2) do/a config.vbguest.auto_update = false' Vagrantfile

    vagrant up

    # Handling vm with hostname [atlassian1] and IP [192.168.56.31]
    # Bringing machine 'atlassian1' up with 'virtualbox' provider...
    # Bringing machine 'atlcon' up with 'virtualbox' provider...
    # ==> atlassian1: Importing base box 'bento/centos-7.3'...
    # ==> atlassian1: Matching MAC address for NAT networking...
    # ==> atlassian1: Setting the name of the VM: atlassian1
    # ==> atlassian1: Clearing any previously set network interfaces...
    # ==> atlassian1: Preparing network interfaces based on configuration...
    #     atlassian1: Adapter 1: nat
    #     atlassian1: Adapter 2: hostonly
    # ==> atlassian1: Forwarding ports...
    #     atlassian1: 22 (guest) => 2222 (host) (adapter 1)
    # ==> atlassian1: Running 'pre-boot' VM customizations...
    # ==> atlassian1: Booting VM...
    # ==> atlassian1: Waiting for machine to boot. This may take a few minutes...
    #     atlassian1: SSH address: 127.0.0.1:2222
    #     atlassian1: SSH username: vagrant
    #     atlassian1: SSH auth method: private key
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Remote connection disconnect. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Remote connection disconnect. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Remote connection disconnect. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Remote connection disconnect. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: Warning: Connection aborted. Retrying...
    #     atlassian1: Warning: Connection reset. Retrying...
    #     atlassian1: 
    #     atlassian1: Vagrant insecure key detected. Vagrant will automatically replace
    #     atlassian1: this with a newly generated keypair for better security.
    #     atlassian1: 
    #     atlassian1: Inserting generated public key within guest...
    #     atlassian1: Removing insecure key from the guest if it's present...
    #     atlassian1: Key inserted! Disconnecting and reconnecting using new SSH key...
    # ==> atlassian1: Machine booted and ready!
    # ==> atlassian1: Checking for guest additions in VM...
    #     atlassian1: The guest additions on this VM do not match the installed version of
    #     atlassian1: VirtualBox! In most cases this is fine, but in rare cases it can
    #     atlassian1: prevent things such as shared folders from working properly. If you see
    #     atlassian1: shared folder errors, please make sure the guest additions within the
    #     atlassian1: virtual machine match the version of VirtualBox you have installed on
    #     atlassian1: your host and reload your VM.
    #     atlassian1: 
    #     atlassian1: Guest Additions Version: 5.1.26
    #     atlassian1: VirtualBox Version: 5.2
    # ==> atlassian1: Setting hostname...
    # ==> atlassian1: Configuring and enabling network interfaces...
    #     atlassian1: SSH address: 127.0.0.1:2222
    #     atlassian1: SSH username: vagrant
    #     atlassian1: SSH auth method: private key
    # ==> atlassian1: Mounting shared folders...
    #     atlassian1: /vagrant => D:/misc/vagrant/opendevstack/ods-core/infrastructure-setup
    # ==> atlcon: Importing base box 'bento/centos-7.3'...
    # ==> atlcon: Matching MAC address for NAT networking...
    # ==> atlcon: Setting the name of the VM: atlcon
    # ==> atlcon: Fixed port collision for 22 => 2222. Now on port 2200.
    # ==> atlcon: Clearing any previously set network interfaces...
    # ==> atlcon: Preparing network interfaces based on configuration...
    #     atlcon: Adapter 1: nat
    #     atlcon: Adapter 2: hostonly
    # ==> atlcon: Forwarding ports...
    #     atlcon: 22 (guest) => 2200 (host) (adapter 1)
    # ==> atlcon: Running 'pre-boot' VM customizations...
    # ==> atlcon: Booting VM...
    # ==> atlcon: Waiting for machine to boot. This may take a few minutes...
    #     atlcon: SSH address: 127.0.0.1:2200
    #     atlcon: SSH username: vagrant
    #     atlcon: SSH auth method: private key
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Connection reset. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: Warning: Remote connection disconnect. Retrying...
    #     atlcon: Warning: Connection aborted. Retrying...
    #     atlcon: 
    #     atlcon: Vagrant insecure key detected. Vagrant will automatically replace
    #     atlcon: this with a newly generated keypair for better security.
    #     atlcon: 
    #     atlcon: Inserting generated public key within guest...
    #     atlcon: Removing insecure key from the guest if it's present...
    #     atlcon: Key inserted! Disconnecting and reconnecting using new SSH key...
    # ==> atlcon: Machine booted and ready!
    # ==> atlcon: Checking for guest additions in VM...
    #     atlcon: The guest additions on this VM do not match the installed version of
    #     atlcon: VirtualBox! In most cases this is fine, but in rare cases it can
    #     atlcon: prevent things such as shared folders from working properly. If you see
    #     atlcon: shared folder errors, please make sure the guest additions within the
    #     atlcon: virtual machine match the version of VirtualBox you have installed on
    #     atlcon: your host and reload your VM.
    #     atlcon: 
    #     atlcon: Guest Additions Version: 5.1.26
    #     atlcon: VirtualBox Version: 5.2
    # ==> atlcon: Setting hostname...
    # ==> atlcon: Configuring and enabling network interfaces...
    #     atlcon: SSH address: 127.0.0.1:2200
    #     atlcon: SSH username: vagrant
    #     atlcon: SSH auth method: private key
    # ==> atlcon: Mounting shared folders...
    #     atlcon: /vagrant => D:/misc/vagrant/opendevstack/ods-core/infrastructure-setup
    #     atlcon: /vagrant/.vagrant => D:/misc/vagrant/opendevstack/ods-core/infrastructure-setup/.vagrant
    # ==> atlcon: Running provisioner: shell...
    #     atlcon: Running: D:/tmp/vagrant-shell20181116-20332-im1984.sh
    #     atlcon: installing ansible
    #     atlcon: Loaded plugins: fastestmirror
    #     atlcon: Determining fastest mirrors
    #     atlcon:  * base: ftp.plusline.net
    #     atlcon:  * extras: ftp.rz.uni-frankfurt.de
    #     atlcon:  * updates: mirror.cuegee.de
    #     atlcon: Resolving Dependencies
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package epel-release.noarch 0:7-11 will be installed
    #     atlcon: --> Finished Dependency Resolution
    #     atlcon: 
    #     atlcon: Dependencies Resolved
    #     atlcon: 
    #     atlcon: ================================================================================
    #     atlcon:  Package                Arch             Version         Repository        Size
    #     atlcon: ================================================================================
    #     atlcon: Installing:
    #     atlcon:  epel-release           noarch           7-11            extras            15 k
    #     atlcon: 
    #     atlcon: Transaction Summary
    #     atlcon: ================================================================================
    #     atlcon: Install  1 Package
    #     atlcon: 
    #     atlcon: Total download size: 15 k
    #     atlcon: Installed size: 24 k
    #     atlcon: Downloading packages:
    #     atlcon: Running transaction check
    #     atlcon: Running transaction test
    #     atlcon: Transaction test succeeded
    #     atlcon: Running transaction
    #     atlcon:   Installing : epel-release-7-11.noarch                                     1/1
    #     atlcon:  
    #     atlcon:   Verifying  : epel-release-7-11.noarch                                     1/1
    #     atlcon:  
    #     atlcon: 
    #     atlcon: Installed:
    #     atlcon:   epel-release.noarch 0:7-11                                                    
    #     atlcon: Complete!
    #     atlcon: Loaded plugins: fastestmirror
    #     atlcon: Loading mirror speeds from cached hostfile
    #     atlcon:  * base: ftp.plusline.net
    #     atlcon:  * epel: mirror.infonline.de
    #     atlcon:  * extras: ftp.rz.uni-frankfurt.de
    #     atlcon:  * updates: mirror.cuegee.de
    #     atlcon: Resolving Dependencies
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package ansible.noarch 0:2.7.1-1.el7 will be installed
    #     atlcon: --> Processing Dependency: sshpass for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python2-jmespath for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-six for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-setuptools for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-paramiko for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-keyczar for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-jinja2 for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-httplib2 for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-crypto for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: PyYAML for package: ansible-2.7.1-1.el7.noarch
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package PyYAML.x86_64 0:3.10-11.el7 will be installed
    #     atlcon: --> Processing Dependency: libyaml-0.so.2()(64bit) for package: PyYAML-3.10-11.el7.x86_64
    #     atlcon: ---> Package python-httplib2.noarch 0:0.9.2-1.el7 will be installed
    #     atlcon: ---> Package python-jinja2.noarch 0:2.7.2-2.el7 will be installed
    #     atlcon: --> Processing Dependency: python-babel >= 0.8 for package: python-jinja2-2.7.2-2.el7.noarch
    #     atlcon: --> Processing Dependency: python-markupsafe for package: python-jinja2-2.7.2-2.el7.noarch
    #     atlcon: ---> Package python-keyczar.noarch 0:0.71c-2.el7 will be installed
    #     atlcon: --> Processing Dependency: python-pyasn1 for package: python-keyczar-0.71c-2.el7.noarch
    #     atlcon: ---> Package python-paramiko.noarch 0:2.1.1-4.el7 will be installed
    #     atlcon: --> Processing Dependency: python-cryptography for package: python-paramiko-2.1.1-4.el7.noarch
    #     atlcon: ---> Package python-setuptools.noarch 0:0.9.8-7.el7 will be installed
    #     atlcon: --> Processing Dependency: python-backports-ssl_match_hostname for package: python-setuptools-0.9.8-7.el7.noarch
    #     atlcon: ---> Package python-six.noarch 0:1.9.0-2.el7 will be installed
    #     atlcon: ---> Package python2-crypto.x86_64 0:2.6.1-15.el7 will be installed
    #     atlcon: --> Processing Dependency: libtomcrypt.so.0()(64bit) for package: python2-crypto-2.6.1-15.el7.x86_64
    #     atlcon: ---> Package python2-jmespath.noarch 0:0.9.0-3.el7 will be installed
    #     atlcon: ---> Package sshpass.x86_64 0:1.06-2.el7 will be installed
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package libtomcrypt.x86_64 0:1.17-26.el7 will be installed
    #     atlcon: --> Processing Dependency: libtommath >= 0.42.0 for package: libtomcrypt-1.17-26.el7.x86_64
    #     atlcon: --> Processing Dependency: libtommath.so.0()(64bit) for package: libtomcrypt-1.17-26.el7.x86_64
    #     atlcon: ---> Package libyaml.x86_64 0:0.1.4-11.el7_0 will be installed
    #     atlcon: ---> Package python-babel.noarch 0:0.9.6-8.el7 will be installed
    #     atlcon: ---> Package python-backports-ssl_match_hostname.noarch 0:3.5.0.1-1.el7 will be installed
    #     atlcon: --> Processing Dependency: python-ipaddress for package: python-backports-ssl_match_hostname-3.5.0.1-1.el7.noarch
    #     atlcon: --> Processing Dependency: python-backports for package: python-backports-ssl_match_hostname-3.5.0.1-1.el7.noarch
    #     atlcon: ---> Package python-markupsafe.x86_64 0:0.11-10.el7 will be installed
    #     atlcon: ---> Package python2-cryptography.x86_64 0:1.7.2-2.el7 will be installed
    #     atlcon: --> Processing Dependency: python-idna >= 2.0 for package: python2-cryptography-1.7.2-2.el7.x86_64
    #     atlcon: --> Processing Dependency: python-cffi >= 1.4.1 for package: python2-cryptography-1.7.2-2.el7.x86_64
    #     atlcon: --> Processing Dependency: python-enum34 for package: python2-cryptography-1.7.2-2.el7.x86_64
    #     atlcon: --> Processing Dependency: libcrypto.so.10(OPENSSL_1.0.2)(64bit) for package: python2-cryptography-1.7.2-2.el7.x86_64
    #     atlcon: ---> Package python2-pyasn1.noarch 0:0.1.9-7.el7 will be installed
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package libtommath.x86_64 0:0.42.0-6.el7 will be installed
    #     atlcon: ---> Package openssl-libs.x86_64 1:1.0.1e-60.el7_3.1 will be updated
    #     atlcon: --> Processing Dependency: openssl-libs(x86-64) = 1:1.0.1e-60.el7_3.1 for package: 1:openssl-1.0.1e-60.el7_3.1.x86_64
    #     atlcon: ---> Package openssl-libs.x86_64 1:1.0.2k-12.el7 will be an update
    #     atlcon: ---> Package python-backports.x86_64 0:1.0-8.el7 will be installed
    #     atlcon: ---> Package python-cffi.x86_64 0:1.6.0-5.el7 will be installed
    #     atlcon: --> Processing Dependency: python-pycparser for package: python-cffi-1.6.0-5.el7.x86_64
    #     atlcon: ---> Package python-enum34.noarch 0:1.0.4-1.el7 will be installed
    #     atlcon: ---> Package python-idna.noarch 0:2.4-1.el7 will be installed
    #     atlcon: ---> Package python-ipaddress.noarch 0:1.0.16-2.el7 will be installed
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package openssl.x86_64 1:1.0.1e-60.el7_3.1 will be updated
    #     atlcon: ---> Package openssl.x86_64 1:1.0.2k-12.el7 will be an update
    #     atlcon: ---> Package python-pycparser.noarch 0:2.14-1.el7 will be installed
    #     atlcon: --> Processing Dependency: python-ply for package: python-pycparser-2.14-1.el7.noarch
    #     atlcon: --> Running transaction check
    #     atlcon: ---> Package python-ply.noarch 0:3.4-11.el7 will be installed
    #     atlcon: --> Finished Dependency Resolution
    #     atlcon: 
    #     atlcon: Dependencies Resolved
    #     atlcon: 
    #     atlcon: ================================================================================
    #     atlcon:  Package                              Arch    Version             Repository
    #     atlcon:                                                                            Size
    #     atlcon: ================================================================================
    #     atlcon: Installing:
    #     atlcon:  ansible                              noarch  2.7.1-1.el7         epel     11 M
    #     atlcon: Installing for dependencies:
    #     atlcon:  PyYAML                               x86_64  3.10-11.el7         base    153 k
    #     atlcon:  libtomcrypt                          x86_64  1.17-26.el7         extras  224 k
    #     atlcon:  libtommath                           x86_64  0.42.0-6.el7        extras   36 k
    #     atlcon:  libyaml                              x86_64  0.1.4-11.el7_0      base     55 k
    #     atlcon:  python-babel                         noarch  0.9.6-8.el7         base    1.4 M
    #     atlcon:  python-backports                     x86_64  1.0-8.el7           base    5.8 k
    #     atlcon:  python-backports-ssl_match_hostname  noarch  3.5.0.1-1.el7       base     13 k
    #     atlcon:  python-cffi                          x86_64  1.6.0-5.el7         base    218 k
    #     atlcon:  python-enum34                        noarch  1.0.4-1.el7         base     52 k
    #     atlcon:  python-httplib2                      noarch  0.9.2-1.el7         extras  115 k
    #     atlcon:  python-idna                          noarch  2.4-1.el7           base     94 k
    #     atlcon:  python-ipaddress                     noarch  1.0.16-2.el7        base     34 k
    #     atlcon:  python-jinja2                        noarch  2.7.2-2.el7         base    515 k
    #     atlcon:  python-keyczar                       noarch  0.71c-2.el7         epel    218 k
    #     atlcon:  python-markupsafe                    x86_64  0.11-10.el7         base     25 k
    #     atlcon:  python-paramiko                      noarch  2.1.1-4.el7         extras  268 k
    #     atlcon:  python-ply                           noarch  3.4-11.el7          base    123 k
    #     atlcon:  python-pycparser                     noarch  2.14-1.el7          base    104 k
    #     atlcon:  python-setuptools                    noarch  0.9.8-7.el7         base    397 k
    #     atlcon:  python-six                           noarch  1.9.0-2.el7         base     29 k
    #     atlcon:  python2-crypto                       x86_64  2.6.1-15.el7        extras  477 k
    #     atlcon:  python2-cryptography                 x86_64  1.7.2-2.el7         base    502 k
    #     atlcon:  python2-jmespath                     noarch  0.9.0-3.el7         extras   39 k
    #     atlcon:  python2-pyasn1                       noarch  0.1.9-7.el7         base    100 k
    #     atlcon:  sshpass                              x86_64  1.06-2.el7          extras   21 k
    #     atlcon: Updating for dependencies:
    #     atlcon:  openssl                              x86_64  1:1.0.2k-12.el7     base    492 k
    #     atlcon:  openssl-libs                         x86_64  1:1.0.2k-12.el7     base    1.2 M
    #     atlcon: 
    #     atlcon: Transaction Summary
    #     atlcon: ================================================================================
    #     atlcon: Install  1 Package  (+25 Dependent packages)
    #     atlcon: Upgrade             (  2 Dependent packages)
    #     atlcon: 
    #     atlcon: Total download size: 18 M
    #     atlcon: Downloading packages:
    #     atlcon: Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
    #     atlcon: Public key for ansible-2.7.1-1.el7.noarch.rpm is not installed
    #     atlcon: warning: /var/cache/yum/x86_64/7/epel/packages/ansible-2.7.1-1.el7.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID 352c64e5: NOKEY
    #     atlcon: --------------------------------------------------------------------------------
    #     atlcon: Total                                              4.1 MB/s |  18 MB  00:04     
    #     atlcon: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    #     atlcon: Importing GPG key 0x352C64E5:
    #     atlcon:  Userid     : "Fedora EPEL (7) <epel@fedoraproject.org>"
    #     atlcon:  Fingerprint: 91e9 7d7c 4a5e 96f1 7f3e 888f 6a2f aea2 352c 64e5
    #     atlcon:  Package    : epel-release-7-11.noarch (@extras)
    #     atlcon:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    #     atlcon: Running transaction check
    #     atlcon: Running transaction test
    #     atlcon: Transaction test succeeded
    #     atlcon: Running transaction
    #     atlcon:   Installing : python2-pyasn1-0.1.9-7.el7.noarch                           1/30
    #     atlcon:  
    #     atlcon:   Installing : python-ipaddress-1.0.16-2.el7.noarch                        2/30
    #     atlcon:  
    #     atlcon:   Installing : python-six-1.9.0-2.el7.noarch                               3/30
    #     atlcon:  
    #     atlcon:   Updating   : 1:openssl-libs-1.0.2k-12.el7.x86_64                         4/30
    #     atlcon:  
    #     atlcon:   Updating   : 1:openssl-1.0.2k-12.el7.x86_64                              5/30
    #     atlcon:  
    #     atlcon:   Installing : python-httplib2-0.9.2-1.el7.noarch                          6/30
    #     atlcon:  
    #     atlcon:   Installing : python-enum34-1.0.4-1.el7.noarch                            7/30
    #     atlcon:  
    #     atlcon:   Installing : libyaml-0.1.4-11.el7_0.x86_64                               8/30
    #     atlcon:  
    #     atlcon:   Installing : PyYAML-3.10-11.el7.x86_64                                   9/30
    #     atlcon:  
    #     atlcon:   Installing : libtommath-0.42.0-6.el7.x86_64                             10/30
    #     atlcon:  
    #     atlcon:   Installing : libtomcrypt-1.17-26.el7.x86_64                             11/30
    #     atlcon:  
    #     atlcon:   Installing : python2-crypto-2.6.1-15.el7.x86_64                         12/30
    #     atlcon:  
    #     atlcon:   Installing : python-keyczar-0.71c-2.el7.noarch                          13/30
    #     atlcon:  
    #     atlcon:   Installing : python-backports-1.0-8.el7.x86_64                          14/30
    #     atlcon:  
    #     atlcon:   Installing : python-backports-ssl_match_hostname-3.5.0.1-1.el7.noarch   15/30
    #     atlcon:  
    #     atlcon:   Installing : python-setuptools-0.9.8-7.el7.noarch                       16/30
    #     atlcon:  
    #     atlcon:   Installing : python-babel-0.9.6-8.el7.noarch                            17/30
    #     atlcon:  
    #     atlcon:   Installing : python-ply-3.4-11.el7.noarch                               18/30
    #     atlcon:  
    #     atlcon:   Installing : python-pycparser-2.14-1.el7.noarch                         19/30
    #     atlcon:  
    #     atlcon:   Installing : python-cffi-1.6.0-5.el7.x86_64                             20/30
    #     atlcon:  
    #     atlcon:   Installing : python-markupsafe-0.11-10.el7.x86_64                       21/30
    #     atlcon:  
    #     atlcon:   Installing : python-jinja2-2.7.2-2.el7.noarch                           22/30
    #     atlcon:  
    #     atlcon:   Installing : python-idna-2.4-1.el7.noarch                               23/30
    #     atlcon:  
    #     atlcon:   Installing : python2-cryptography-1.7.2-2.el7.x86_64                    24/30
    #     atlcon:  
    #     atlcon:   Installing : python-paramiko-2.1.1-4.el7.noarch                         25/30
    #     atlcon:  
    #     atlcon:   Installing : sshpass-1.06-2.el7.x86_64                                  26/30
    #     atlcon:  
    #     atlcon:   Installing : python2-jmespath-0.9.0-3.el7.noarch                        27/30
    #     atlcon:  
    #     atlcon:   Installing : ansible-2.7.1-1.el7.noarch                                 28/30
    #     atlcon:  
    #     atlcon:   Cleanup    : 1:openssl-1.0.1e-60.el7_3.1.x86_64                         29/30
    #     atlcon:  
    #     atlcon:   Cleanup    : 1:openssl-libs-1.0.1e-60.el7_3.1.x86_64                    30/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-keyczar-0.71c-2.el7.noarch                           1/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-jinja2-2.7.2-2.el7.noarch                            2/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-backports-ssl_match_hostname-3.5.0.1-1.el7.noarch    3/30
    #     atlcon:  
    #     atlcon:   Verifying  : python2-jmespath-0.9.0-3.el7.noarch                         4/30
    #     atlcon:  
    #     atlcon:   Verifying  : sshpass-1.06-2.el7.x86_64                                   5/30
    #     atlcon:  
    #     atlcon:   Verifying  : python2-cryptography-1.7.2-2.el7.x86_64                     6/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-setuptools-0.9.8-7.el7.noarch                        7/30
    #     atlcon:  
    #     atlcon:   Verifying  : 1:openssl-libs-1.0.2k-12.el7.x86_64                         8/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-paramiko-2.1.1-4.el7.noarch                          9/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-six-1.9.0-2.el7.noarch                              10/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-idna-2.4-1.el7.noarch                               11/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-markupsafe-0.11-10.el7.x86_64                       12/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-ply-3.4-11.el7.noarch                               13/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-babel-0.9.6-8.el7.noarch                            14/30
    #     atlcon:  
    #     atlcon:   Verifying  : PyYAML-3.10-11.el7.x86_64                                  15/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-backports-1.0-8.el7.x86_64                          16/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-cffi-1.6.0-5.el7.x86_64                             17/30
    #     atlcon:  
    #     atlcon:   Verifying  : libtommath-0.42.0-6.el7.x86_64                             18/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-pycparser-2.14-1.el7.noarch                         19/30
    #     atlcon:  
    #     atlcon:   Verifying  : libyaml-0.1.4-11.el7_0.x86_64                              20/30
    #     atlcon:  
    #     atlcon:   Verifying  : python2-crypto-2.6.1-15.el7.x86_64                         21/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-ipaddress-1.0.16-2.el7.noarch                       22/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-enum34-1.0.4-1.el7.noarch                           23/30
    #     atlcon:  
    #     atlcon:   Verifying  : python-httplib2-0.9.2-1.el7.noarch                         24/30
    #     atlcon:  
    #     atlcon:   Verifying  : python2-pyasn1-0.1.9-7.el7.noarch                          25/30
    #     atlcon:  
    #     atlcon:   Verifying  : ansible-2.7.1-1.el7.noarch                                 26/30
    #     atlcon:  
    #     atlcon:   Verifying  : 1:openssl-1.0.2k-12.el7.x86_64                             27/30
    #     atlcon:  
    #     atlcon:   Verifying  : libtomcrypt-1.17-26.el7.x86_64                             28/30
    #     atlcon:  
    #     atlcon:   Verifying  : 1:openssl-1.0.1e-60.el7_3.1.x86_64                         29/30 
    #     atlcon:   Verifying  : 1:openssl-libs-1.0.1e-60.el7_3.1.x86_64                    30/30
    #     atlcon:  
    #     atlcon: 
    #     atlcon: Installed:
    #     atlcon:   ansible.noarch 0:2.7.1-1.el7                                                  
    #     atlcon: 
    #     atlcon: Dependency Installed:
    #     atlcon:   PyYAML.x86_64 0:3.10-11.el7                                                   
    #     atlcon:   libtomcrypt.x86_64 0:1.17-26.el7                                              
    #     atlcon:   libtommath.x86_64 0:0.42.0-6.el7                                              
    #     atlcon:   libyaml.x86_64 0:0.1.4-11.el7_0                                               
    #     atlcon:   python-babel.noarch 0:0.9.6-8.el7                                             
    #     atlcon:   python-backports.x86_64 0:1.0-8.el7                                           
    #     atlcon:   python-backports-ssl_match_hostname.noarch 0:3.5.0.1-1.el7                    
    #     atlcon:   python-cffi.x86_64 0:1.6.0-5.el7                                              
    #     atlcon:   python-enum34.noarch 0:1.0.4-1.el7                                            
    #     atlcon:   python-httplib2.noarch 0:0.9.2-1.el7                                          
    #     atlcon:   python-idna.noarch 0:2.4-1.el7                                                
    #     atlcon:   python-ipaddress.noarch 0:1.0.16-2.el7                                        
    #     atlcon:   python-jinja2.noarch 0:2.7.2-2.el7                                            
    #     atlcon:   python-keyczar.noarch 0:0.71c-2.el7                                           
    #     atlcon:   python-markupsafe.x86_64 0:0.11-10.el7                                        
    #     atlcon:   python-paramiko.noarch 0:2.1.1-4.el7                                          
    #     atlcon:   python-ply.noarch 0:3.4-11.el7                                                
    #     atlcon:   python-pycparser.noarch 0:2.14-1.el7                                          
    #     atlcon:   python-setuptools.noarch 0:0.9.8-7.el7                                        
    #     atlcon:   python-six.noarch 0:1.9.0-2.el7                                               
    #     atlcon:   python2-crypto.x86_64 0:2.6.1-15.el7                                          
    #     atlcon:   python2-cryptography.x86_64 0:1.7.2-2.el7                                     
    #     atlcon:   python2-jmespath.noarch 0:0.9.0-3.el7                                         
    #     atlcon:   python2-pyasn1.noarch 0:0.1.9-7.el7                                           
    #     atlcon:   sshpass.x86_64 0:1.06-2.el7                                                   
    #     atlcon: 
    #     atlcon: Dependency Updated:
    #     atlcon:   openssl.x86_64 1:1.0.2k-12.el7       openssl-libs.x86_64 1:1.0.2k-12.el7      
    #     atlcon: Complete!


<a id="orgb66fbdb"></a>

#### Connect to the Ansible controller **atlcon**

After Vagrant has provisioned the VMs you are able to connect to them. There are
two VMs, **atlcon** and **atlassian1**. First connect to the Ansible controller **atlcon**
from the directory you ran the Vagrantfile from via

    vagrant ssh atlcon

After the connect change the directory to /vagrant/ansible. 

    cd /vagrant/ansible

Here you have to execute the following command:

    ansible-playbook -i inventories/dev dev.yml --ask-vault-pass
    opendevstack

    # Vault password: opendevstack
    # 
    # [DEPRECATION WARNING]: 'include' for playbook includes. You should use 
    # 'import_playbook' instead. This feature will be removed in version 2.8. Deprecation
    #  warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
    # 
    # PLAY [localhost] *******************************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [localhost]
    # 
    # TASK [install additional packages] *************************************************
    # changed: [localhost] => (item=vim)
    # changed: [localhost] => (item=tig)
    # changed: [localhost] => (item=python2-pip)
    # changed: [localhost] => (item=tmux)
    # 
    # TASK [install python libraries] ****************************************************
    # [DEPRECATION WARNING]: Invoking "pip" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'boto', u'psycopg2', u'awscli']`
    #  and remove the loop. This feature will be removed in version 2.11. Deprecation 
    # warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
    # changed: [localhost] => (item=[u'boto', u'psycopg2', u'awscli'])
    # 
    # TASK [install centos pgdg] *********************************************************
    # changed: [localhost]
    # 
    # TASK [install redhat pgdg] *********************************************************
    # skipping: [localhost]
    # 
    # TASK [remove postgresql 9.2 client] ************************************************
    # ok: [localhost]
    # 
    # TASK [add postgresql94 client] *****************************************************
    # changed: [localhost]
    # 
    # TASK [install git prompt] **********************************************************
    # changed: [localhost]
    # 
    # TASK [install bashrc] **************************************************************
    # changed: [localhost]
    # 
    # PLAY [tag_ansible_managed] *********************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [install epel] ****************************************************************
    # changed: [atlassian1]
    # 
    # TASK [install basic packages] ******************************************************
    # [DEPRECATION WARNING]: Invoking "yum" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'chrony', u'htop']` and remove 
    # the loop. This feature will be removed in version 2.11. Deprecation warnings can be
    #  disabled by setting deprecation_warnings=False in ansible.cfg.
    # changed: [atlassian1] => (item=[u'chrony', u'htop'])
    # 
    # TASK [set timezone to UTC] *********************************************************
    # changed: [atlassian1]
    # 
    # PLAY [tag_ansible_managed] *********************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [install additional packages] *************************************************
    # changed: [atlassian1] => (item=vim)
    # changed: [atlassian1] => (item=python2-pip)
    # changed: [atlassian1] => (item=tmux)
    # ok: [atlassian1] => (item=htop)
    # 
    # TASK [install python libraries] ****************************************************
    # [DEPRECATION WARNING]: Invoking "pip" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'awscli']` and remove the loop. 
    # This feature will be removed in version 2.11. Deprecation warnings can be disabled 
    # by setting deprecation_warnings=False in ansible.cfg.
    # changed: [atlassian1] => (item=[u'awscli'])
    # 
    # TASK [install bashrc] **************************************************************
    # changed: [atlassian1]
    # 
    # PLAY [atlassian-db] ****************************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [exclude standard postgresql package] *****************************************
    # changed: [atlassian1] => (item=[base])
    # ok: [atlassian1] => (item=[update])
    # 
    # TASK [install centos pgdg] *********************************************************
    # changed: [atlassian1]
    # 
    # TASK [install postgresql] **********************************************************
    # changed: [atlassian1]
    # 
    # TASK [Enable Service] **************************************************************
    # changed: [atlassian1]
    # 
    # TASK [initialize postgresql if necessary] ******************************************
    # changed: [atlassian1]
    # 
    # TASK [Copy pg_hba.configure] *******************************************************
    # changed: [atlassian1]
    # 
    # TASK [Configure listen address] ****************************************************
    # changed: [atlassian1]
    # 
    # TASK [start postgresql] ************************************************************
    # changed: [atlassian1]
    # 
    # TASK [install epel] ****************************************************************
    # ok: [atlassian1]
    # 
    # TASK [install pip] *****************************************************************
    # ok: [atlassian1]
    # 
    # TASK [install required pip packages to manage postgresql_db] ***********************
    # changed: [atlassian1]
    # 
    # TASK [create atlassian database] ***************************************************
    #  [WARNING]: Module remote_tmp /var/lib/pgsql/.ansible/tmp did not exist and was
    # created with a mode of 0700, this may cause issues when running as another user. To
    # avoid this, create the remote_tmp dir with the correct permissions manually
    # changed: [atlassian1]
    # 
    # TASK [create root login user] ******************************************************
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|failed` use `result is failed`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # changed: [atlassian1]
    # 
    # RUNNING HANDLER [restart postgresql] ***********************************************
    # changed: [atlassian1]
    # 
    # PLAY [atlassian-db] ****************************************************************
    # 
    # TASK [create database users] *******************************************************
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'eazybi', u'name': u'eazybi_jira'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'crowd', u'name': u'crowd'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'crowdid', u'name': u'crowdid'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'jira', u'name': u'jira'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'bitbucket', u'name': u'bitbucket'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'confluence', u'name': u'confluence'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'password': u'rundeck', u'name': u'rundeck'})
    # 
    # TASK [fail if error not because user already exists] *******************************
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|failed` use `result is failed`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.145110', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'eazybi', u'name': u'eazybi_jira'}, u'end': u'2018-11-16 10:54:07.169426', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER eazybi_jira WITH PASSWORD 'eazybi'"], 'item': {u'password': u'eazybi', u'name': u'eazybi_jira'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER eazybi_jira WITH PASSWORD \'eazybi\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:07.024316', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.012907', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'crowd', u'name': u'crowd'}, u'end': u'2018-11-16 10:54:07.382308', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER crowd WITH PASSWORD 'crowd'"], 'item': {u'password': u'crowd', u'name': u'crowd'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER crowd WITH PASSWORD \'crowd\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:07.369401', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.012744', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'crowdid', u'name': u'crowdid'}, u'end': u'2018-11-16 10:54:07.593989', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER crowdid WITH PASSWORD 'crowdid'"], 'item': {u'password': u'crowdid', u'name': u'crowdid'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER crowdid WITH PASSWORD \'crowdid\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:07.581245', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.012552', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'jira', u'name': u'jira'}, u'end': u'2018-11-16 10:54:07.812252', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER jira WITH PASSWORD 'jira'"], 'item': {u'password': u'jira', u'name': u'jira'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER jira WITH PASSWORD \'jira\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:07.799700', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.013372', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'bitbucket', u'name': u'bitbucket'}, u'end': u'2018-11-16 10:54:08.050535', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER bitbucket WITH PASSWORD 'bitbucket'"], 'item': {u'password': u'bitbucket', u'name': u'bitbucket'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER bitbucket WITH PASSWORD \'bitbucket\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:08.037163', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.013804', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'confluence', u'name': u'confluence'}, u'end': u'2018-11-16 10:54:08.278589', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER confluence WITH PASSWORD 'confluence'"], 'item': {u'password': u'confluence', u'name': u'confluence'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER confluence WITH PASSWORD \'confluence\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:08.264785', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE ROLE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.011537', 'stdout_lines': [u'CREATE ROLE'], '_ansible_item_label': {u'password': u'rundeck', u'name': u'rundeck'}, u'end': u'2018-11-16 10:54:08.493314', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE USER rundeck WITH PASSWORD 'rundeck'"], 'item': {u'password': u'rundeck', u'name': u'rundeck'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE USER rundeck WITH PASSWORD \'rundeck\'"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:08.481777', '_ansible_ignore_errors': True}) 
    # 
    # TASK [grant newly created roles / users to root user] ******************************
    # changed: [atlassian1 -> 127.0.0.1] => (item=eazybi_jira)
    # changed: [atlassian1 -> 127.0.0.1] => (item=crowd)
    # changed: [atlassian1 -> 127.0.0.1] => (item=crowdid)
    # changed: [atlassian1 -> 127.0.0.1] => (item=jira)
    # changed: [atlassian1 -> 127.0.0.1] => (item=bitbucket)
    # changed: [atlassian1 -> 127.0.0.1] => (item=confluence)
    # changed: [atlassian1 -> 127.0.0.1] => (item=rundeck)
    # 
    # TASK [create databases] ************************************************************
    # changed: [atlassian1 -> 127.0.0.1] => (item=confluence)
    # changed: [atlassian1 -> 127.0.0.1] => (item=bitbucket)
    # changed: [atlassian1 -> 127.0.0.1] => (item=eazybi_jira)
    # changed: [atlassian1 -> 127.0.0.1] => (item=rundeck)
    # 
    # TASK [debug] ***********************************************************************
    # ok: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:01.134313', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'confluence', u'end': u'2018-11-16 10:54:12.110299', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE confluence WITH ENCODING='UTF8' OWNER=confluence CONNECTION LIMIT=-1"], 'item': u'confluence', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE confluence WITH ENCODING=\'UTF8\' OWNER=confluence CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:10.975986', '_ansible_ignore_errors': True}) => {
    #     "msg": {
    #         "changed": true, 
    #         "cmd": [
    #             "psql", 
    #             "-U", 
    #             "db_root", 
    #             "-h", 
    #             "192.168.56.31", 
    #             "-d", 
    #             "atlassian", 
    #             "-c", 
    #             "CREATE DATABASE confluence WITH ENCODING='UTF8' OWNER=confluence CONNECTION LIMIT=-1"
    #         ], 
    #         "delta": "0:00:01.134313", 
    #         "end": "2018-11-16 10:54:12.110299", 
    #         "failed": false, 
    #         "invocation": {
    #             "module_args": {
    #                 "_raw_params": "psql -U db_root -h 192.168.56.31 -d atlassian -c \"CREATE DATABASE confluence WITH ENCODING='UTF8' OWNER=confluence CONNECTION LIMIT=-1\"", 
    #                 "_uses_shell": false, 
    #                 "argv": null, 
    #                 "chdir": null, 
    #                 "creates": null, 
    #                 "executable": null, 
    #                 "removes": null, 
    #                 "stdin": null, 
    #                 "warn": true
    #             }
    #         }, 
    #         "item": "confluence", 
    #         "rc": 0, 
    #         "start": "2018-11-16 10:54:10.975986", 
    #         "stderr": "", 
    #         "stderr_lines": [], 
    #         "stdout": "CREATE DATABASE", 
    #         "stdout_lines": [
    #             "CREATE DATABASE"
    #         ]
    #     }
    # }
    # ok: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.638357', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'bitbucket', u'end': u'2018-11-16 10:54:12.962699', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE bitbucket WITH ENCODING='UTF8' OWNER=bitbucket CONNECTION LIMIT=-1"], 'item': u'bitbucket', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE bitbucket WITH ENCODING=\'UTF8\' OWNER=bitbucket CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:12.324342', '_ansible_ignore_errors': True}) => {
    #     "msg": {
    #         "changed": true, 
    #         "cmd": [
    #             "psql", 
    #             "-U", 
    #             "db_root", 
    #             "-h", 
    #             "192.168.56.31", 
    #             "-d", 
    #             "atlassian", 
    #             "-c", 
    #             "CREATE DATABASE bitbucket WITH ENCODING='UTF8' OWNER=bitbucket CONNECTION LIMIT=-1"
    #         ], 
    #         "delta": "0:00:00.638357", 
    #         "end": "2018-11-16 10:54:12.962699", 
    #         "failed": false, 
    #         "invocation": {
    #             "module_args": {
    #                 "_raw_params": "psql -U db_root -h 192.168.56.31 -d atlassian -c \"CREATE DATABASE bitbucket WITH ENCODING='UTF8' OWNER=bitbucket CONNECTION LIMIT=-1\"", 
    #                 "_uses_shell": false, 
    #                 "argv": null, 
    #                 "chdir": null, 
    #                 "creates": null, 
    #                 "executable": null, 
    #                 "removes": null, 
    #                 "stdin": null, 
    #                 "warn": true
    #             }
    #         }, 
    #         "item": "bitbucket", 
    #         "rc": 0, 
    #         "start": "2018-11-16 10:54:12.324342", 
    #         "stderr": "", 
    #         "stderr_lines": [], 
    #         "stdout": "CREATE DATABASE", 
    #         "stdout_lines": [
    #             "CREATE DATABASE"
    #         ]
    #     }
    # }
    # ok: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.771316', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'eazybi_jira', u'end': u'2018-11-16 10:54:13.931960', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE eazybi_jira WITH ENCODING='UTF8' OWNER=eazybi_jira CONNECTION LIMIT=-1"], 'item': u'eazybi_jira', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE eazybi_jira WITH ENCODING=\'UTF8\' OWNER=eazybi_jira CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:13.160644', '_ansible_ignore_errors': True}) => {
    #     "msg": {
    #         "changed": true, 
    #         "cmd": [
    #             "psql", 
    #             "-U", 
    #             "db_root", 
    #             "-h", 
    #             "192.168.56.31", 
    #             "-d", 
    #             "atlassian", 
    #             "-c", 
    #             "CREATE DATABASE eazybi_jira WITH ENCODING='UTF8' OWNER=eazybi_jira CONNECTION LIMIT=-1"
    #         ], 
    #         "delta": "0:00:00.771316", 
    #         "end": "2018-11-16 10:54:13.931960", 
    #         "failed": false, 
    #         "invocation": {
    #             "module_args": {
    #                 "_raw_params": "psql -U db_root -h 192.168.56.31 -d atlassian -c \"CREATE DATABASE eazybi_jira WITH ENCODING='UTF8' OWNER=eazybi_jira CONNECTION LIMIT=-1\"", 
    #                 "_uses_shell": false, 
    #                 "argv": null, 
    #                 "chdir": null, 
    #                 "creates": null, 
    #                 "executable": null, 
    #                 "removes": null, 
    #                 "stdin": null, 
    #                 "warn": true
    #             }
    #         }, 
    #         "item": "eazybi_jira", 
    #         "rc": 0, 
    #         "start": "2018-11-16 10:54:13.160644", 
    #         "stderr": "", 
    #         "stderr_lines": [], 
    #         "stdout": "CREATE DATABASE", 
    #         "stdout_lines": [
    #             "CREATE DATABASE"
    #         ]
    #     }
    # }
    # ok: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.812769', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'rundeck', u'end': u'2018-11-16 10:54:14.964972', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE rundeck WITH ENCODING='UTF8' OWNER=rundeck CONNECTION LIMIT=-1"], 'item': u'rundeck', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE rundeck WITH ENCODING=\'UTF8\' OWNER=rundeck CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:14.152203', '_ansible_ignore_errors': True}) => {
    #     "msg": {
    #         "changed": true, 
    #         "cmd": [
    #             "psql", 
    #             "-U", 
    #             "db_root", 
    #             "-h", 
    #             "192.168.56.31", 
    #             "-d", 
    #             "atlassian", 
    #             "-c", 
    #             "CREATE DATABASE rundeck WITH ENCODING='UTF8' OWNER=rundeck CONNECTION LIMIT=-1"
    #         ], 
    #         "delta": "0:00:00.812769", 
    #         "end": "2018-11-16 10:54:14.964972", 
    #         "failed": false, 
    #         "invocation": {
    #             "module_args": {
    #                 "_raw_params": "psql -U db_root -h 192.168.56.31 -d atlassian -c \"CREATE DATABASE rundeck WITH ENCODING='UTF8' OWNER=rundeck CONNECTION LIMIT=-1\"", 
    #                 "_uses_shell": false, 
    #                 "argv": null, 
    #                 "chdir": null, 
    #                 "creates": null, 
    #                 "executable": null, 
    #                 "removes": null, 
    #                 "stdin": null, 
    #                 "warn": true
    #             }
    #         }, 
    #         "item": "rundeck", 
    #         "rc": 0, 
    #         "start": "2018-11-16 10:54:14.152203", 
    #         "stderr": "", 
    #         "stderr_lines": [], 
    #         "stdout": "CREATE DATABASE", 
    #         "stdout_lines": [
    #             "CREATE DATABASE"
    #         ]
    #     }
    # }
    # 
    # TASK [fail if not because db exists] ***********************************************
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:01.134313', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'confluence', u'end': u'2018-11-16 10:54:12.110299', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE confluence WITH ENCODING='UTF8' OWNER=confluence CONNECTION LIMIT=-1"], 'item': u'confluence', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE confluence WITH ENCODING=\'UTF8\' OWNER=confluence CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:10.975986', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.638357', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'bitbucket', u'end': u'2018-11-16 10:54:12.962699', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE bitbucket WITH ENCODING='UTF8' OWNER=bitbucket CONNECTION LIMIT=-1"], 'item': u'bitbucket', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE bitbucket WITH ENCODING=\'UTF8\' OWNER=bitbucket CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:12.324342', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.771316', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'eazybi_jira', u'end': u'2018-11-16 10:54:13.931960', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE eazybi_jira WITH ENCODING='UTF8' OWNER=eazybi_jira CONNECTION LIMIT=-1"], 'item': u'eazybi_jira', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE eazybi_jira WITH ENCODING=\'UTF8\' OWNER=eazybi_jira CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:13.160644', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE DATABASE', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.812769', 'stdout_lines': [u'CREATE DATABASE'], '_ansible_item_label': u'rundeck', u'end': u'2018-11-16 10:54:14.964972', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u"CREATE DATABASE rundeck WITH ENCODING='UTF8' OWNER=rundeck CONNECTION LIMIT=-1"], 'item': u'rundeck', u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE DATABASE rundeck WITH ENCODING=\'UTF8\' OWNER=rundeck CONNECTION LIMIT=-1"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:14.152203', '_ansible_ignore_errors': True}) 
    # 
    # TASK [create database schemas] *****************************************************
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'owner': u'crowd', u'name': u'crowd'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'owner': u'crowdid', u'name': u'crowdid'})
    # changed: [atlassian1 -> 127.0.0.1] => (item={u'owner': u'jira', u'name': u'jira'})
    # 
    # TASK [fail if error not because schema already exists] *****************************
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|failed` use `result is failed`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE SCHEMA', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.103274', 'stdout_lines': [u'CREATE SCHEMA'], '_ansible_item_label': {u'owner': u'crowd', u'name': u'crowd'}, u'end': u'2018-11-16 10:54:15.965281', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u'CREATE SCHEMA AUTHORIZATION crowd'], 'item': {u'owner': u'crowd', u'name': u'crowd'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE SCHEMA AUTHORIZATION crowd"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:15.862007', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE SCHEMA', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.011469', 'stdout_lines': [u'CREATE SCHEMA'], '_ansible_item_label': {u'owner': u'crowdid', u'name': u'crowdid'}, u'end': u'2018-11-16 10:54:16.211834', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u'CREATE SCHEMA AUTHORIZATION crowdid'], 'item': {u'owner': u'crowdid', u'name': u'crowdid'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE SCHEMA AUTHORIZATION crowdid"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:16.200365', '_ansible_ignore_errors': True}) 
    # skipping: [atlassian1] => (item={'_ansible_parsed': True, 'stderr_lines': [], u'changed': True, u'stdout': u'CREATE SCHEMA', '_ansible_delegated_vars': {'ansible_delegated_host': u'127.0.0.1', 'ansible_host': u'127.0.0.1'}, '_ansible_item_result': True, u'delta': u'0:00:00.012306', 'stdout_lines': [u'CREATE SCHEMA'], '_ansible_item_label': {u'owner': u'jira', u'name': u'jira'}, u'end': u'2018-11-16 10:54:16.450471', '_ansible_no_log': False, 'failed': False, u'cmd': [u'psql', u'-U', u'db_root', u'-h', u'192.168.56.31', u'-d', u'atlassian', u'-c', u'CREATE SCHEMA AUTHORIZATION jira'], 'item': {u'owner': u'jira', u'name': u'jira'}, u'stderr': u'', u'rc': 0, u'invocation': {u'module_args': {u'warn': True, u'executable': None, u'_uses_shell': False, u'_raw_params': u'psql -U db_root -h 192.168.56.31 -d atlassian -c "CREATE SCHEMA AUTHORIZATION jira"', u'removes': None, u'argv': None, u'creates': None, u'chdir': None, u'stdin': None}}, u'start': u'2018-11-16 10:54:16.438165', '_ansible_ignore_errors': True}) 
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=28   changed=22   unreachable=0    failed=0   
    # localhost                  : ok=8    changed=6    unreachable=0    failed=0   

This playbook prepares the ansible controller and basic installations on the
**atlassian1** VM like a local database and the necessary schemas with their
respective user. The password for the vault located under
`ansible/inventories/dev/group_vars/all/vault.yml` is **opendevstack**. Depending on
your network or proxy configuration it might happen that some online resources
are not reachable. Please try to execute the playbook again in such a case.

All ansible playbook commands in this guide have to be executed from the Ansible
controller like described before!


<a id="org8980e3d"></a>

## Install Atlassian Tools and Rundeck

The following steps explain the Atlassian tools and the Rundeck installation.


<a id="org111c692"></a>

### Crowd Setup


<a id="orgca444c6"></a>

#### Setup Application

Downloading and Configuring as service

    ansible-playbook -v -i inventories/dev playbooks/crowd.yml --ask-vault
    opendevstack

    # Using /vagrant/ansible/ansible.cfg as config file
    # Vault password: opendevstack
    # 
    # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
    # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
    # 
    # PLAY [tag_hostgroup_crowd_test] ****************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [srsp.oracle-java : precondition - java_version] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_subversion] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_install_jce] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_version": "1.8.0_181"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java architecture] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_arch": "x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Linux] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_os": "linux"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set rpm binary] *******************************************
    # ok: [atlassian1] => {"ansible_facts": {"use_dmg": false, "use_rpm": true, "use_tarball": false}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set tarball binary] ***************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set dmg binary] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 10] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 9.0.4] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_181] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_hash": "96a7b8442fe848ef90c96a2fad6ed6d1", "jdk_version_detail": "8u181-b13"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_172] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_171] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_161] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_152] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_151] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_141] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_131] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_121] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_112] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_111] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for generic Java version] ***************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_file": "jdk-8u181-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_url": "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE zip file variables for java 8] ********************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_file": "jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE variables for java 8] *****************************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_folder": "UnlimitedJCEPolicyJDK8", "jce_zip_url": "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE download file] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Debian platforms] ******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Mac OS X] **************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on non-Debian platforms] ***
    # ok: [atlassian1] => {"ansible_facts": {"java_default_link_name": "default", "java_home": "/usr/java/default", "java_install_dir": "/usr/java"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : install libselinux-python binary for Ansible to work] *****
    # ok: [atlassian1] => {"changed": false, "msg": "", "rc": 0, "results": ["libselinux-python-2.5-6.el7.x86_64 providing libselinux-python is already installed"]}
    # 
    # TASK [srsp.oracle-java : copy scripts to server] ***********************************
    # changed: [atlassian1] => {"changed": true, "checksum": "2546647b60a8fffe888d8b73c924cfa0492c60b2", "dest": "/tmp/check-java-version.sh", "gid": 0, "group": "root", "md5sum": "bfd089da0c10974dde1967f253e090a3", "mode": "0755", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 416, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542366485.15-208450538734760/source", "state": "file", "uid": 0}
    # 
    # TASK [srsp.oracle-java : check if specific version of Oracle JDK is installed?] ****
    # ok: [atlassian1] => {"changed": false, "cmd": "LC_ALL=\"en_US.UTF-8\" /tmp/check-java-version.sh \"1.8.0_181\"", "delta": "0:00:00.006845", "end": "2018-11-16 11:08:06.986036", "failed_when_result": false, "rc": 0, "start": "2018-11-16 11:08:06.979191", "stderr": "", "stderr_lines": [], "stdout": "{ \"found\": false , \"not_found\": true  }", "stdout_lines": ["{ \"found\": false , \"not_found\": true  }"]}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as RPM file)] ****************************
    # [DEPRECATION WARNING]: Supplying `headers` as a string is deprecated. Please use 
    # dict/hash format for `headers`. This feature will be removed in version 2.10. 
    # Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # fatal: [atlassian1]: FAILED! => {"changed": false, "dest": "/tmp/jdk-8u181-linux-x64.rpm", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "state": "absent", "status_code": 404, "url": "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"}
    # 	to retry, use: --limit @/vagrant/ansible/playbooks/crowd.retry
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=14   changed=1    unreachable=0    failed=1   

Add java 8.0.192 to the relevant files

    ansible-playbook -v -i inventories/dev playbooks/crowd.yml --ask-vault
    opendevstack

    # Using /vagrant/ansible/ansible.cfg as config file
    # Vault password: opendevstack
    # 
    # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
    # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
    # 
    # PLAY [tag_hostgroup_crowd_test] ****************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [srsp.oracle-java : precondition - java_version] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_subversion] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_install_jce] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_version": "1.8.0_192"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java architecture] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_arch": "x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Linux] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_os": "linux"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set rpm binary] *******************************************
    # ok: [atlassian1] => {"ansible_facts": {"use_dmg": false, "use_rpm": true, "use_tarball": false}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set tarball binary] ***************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set dmg binary] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 10] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 9.0.4] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_192] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_hash": "750e1c8617c5452694857ad95c3ee230", "jdk_version_detail": "8u192-b12"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_181] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_172] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_171] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_161] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_152] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_151] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_141] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_131] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_121] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_112] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_111] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for generic Java version] ***************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_file": "jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_url": "http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE zip file variables for java 8] ********************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_file": "jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE variables for java 8] *****************************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_folder": "UnlimitedJCEPolicyJDK8", "jce_zip_url": "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE download file] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Debian platforms] ******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Mac OS X] **************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on non-Debian platforms] ***
    # ok: [atlassian1] => {"ansible_facts": {"java_default_link_name": "default", "java_home": "/usr/java/default", "java_install_dir": "/usr/java"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : install libselinux-python binary for Ansible to work] *****
    # ok: [atlassian1] => {"changed": false, "msg": "", "rc": 0, "results": ["libselinux-python-2.5-6.el7.x86_64 providing libselinux-python is already installed"]}
    # 
    # TASK [srsp.oracle-java : copy scripts to server] ***********************************
    # ok: [atlassian1] => {"changed": false, "checksum": "2546647b60a8fffe888d8b73c924cfa0492c60b2", "dest": "/tmp/check-java-version.sh", "gid": 0, "group": "root", "mode": "0755", "owner": "root", "path": "/tmp/check-java-version.sh", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 416, "state": "file", "uid": 0}
    # 
    # TASK [srsp.oracle-java : check if specific version of Oracle JDK is installed?] ****
    # ok: [atlassian1] => {"changed": false, "cmd": "LC_ALL=\"en_US.UTF-8\" /tmp/check-java-version.sh \"1.8.0_192\"", "delta": "0:00:00.009828", "end": "2018-11-16 11:14:48.297002", "failed_when_result": false, "rc": 0, "start": "2018-11-16 11:14:48.287174", "stderr": "", "stderr_lines": [], "stdout": "{ \"found\": false , \"not_found\": true  }", "stdout_lines": ["{ \"found\": false , \"not_found\": true  }"]}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as RPM file)] ****************************
    # [DEPRECATION WARNING]: Supplying `headers` as a string is deprecated. Please use 
    # dict/hash format for `headers`. This feature will be removed in version 2.10. 
    # Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "56c0829e226d2c13964c7c8a3800d1cba76622d4", "dest": "/tmp/jdk-8u192-linux-x64.rpm", "gid": 0, "group": "root", "md5sum": "b7811c8f43b2d1e392e113136f22953f", "mode": "0644", "msg": "OK (176154290 bytes)", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 176154290, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542366888.52-141312398254207/tmp8Hvzpc", "state": "file", "status_code": 200, "uid": 0, "url": "http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64.rpm"}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as tar.gz file)] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK package (as Mac OS X .dmg)] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy RPM from local] **************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy tarball from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy .dmg from local] *************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : uninstall messy packages to avoid blocking conditions] ****
    # changed: [atlassian1] => {"changed": true, "rc": 0, "stderr": "Shared connection to 192.168.56.31 closed.\r\n", "stderr_lines": ["Shared connection to 192.168.56.31 closed."], "stdout": "sun-javadb-core\r\nerror: package sun-javadb-core is not installed\r\nsun-javadb-client\r\nerror: package sun-javadb-client is not installed\r\nsun-javadb-docs\r\nerror: package sun-javadb-docs is not installed\r\nsun-javadb-javadoc\r\nerror: package sun-javadb-javadoc is not installed\r\nsun-javadb-demo\r\nerror: package sun-javadb-demo is not installed\r\nsun-javadb-common\r\nerror: package sun-javadb-common is not installed\r\n", "stdout_lines": ["sun-javadb-core", "error: package sun-javadb-core is not installed", "sun-javadb-client", "error: package sun-javadb-client is not installed", "sun-javadb-docs", "error: package sun-javadb-docs is not installed", "sun-javadb-javadoc", "error: package sun-javadb-javadoc is not installed", "sun-javadb-demo", "error: package sun-javadb-demo is not installed", "sun-javadb-common", "error: package sun-javadb-common is not installed"]}
    # 
    # TASK [srsp.oracle-java : delete messy .rpm files to avoid blocking conditions] *****
    # changed: [atlassian1] => {"changed": true, "rc": 0, "stderr": "Shared connection to 192.168.56.31 closed.\r\n", "stderr_lines": ["Shared connection to 192.168.56.31 closed."], "stdout": "sun-javadb-*.rpm\r\n*-linux-amd64.rpm\r\n", "stdout_lines": ["sun-javadb-*.rpm", "*-linux-amd64.rpm"]}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with yum] ************************
    # changed: [atlassian1] => {"changed": true, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nExamining /tmp/jdk-8u192-linux-x64.rpm: 2000:jdk1.8-1.8.0_192-fcs.x86_64\nMarking /tmp/jdk-8u192-linux-x64.rpm to be installed\nResolving Dependencies\n--> Running transaction check\n---> Package jdk1.8.x86_64 2000:1.8.0_192-fcs will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package    Arch       Version                   Repository                Size\n================================================================================\nInstalling:\n jdk1.8     x86_64     2000:1.8.0_192-fcs        /jdk-8u192-linux-x64     288 M\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal size: 288 M\nInstalled size: 288 M\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : 2000:jdk1.8-1.8.0_192-fcs.x86_64                             1/1 \nUnpacking JAR files...\n\ttools.jar...\n\tplugin.jar...\n\tjavaws.jar...\n\tdeploy.jar...\n\trt.jar...\n\tjsse.jar...\n\tcharsets.jar...\n\tlocaledata.jar...\n  Verifying  : 2000:jdk1.8-1.8.0_192-fcs.x86_64                             1/1 \n\nInstalled:\n  jdk1.8.x86_64 2000:1.8.0_192-fcs                                              \n\nComplete!\n"]}
    # 
    # TASK [srsp.oracle-java : symlink /usr/sbin/update-alternatives to /usr/sbin/alternatives] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if pkg already installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with rpm (for zypper)] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - uninstall messy packages] **********************
    # changed: [atlassian1] => {"changed": true, "rc": 0, "stderr": "Shared connection to 192.168.56.31 closed.\r\n", "stderr_lines": ["Shared connection to 192.168.56.31 closed."], "stdout": "sun-javadb-core\r\nerror: package sun-javadb-core is not installed\r\nsun-javadb-client\r\nerror: package sun-javadb-client is not installed\r\nsun-javadb-docs\r\nerror: package sun-javadb-docs is not installed\r\nsun-javadb-javadoc\r\nerror: package sun-javadb-javadoc is not installed\r\nsun-javadb-demo\r\nerror: package sun-javadb-demo is not installed\r\nsun-javadb-common\r\nerror: package sun-javadb-common is not installed\r\n", "stdout_lines": ["sun-javadb-core", "error: package sun-javadb-core is not installed", "sun-javadb-client", "error: package sun-javadb-client is not installed", "sun-javadb-docs", "error: package sun-javadb-docs is not installed", "sun-javadb-javadoc", "error: package sun-javadb-javadoc is not installed", "sun-javadb-demo", "error: package sun-javadb-demo is not installed", "sun-javadb-common", "error: package sun-javadb-common is not installed"]}
    # 
    # TASK [srsp.oracle-java : clean up - delete messy .rpm files] ***********************
    # changed: [atlassian1] => {"changed": true, "rc": 0, "stderr": "Shared connection to 192.168.56.31 closed.\r\n", "stderr_lines": ["Shared connection to 192.168.56.31 closed."], "stdout": "sun-javadb-*.rpm\r\n*-linux-amd64.rpm\r\n", "stdout_lines": ["sun-javadb-*.rpm", "*-linux-amd64.rpm"]}
    # 
    # TASK [srsp.oracle-java : mkdir for Java] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for specific Java version] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via tarball file] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mount the downloaded dmg] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install the pkg file from the dmg] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unmount the downloaded dmg] *******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : make sure /etc/profile.d exists] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : export JAVA_HOME] *****************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK8"] ***
    # changed: [atlassian1] => {"changed": true, "dest": "/usr/java/default", "gid": 0, "group": "root", "mode": "0777", "owner": "root", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 28, "src": "/usr/java/jdk1.8.0_192-amd64", "state": "link", "uid": 0}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java"] *****************************
    # changed: [atlassian1] => {"changed": true}
    # 
    # TASK [srsp.oracle-java : alternatives link for "javac"] ****************************
    # changed: [atlassian1] => {"changed": true}
    # 
    # TASK [srsp.oracle-java : alternatives link for "jar"] ******************************
    # changed: [atlassian1] => {"changed": true}
    # 
    # TASK [srsp.oracle-java : check if "java_sdk" target exists] ************************
    # ok: [atlassian1] => {"changed": false, "stat": {"exists": false}}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java_sdk"] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded files, if requested] **********
    # changed: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.rpm) => {"changed": true, "item": "/tmp/jdk-8u192-linux-x64.rpm", "path": "/tmp/jdk-8u192-linux-x64.rpm", "state": "absent"}
    # ok: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.tar.gz) => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.tar.gz", "path": "/tmp/jdk-8u192-linux-x64.tar.gz", "state": "absent"}
    # ok: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.dmg) => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.dmg", "path": "/tmp/jdk-8u192-linux-x64.dmg", "state": "absent"}
    # ok: [atlassian1] => (item=/tmp/check-tarball-installed.sh) => {"changed": false, "item": "/tmp/check-tarball-installed.sh", "path": "/tmp/check-tarball-installed.sh", "state": "absent"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Mac] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Make sure 'which' is installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Linux] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Check if JCE is already installed] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JCE] **************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy JCE zip from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install unzip] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unzip JCE] ************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JCE policies] *************************************
    # skipping: [atlassian1] => (item=local_policy.jar)  => {"changed": false, "item": "local_policy.jar", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=US_export_policy.jar)  => {"changed": false, "item": "US_export_policy.jar", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded JCE files, if requested] ******
    # skipping: [atlassian1] => (item=/tmp/jce_policy-8.zip)  => {"changed": false, "item": "/tmp/jce_policy-8.zip", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/UnlimitedJCEPolicyJDK8)  => {"changed": false, "item": "/tmp/UnlimitedJCEPolicyJDK8", "skip_reason": "Conditional result was False"}
    # 
    # TASK [local.atlassian_crowd : print some debug information] ************************
    # skipping: [atlassian1] => (item=atlassian_download_tmp = /opt/atlassian/atlassian-crowd-2.11.2.tar.gz)  => {"item": "atlassian_download_tmp = /opt/atlassian/atlassian-crowd-2.11.2.tar.gz", "skipped_reason": "Verbosity threshold not met."}
    # skipping: [atlassian1] => (item=atlassian_crowd_home = /srv/atlassian/crowd)  => {"item": "atlassian_crowd_home = /srv/atlassian/crowd", "skipped_reason": "Verbosity threshold not met."}
    # skipping: [atlassian1] => {"msg": "All items completed"}
    # 
    # TASK [local.atlassian_crowd : create application group] ****************************
    # changed: [atlassian1] => {"changed": true, "gid": 10002, "name": "crowd", "state": "present", "system": false}
    # 
    # TASK [local.atlassian_crowd : create user] *****************************************
    # changed: [atlassian1] => {"changed": true, "comment": "Atlassian Crowd", "create_home": false, "group": 10002, "home": "/nonexistant", "name": "crowd", "shell": "/bin/false", "state": "present", "system": false, "uid": 10002}
    # 
    # TASK [local.atlassian_crowd : create directories] **********************************
    # changed: [atlassian1] => (item={u'owner': u'root', u'path': u'/opt/atlassian', u'group': u'root', u'mode': u'0751'}) => {"changed": true, "gid": 0, "group": "root", "item": {"group": "root", "mode": "0751", "owner": "root", "path": "/opt/atlassian"}, "mode": "0751", "owner": "root", "path": "/opt/atlassian", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 6, "state": "directory", "uid": 0}
    # changed: [atlassian1] => (item={u'owner': u'crowd', u'path': u'/srv/atlassian/crowd', u'group': u'crowd', u'mode': u'0755'}) => {"changed": true, "gid": 10002, "group": "crowd", "item": {"group": "crowd", "mode": "0755", "owner": "crowd", "path": "/srv/atlassian/crowd"}, "mode": "0755", "owner": "crowd", "path": "/srv/atlassian/crowd", "secontext": "unconfined_u:object_r:var_t:s0", "size": 6, "state": "directory", "uid": 10002}
    # 
    # TASK [local.atlassian_crowd : download atlassian-crowd tar.gz] *********************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "3a1dac7ea6b89a32f647d428384c0a358aae5e8c", "dest": "/opt/atlassian/atlassian-crowd-2.11.2.tar.gz", "gid": 0, "group": "root", "md5sum": "c34c3f039ca7d41b020cab87fcd850e4", "mode": "0644", "msg": "OK (178523922 bytes)", "owner": "root", "secontext": "system_u:object_r:usr_t:s0", "size": 178523922, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542366978.24-5330689258497/tmpqgmvWe", "state": "file", "status_code": 200, "uid": 0, "url": "https://www.atlassian.com/software/crowd/downloads/binary//atlassian-crowd-2.11.2.tar.gz"}
    # 
    # TASK [local.atlassian_crowd : ensure unarchive programs are installed] *************
    # changed: [atlassian1] => {"changed": true, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package unzip.x86_64 0:6.0-19.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package          Arch              Version               Repository       Size\n================================================================================\nInstalling:\n unzip            x86_64            6.0-19.el7            base            170 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal download size: 170 k\nInstalled size: 365 k\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : unzip-6.0-19.el7.x86_64                                      1/1 \n  Verifying  : unzip-6.0-19.el7.x86_64                                      1/1 \n\nInstalled:\n  unzip.x86_64 0:6.0-19.el7                                                     \n\nComplete!\n"]}
    # 
    # TASK [local.atlassian_crowd : extract downloaded atlassian-crowd tar.gz] ***********
    # changed: [atlassian1] => {"changed": true, "dest": "/opt/atlassian", "extract_results": {"cmd": ["/bin/gtar", "--extract", "-C", "/opt/atlassian", "-z", "--owner=crowd", "--group=crowd", "-f", "/opt/atlassian/atlassian-crowd-2.11.2.tar.gz"], "err": "", "out": "", "rc": 0}, "gid": 0, "group": "root", "handler": "TgzArchive", "mode": "0751", "owner": "root", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 73, "src": "/opt/atlassian/atlassian-crowd-2.11.2.tar.gz", "state": "directory", "uid": 0}
    # 
    # TASK [local.atlassian_crowd : fix directory permissions] ***************************
    # ok: [atlassian1] => (item={u'owner': u'crowd', u'path': u'/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/temp', u'group': u'crowd'}) => {"changed": false, "gid": 10002, "group": "crowd", "item": {"group": "crowd", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/temp"}, "mode": "0775", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/temp", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 30, "state": "directory", "uid": 10002}
    # ok: [atlassian1] => (item={u'owner': u'crowd', u'path': u'/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/work', u'group': u'crowd'}) => {"changed": false, "gid": 10002, "group": "crowd", "item": {"group": "crowd", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/work"}, "mode": "0775", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/work", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 6, "state": "directory", "uid": 10002}
    # ok: [atlassian1] => (item={u'owner': u'crowd', u'path': u'/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/logs', u'group': u'crowd'}) => {"changed": false, "gid": 10002, "group": "crowd", "item": {"group": "crowd", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/logs"}, "mode": "0775", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/logs", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 6, "state": "directory", "uid": 10002}
    # 
    # TASK [local.atlassian_crowd : fix shell script permissions (find)] *****************
    # changed: [atlassian1] => {"changed": true, "cmd": "find /opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin -type f -name '*.sh'", "delta": "0:00:00.004243", "end": "2018-11-16 11:17:11.528498", "rc": 0, "start": "2018-11-16 11:17:11.524255", "stderr": "", "stderr_lines": [], "stdout": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setenv.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/catalina.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setclasspath.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/version.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/configtest.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/startup.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/digest.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/daemon.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/shutdown.sh\n/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/tool-wrapper.sh", "stdout_lines": ["/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setenv.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/catalina.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setclasspath.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/version.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/configtest.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/startup.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/digest.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/daemon.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/shutdown.sh", "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/tool-wrapper.sh"]}
    # 
    # TASK [local.atlassian_crowd : fix shell script permissions (change)] ***************
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setenv.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setenv.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setenv.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 370, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/catalina.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/catalina.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/catalina.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 21122, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setclasspath.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setclasspath.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/setclasspath.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 3547, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/version.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/version.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/version.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 1908, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/configtest.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/configtest.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/configtest.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 1922, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/startup.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/startup.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/startup.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 1904, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/digest.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/digest.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/digest.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 1965, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/daemon.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/daemon.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/daemon.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 7888, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/shutdown.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/shutdown.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/shutdown.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 1902, "state": "file", "uid": 10002}
    # changed: [atlassian1] => (item=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/tool-wrapper.sh) => {"changed": true, "gid": 10002, "group": "crowd", "item": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/tool-wrapper.sh", "mode": "0754", "owner": "crowd", "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/tool-wrapper.sh", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 5024, "state": "file", "uid": 10002}
    # 
    # TASK [local.atlassian_crowd : Download Postgresql JDBC driver] *********************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "938ede0cdf862cc4eaba5023a86254783af1d261", "dest": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/lib/postgresql-42.0.0.jar", "gid": 10002, "group": "crowd", "md5sum": "c67163ca764bfe632f28229c142131b5", "mode": "0644", "msg": "OK (707261 bytes)", "owner": "crowd", "secontext": "system_u:object_r:lib_t:s0", "size": 707261, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542367035.64-231745073286881/tmpuPz_aL", "state": "file", "status_code": 200, "uid": 10002, "url": "https://jdbc.postgresql.org/download/postgresql-42.0.0.jar"}
    # 
    # TASK [local.atlassian_crowd : Delete installed Postgresql driver] ******************
    # changed: [atlassian1] => {"changed": true, "path": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/lib/postgresql-9.2-1003-jdbc4.jar", "state": "absent"}
    # 
    # TASK [local.atlassian_crowd : update build.properties] *****************************
    # changed: [atlassian1] => (item={u'key': u'hibernate.dialect', u'value': u'org.hibernate.dialect.PostgreSQLDialect'}) => {"backup": "", "changed": true, "item": {"key": "hibernate.dialect", "value": "org.hibernate.dialect.PostgreSQLDialect"}, "msg": "line replaced"}
    # ok: [atlassian1] => (item={u'key': u'crowd.url', u'value': u'http://localhost:8095/crowd'}) => {"backup": "", "changed": false, "item": {"key": "crowd.url", "value": "http://localhost:8095/crowd"}, "msg": ""}
    # ok: [atlassian1] => (item={u'key': u'demo.url', u'value': u'http://localhost:8095/demo'}) => {"backup": "", "changed": false, "item": {"key": "demo.url", "value": "http://localhost:8095/demo"}, "msg": ""}
    # ok: [atlassian1] => (item={u'key': u'openidserver.url', u'value': u'http://localhost:8095/openidserver'}) => {"backup": "", "changed": false, "item": {"key": "openidserver.url", "value": "http://localhost:8095/openidserver"}, "msg": ""}
    # 
    # TASK [local.atlassian_crowd : run build.sh] ****************************************
    #  [WARNING]: Unable to use /nonexistant/.ansible/tmp as temporary directory, failing
    # back to system: [Errno 13] Permission denied: '/nonexistant'
    # changed: [atlassian1] => {"changed": true, "cmd": ["./build.sh"], "delta": "0:00:00.462465", "end": "2018-11-16 11:17:21.624372", "rc": 0, "start": "2018-11-16 11:17:21.161907", "stderr": "", "stderr_lines": [], "stdout": "Buildfile: build.xml\n\ninit:\n\nassistant:\nChanging Tomcat's connector port to 8095\nChanging Tomcat's shutdown port to 8020\nConfiguring the Crowd console\nUpdating crowd.properties: crowd-webapp/WEB-INF/classes\nCopying 1 file to /opt/atlassian/atlassian-crowd-2.11.2/crowd-webapp/WEB-INF/classes\nUpdating property file: /opt/atlassian/atlassian-crowd-2.11.2/crowd-webapp/WEB-INF/classes/crowd.properties\nConfiguring the Demo application\nUpdating crowd.properties: demo-webapp/WEB-INF/classes\nUpdating property file: /opt/atlassian/atlassian-crowd-2.11.2/demo-webapp/WEB-INF/classes/crowd.properties\nConfiguring the OpenID server application\nUpdating crowd.properties: crowd-openidserver-webapp/WEB-INF/classes\nUpdating property file: /opt/atlassian/atlassian-crowd-2.11.2/crowd-openidserver-webapp/WEB-INF/classes/crowd.properties\nConfiguring the OpenID hibernate configuration\nUpdating the HibernateDialect and TransactionFactory in crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties\nUpdating property file: /opt/atlassian/atlassian-crowd-2.11.2/crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties\n\nBUILD SUCCESSFUL\nTotal time: 0 seconds", "stdout_lines": ["Buildfile: build.xml", "", "init:", "", "assistant:", "Changing Tomcat's connector port to 8095", "Changing Tomcat's shutdown port to 8020", "Configuring the Crowd console", "Updating crowd.properties: crowd-webapp/WEB-INF/classes", "Copying 1 file to /opt/atlassian/atlassian-crowd-2.11.2/crowd-webapp/WEB-INF/classes", "Updating property file: /opt/atlassian/atlassian-crowd-2.11.2/crowd-webapp/WEB-INF/classes/crowd.properties", "Configuring the Demo application", "Updating crowd.properties: demo-webapp/WEB-INF/classes", "Updating property file: /opt/atlassian/atlassian-crowd-2.11.2/demo-webapp/WEB-INF/classes/crowd.properties", "Configuring the OpenID server application", "Updating crowd.properties: crowd-openidserver-webapp/WEB-INF/classes", "Updating property file: /opt/atlassian/atlassian-crowd-2.11.2/crowd-openidserver-webapp/WEB-INF/classes/crowd.properties", "Configuring the OpenID hibernate configuration", "Updating the HibernateDialect and TransactionFactory in crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties", "Updating property file: /opt/atlassian/atlassian-crowd-2.11.2/crowd-openidserver-webapp/WEB-INF/classes/jdbc.properties", "", "BUILD SUCCESSFUL", "Total time: 0 seconds"]}
    # 
    # TASK [local.atlassian_crowd : set crowd.home variable] *****************************
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [local.atlassian_crowd : Copy openidserver webapp config] *********************
    # changed: [atlassian1] => {"changed": true, "checksum": "924d88731fbb8718a0c8e9a8fc2db54ae49dd532", "dest": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/conf/Catalina/localhost/openidserver.xml", "gid": 10002, "group": "crowd", "md5sum": "a8b106dec45174a684624894de755ab0", "mode": "0664", "owner": "crowd", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 1023, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542367042.42-151401739410364/source", "state": "file", "uid": 10002}
    # 
    # TASK [local.atlassian_crowd : Add proxy endpoint address to server.xml] ************
    # changed: [atlassian1] => {"changed": true, "checksum": "73e04dbfb4cf567605e5533f19ba68345ff47e94", "dest": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/conf/server.xml", "gid": 10002, "group": "crowd", "md5sum": "d0063f25ed9ffb138bf2ceef04b96cf5", "mode": "0664", "owner": "crowd", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 2045, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542367043.54-198334688026839/source", "state": "file", "uid": 10002}
    # 
    # TASK [local.atlassian_crowd : modify JVM properties] *******************************
    # ok: [atlassian1] => {"backup": "", "changed": false, "msg": ""}
    # 
    # TASK [local.atlassian_crowd : check, if crowd.cfg.xml exists] **********************
    # ok: [atlassian1] => {"changed": false, "stat": {"exists": false}}
    # 
    # TASK [local.atlassian_crowd : configure connection pool] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [local.atlassian_crowd : create systemd service definition] *******************
    # changed: [atlassian1] => {"changed": true, "checksum": "6ce386f158f3207801fc51d1d5fd52cd7f25e53e", "dest": "/usr/lib/systemd/system/crowd.service", "gid": 0, "group": "root", "md5sum": "375a53d3db5205a0f9990f15a5ee6e4c", "mode": "0644", "owner": "root", "secontext": "system_u:object_r:systemd_unit_file_t:s0", "size": 354, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542367045.59-168219073034170/source", "state": "file", "uid": 0}
    # 
    # TASK [local.atlassian_crowd : restart service if service definition changed] *******
    # ok: [atlassian1] => {
    #     "msg": "restarting service"
    # }
    # 
    # TASK [local.atlassian_crowd : Enable Service on startup] ***************************
    # changed: [atlassian1] => {"changed": true, "enabled": true, "name": "crowd", "state": "started", "status": {"ActiveEnterTimestampMonotonic": "0", "ActiveExitTimestampMonotonic": "0", "ActiveState": "inactive", "After": "network.target basic.target system.slice systemd-journald.socket", "AllowIsolate": "no", "AssertResult": "no", "AssertTimestampMonotonic": "0", "Before": "shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "no", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "no", "ConditionTimestampMonotonic": "0", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "Crowd Identity management for web apps", "DevicePolicy": "auto", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "0", "ExecMainStartTimestampMonotonic": "0", "ExecMainStatus": "0", "ExecStart": "{ path=/opt/atlassian/atlassian-crowd-2.11.2/start_crowd.sh ; argv[]=/opt/atlassian/atlassian-crowd-2.11.2/start_crowd.sh ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStop": "{ path=/opt/atlassian/atlassian-crowd-2.11.2/stop_crowd.sh ; argv[]=/opt/atlassian/atlassian-crowd-2.11.2/stop_crowd.sh ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/crowd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "crowd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestampMonotonic": "0", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "control-group", "KillSignal": "15", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "31210", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "31210", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "crowd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "none", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PIDFile": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/work/catalina.pid", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "no", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "forking", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "User": "crowd", "Wants": "system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}
    # 
    # RUNNING HANDLER [local.atlassian_crowd : start crowd] ******************************
    # ok: [atlassian1] => {"changed": false, "name": "crowd", "state": "started", "status": {"ActiveEnterTimestamp": "Fri 2018-11-16 11:17:27 UTC", "ActiveEnterTimestampMonotonic": "2638456768", "ActiveExitTimestampMonotonic": "0", "ActiveState": "active", "After": "systemd-journald.socket system.slice network.target basic.target", "AllowIsolate": "no", "AssertResult": "yes", "AssertTimestamp": "Fri 2018-11-16 11:17:27 UTC", "AssertTimestampMonotonic": "2638425505", "Before": "shutdown.target multi-user.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "no", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Fri 2018-11-16 11:17:27 UTC", "ConditionTimestampMonotonic": "2638425505", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/crowd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "Crowd Identity management for web apps", "DevicePolicy": "auto", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "12957", "ExecMainStartTimestamp": "Fri 2018-11-16 11:17:27 UTC", "ExecMainStartTimestampMonotonic": "2638456726", "ExecMainStatus": "0", "ExecStart": "{ path=/opt/atlassian/atlassian-crowd-2.11.2/start_crowd.sh ; argv[]=/opt/atlassian/atlassian-crowd-2.11.2/start_crowd.sh ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStop": "{ path=/opt/atlassian/atlassian-crowd-2.11.2/stop_crowd.sh ; argv[]=/opt/atlassian/atlassian-crowd-2.11.2/stop_crowd.sh ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/crowd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "crowd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestamp": "Fri 2018-11-16 11:17:27 UTC", "InactiveExitTimestampMonotonic": "2638426988", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "control-group", "KillSignal": "15", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "31210", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "31210", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "12957", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "crowd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "none", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PIDFile": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/work/catalina.pid", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "no", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "forking", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "enabled", "User": "crowd", "WantedBy": "multi-user.target", "Wants": "system.slice", "WatchdogTimestamp": "Fri 2018-11-16 11:17:27 UTC", "WatchdogTimestampMonotonic": "2638456744", "WatchdogUSec": "0"}}
    # 
    # RUNNING HANDLER [local.atlassian_crowd : restart crowd] ****************************
    # changed: [atlassian1] => {"changed": true, "name": "crowd", "state": "started", "status": {"ActiveEnterTimestamp": "Fri 2018-11-16 11:17:27 UTC", "ActiveEnterTimestampMonotonic": "2638456768", "ActiveExitTimestampMonotonic": "0", "ActiveState": "active", "After": "network.target systemd-journald.socket basic.target system.slice", "AllowIsolate": "no", "AssertResult": "yes", "AssertTimestamp": "Fri 2018-11-16 11:17:27 UTC", "AssertTimestampMonotonic": "2638425505", "Before": "shutdown.target multi-user.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "no", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Fri 2018-11-16 11:17:27 UTC", "ConditionTimestampMonotonic": "2638425505", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/crowd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "Crowd Identity management for web apps", "DevicePolicy": "auto", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "12957", "ExecMainStartTimestamp": "Fri 2018-11-16 11:17:27 UTC", "ExecMainStartTimestampMonotonic": "2638456726", "ExecMainStatus": "0", "ExecStart": "{ path=/opt/atlassian/atlassian-crowd-2.11.2/start_crowd.sh ; argv[]=/opt/atlassian/atlassian-crowd-2.11.2/start_crowd.sh ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStop": "{ path=/opt/atlassian/atlassian-crowd-2.11.2/stop_crowd.sh ; argv[]=/opt/atlassian/atlassian-crowd-2.11.2/stop_crowd.sh ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/crowd.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "crowd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestamp": "Fri 2018-11-16 11:17:27 UTC", "InactiveExitTimestampMonotonic": "2638426988", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "control-group", "KillSignal": "15", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "31210", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "31210", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "12957", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "crowd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "none", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PIDFile": "/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/work/catalina.pid", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "no", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TimeoutStartUSec": "1min 30s", "TimeoutStopUSec": "1min 30s", "TimerSlackNSec": "50000", "Transient": "no", "Type": "forking", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "enabled", "User": "crowd", "WantedBy": "multi-user.target", "Wants": "system.slice", "WatchdogTimestamp": "Fri 2018-11-16 11:17:27 UTC", "WatchdogTimestampMonotonic": "2638456744", "WatchdogUSec": "0"}}
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=49   changed=29   unreachable=0    failed=0   


<a id="org9c4f284"></a>

#### Run Configuration Wizard

Be patient. First time accessing this page will take some time.

<http://192.168.56.31:8095/crowd/console>

-   License key

    When prompted later for the **License type**, always choose **<Product> Software (Server)**
    
    -   Manage the entire application on your own servers or virtual machines.
    -   Deployable to a single server.
    
    Click on **An evaluation license key is available from the `Atlassian website`**
    
        https://my.atlassian.com/products/index?sen=12663443&evalId=12663443&eval=true#license_12663443
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    
    <col  class="org-left" />
    
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <thead>
    <tr>
    <th scope="col" class="org-left">SEN</th>
    <th scope="col" class="org-left">Product</th>
    <th scope="col" class="org-left">Name</th>
    <th scope="col" class="org-left">Support Expires</th>
    <th scope="col" class="org-left">Support</th>
    </tr>
    </thead>
    
    <tbody>
    <tr>
    <td class="org-left">SEN-L12663443</td>
    <td class="org-left">Crowd (Server) Unlimited Users: Evaluation</td>
    <td class="org-left">Opitz Consulting</td>
    <td class="org-left">15 Dec 2018</td>
    <td class="org-left">Request Support</td>
    </tr>
    </tbody>
    </table>
    
        SEN:         SEN-L12663443
        Server ID:   BN4K-VUOS-XN1O-GKL4 
        License key: AAABOQ0ODAoPeNqFkV1LwzAYhe/zKwLe6EXG0tUig4DaVhnrWrHb8MKbGN/NYJaUJK3OX2+71k8EL
        wLhPclzzkmOrqzEuWkwjfD4dBpMpu0mLpc4GNMzlIATVlZeGs1ia14e8XEJtgF7cj/FacNVzTsNi
        U4bceFlA8zbGlBs4SAl3APrWIRSQiMUG+3bcznfAWuMegY7egOlzk0l/RsRRrtaeam3I2F2A7b03
        HqwbMOVg2GWSQHawXJfwQEVF4tFehvPLrIPh3TBpfrf4qtEn1v14DVY180C1GK0B821gPS1knb/r
        VHQNSrslmvpekbReeD40wP1zzVL2GUezsl6VZTkLqcFuZ5nISrTnLWLZDSIokkYToZ2eb17AFtsV
        q6NwQhFQ90Wk82SnzcG6e9sN7UVT9zB7194B11Wp40wLQIVAI//QeVO1pC/OyPFySAUq08HDX2jA
        hQ3WTO7ucUj+gm+KRZkkjhR+5uw9Q==X02fn

-   Crowd installation

    Here choose the **New installation** option.

-   Database Configuration

    The next step is the database configuration. Choose the **JDBC Connection** option and configure the database with the following settings
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <thead>
    <tr>
    <th scope="col" class="org-left">Option</th>
    <th scope="col" class="org-left">Value</th>
    </tr>
    </thead>
    
    <tbody>
    <tr>
    <td class="org-left">Database</td>
    <td class="org-left">PostgreSQL</td>
    </tr>
    
    
    <tr>
    <td class="org-left">Driver class name</td>
    <td class="org-left">org.postgresql.Driver</td>
    </tr>
    
    
    <tr>
    <td class="org-left">JDBC URL</td>
    <td class="org-left">jdbc:postgresql://localhost:5432/atlassian?currentSchema=crowd&reWriteBatchedInserts=true&prepareThreshold=0</td>
    </tr>
    
    
    <tr>
    <td class="org-left">Username</td>
    <td class="org-left">crowd</td>
    </tr>
    
    
    <tr>
    <td class="org-left">Password</td>
    <td class="org-left">crowd</td>
    </tr>
    
    
    <tr>
    <td class="org-left">Hibernate dialect</td>
    <td class="org-left">org.hibernate.dialect.PostgreSQLDialect</td>
    </tr>
    </tbody>
    </table>

-   Options

    Choose a deployment title, e.g. **OpenDevStack** and set the **Base URL** to
    
    <http://192.168.56.31:8095/crowd>

-   Mail configuration

    For the local test environment a mail server is not necessary, so you can skip
    this step by choosing Later

-   Internal directory

    Enter the name for the internal crowd directory, e.g. **OpenDevStack**

-   Default administrator

    Enter the data for the **default administrator**, so you are able to login to crowd.
    
        Email address: volker.zell@opitz-consulting.com
        Username: vzell
        Password: opendevstack
        Confirm password: opendevstack
        First name: Volker
        Last name: Zell

-   Integrated applications

    Enable both integrated applications.

-   Log in to Crowd console


<a id="orgf9e3339"></a>

#### Configure Crowd

You will have to configure **crowd** to enable the **Atlassian tools** and **Rundeck** to
login with crowd credentials.


<a id="org18f6601"></a>

#### Add OpenDevStack groups

You will have to add the following groups to crowd’s internal directory

To do so, access the crowd console at <http://192.168.56.31:8095/crowd/console/>
Choose the **Groups** menu point and click **Add group**. Enter the group name like shown
below and link it to the created internal directory.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Group</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">opendevstack-users</td>
<td class="org-left">Group for normal users without adminstration rights</td>
</tr>


<tr>
<td class="org-left">opendevstack-administrators</td>
<td class="org-left">Group for administration users</td>
</tr>
</tbody>
</table>


<a id="orgc7f0c86"></a>

#### Add Atlassian groups

You also have to add the groups from the atlassian tools, even if you don’t use them.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Group</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">bitbucket-administrators</td>
<td class="org-left">Bitbucket administrator group</td>
</tr>


<tr>
<td class="org-left">bitbucket-users</td>
<td class="org-left">Bitbucket user group</td>
</tr>


<tr>
<td class="org-left">jira-administrators</td>
<td class="org-left">Jira administrator group</td>
</tr>


<tr>
<td class="org-left">jira-developers</td>
<td class="org-left">Jira developers group</td>
</tr>


<tr>
<td class="org-left">jira-users</td>
<td class="org-left">Jira user group</td>
</tr>


<tr>
<td class="org-left">confluence-administrators</td>
<td class="org-left">Confluence administrator group</td>
</tr>


<tr>
<td class="org-left">confluence-users</td>
<td class="org-left">Confluence user group</td>
</tr>
</tbody>
</table>


<a id="org37d5fe8"></a>

#### Add groups to user

Now you have to add all groups to the administrator. Go to the **Users** section
in Crowd, click on the hyperlink of your **administration user** and open the
**Groups** tab. Click **Add groups**, search for all by leaving the Search fields
empty and add all groups by clicking on **Add selected groups**.


<a id="org8462eb6"></a>

#### TODO Add applications to crowd

You will have to add the applications you want to access with your Crowd
credentials in the Crowd console. Access the Crowd console at

<http://192.168.56.31:8095/crowd/console/>

Choose the Applications menu point and click **Add application**. In the following
wizard enter the data for the application you want to add. See the data for the
applications in the test environment in the table below.

Don't forget to click on the **Add application** button on the final screen after entering the data.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Application type</th>
<th scope="col" class="org-left">Name</th>
<th scope="col" class="org-left">Description</th>
<th scope="col" class="org-left">Password</th>
<th scope="col" class="org-left">URL</th>
<th scope="col" class="org-right">Remote IP address</th>
<th scope="col" class="org-left">Directories</th>
<th scope="col" class="org-left">Authorisation</th>
<th scope="col" class="org-left">Additional Remote Adresses</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Jira</td>
<td class="org-left">jira</td>
<td class="org-left">jira</td>
<td class="org-left">jira</td>
<td class="org-left"><http://192.168.56.31:8080></td>
<td class="org-right">192.168.56.31</td>
<td class="org-left">Internal directory with OpenDevStack groups</td>
<td class="org-left">all users</td>
<td class="org-left">0.0.0.0/0</td>
</tr>


<tr>
<td class="org-left">Confluence</td>
<td class="org-left">confluence</td>
<td class="org-left">confluence</td>
<td class="org-left">confluence</td>
<td class="org-left"><http://192.168.56.31:8090></td>
<td class="org-right">192.168.56.31</td>
<td class="org-left">Internal directory with OpenDevStack groups</td>
<td class="org-left">all users</td>
<td class="org-left">0.0.0.0/0</td>
</tr>


<tr>
<td class="org-left">Bitbucket Server</td>
<td class="org-left">bitbucket</td>
<td class="org-left">bitbucket</td>
<td class="org-left">bitbucket</td>
<td class="org-left"><http://192.168.56.31:7990></td>
<td class="org-right">192.168.56.31</td>
<td class="org-left">Internal directory with OpenDevStack groups</td>
<td class="org-left">all users</td>
<td class="org-left">0.0.0.0/0</td>
</tr>


<tr>
<td class="org-left">Generic application</td>
<td class="org-left">rundeck</td>
<td class="org-left">rundeck</td>
<td class="org-left">secret</td>
<td class="org-left"><http://192.168.56.31:4440/rundeck></td>
<td class="org-right">192.168.56.31</td>
<td class="org-left">Internal directory with OpenDevStack groups</td>
<td class="org-left">all users</td>
<td class="org-left">0.0.0.0/0</td>
</tr>


<tr>
<td class="org-left">Generic application</td>
<td class="org-left">provision</td>
<td class="org-left">provision</td>
<td class="org-left">provision</td>
<td class="org-left"><http://192.168.56.1:8088></td>
<td class="org-right">192.168.56.1</td>
<td class="org-left">Internal directory with OpenDevStack groups</td>
<td class="org-left">all users</td>
<td class="org-left">0.0.0.0/0</td>
</tr>


<tr>
<td class="org-left">Generic application</td>
<td class="org-left">sonarqube</td>
<td class="org-left">sonarqube</td>
<td class="org-left">sonarqube</td>
<td class="org-left"><https://sonarqube-cd.192.168.99.100.nip.io></td>
<td class="org-right">192.168.56.1</td>
<td class="org-left">Internal directory with OpenDevStack groups</td>
<td class="org-left">all users</td>
<td class="org-left">0.0.0.0/0</td>
</tr>
</tbody>
</table>

After adding all the applications edit each one, go to the **Remote adresses** tab and add **0.0.0.0/0**


<a id="org57398b1"></a>

### Bitbucket Setup


<a id="org471ee82"></a>

#### Setup Application

    ansible-playbook -v -i inventories/dev playbooks/bitbucket.yml --ask-vault
    opendevstack

    # Using /vagrant/ansible/ansible.cfg as config file
    # Vault password: opendevstack
    # 
    # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
    # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
    # 
    # PLAY [tag_hostgroup_bitbucket_test] ************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [geerlingguy.git : Ensure git is installed (RedHat).] *************************
    # skipping: [atlassian1] => (item=git)  => {"changed": false, "item": "git", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=git-svn)  => {"changed": false, "item": "git-svn", "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.git : Update apt cache (Debian).] ********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.git : Ensure git is installed (Debian).] *************************
    # [DEPRECATION WARNING]: Invoking "apt" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: u'{{ git_packages }}'` and remove 
    # the loop. This feature will be removed in version 2.11. Deprecation warnings can be
    #  disabled by setting deprecation_warnings=False in ansible.cfg.
    # skipping: [atlassian1] => (item=[])  => {"changed": false, "item": [], "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.git : Ensure git's dependencies are installed (RedHat).] *********
    # changed: [atlassian1] => (item=perl-ExtUtils-MakeMaker) => {"changed": true, "item": "perl-ExtUtils-MakeMaker", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package perl-ExtUtils-MakeMaker.noarch 0:6.68-3.el7 will be installed\n--> Processing Dependency: perl(Test::Harness) for package: perl-ExtUtils-MakeMaker-6.68-3.el7.noarch\n--> Processing Dependency: perl(ExtUtils::Packlist) for package: perl-ExtUtils-MakeMaker-6.68-3.el7.noarch\n--> Processing Dependency: perl(ExtUtils::Manifest) for package: perl-ExtUtils-MakeMaker-6.68-3.el7.noarch\n--> Processing Dependency: perl(ExtUtils::Installed) for package: perl-ExtUtils-MakeMaker-6.68-3.el7.noarch\n--> Processing Dependency: perl(ExtUtils::Install) for package: perl-ExtUtils-MakeMaker-6.68-3.el7.noarch\n--> Running transaction check\n---> Package perl-ExtUtils-Install.noarch 0:1.58-292.el7 will be installed\n--> Processing Dependency: perl-devel for package: perl-ExtUtils-Install-1.58-292.el7.noarch\n---> Package perl-ExtUtils-Manifest.noarch 0:1.61-244.el7 will be installed\n---> Package perl-Test-Harness.noarch 0:3.28-3.el7 will be installed\n--> Running transaction check\n---> Package perl-devel.x86_64 4:5.16.3-292.el7 will be installed\n--> Processing Dependency: systemtap-sdt-devel for package: 4:perl-devel-5.16.3-292.el7.x86_64\n--> Processing Dependency: perl(ExtUtils::ParseXS) for package: 4:perl-devel-5.16.3-292.el7.x86_64\n--> Processing Dependency: libdb-devel for package: 4:perl-devel-5.16.3-292.el7.x86_64\n--> Processing Dependency: glibc-devel for package: 4:perl-devel-5.16.3-292.el7.x86_64\n--> Processing Dependency: gdbm-devel for package: 4:perl-devel-5.16.3-292.el7.x86_64\n--> Running transaction check\n---> Package gdbm-devel.x86_64 0:1.10-8.el7 will be installed\n---> Package glibc-devel.x86_64 0:2.17-222.el7 will be installed\n--> Processing Dependency: glibc-headers = 2.17-222.el7 for package: glibc-devel-2.17-222.el7.x86_64\n--> Processing Dependency: glibc = 2.17-222.el7 for package: glibc-devel-2.17-222.el7.x86_64\n--> Processing Dependency: glibc-headers for package: glibc-devel-2.17-222.el7.x86_64\n---> Package libdb-devel.x86_64 0:5.3.21-24.el7 will be installed\n--> Processing Dependency: libdb(x86-64) = 5.3.21-24.el7 for package: libdb-devel-5.3.21-24.el7.x86_64\n---> Package perl-ExtUtils-ParseXS.noarch 1:3.18-3.el7 will be installed\n---> Package systemtap-sdt-devel.x86_64 0:3.2-8.el7_5 will be installed\n--> Processing Dependency: pyparsing for package: systemtap-sdt-devel-3.2-8.el7_5.x86_64\n--> Running transaction check\n---> Package glibc.x86_64 0:2.17-157.el7_3.5 will be updated\n--> Processing Dependency: glibc = 2.17-157.el7_3.5 for package: glibc-common-2.17-157.el7_3.5.x86_64\n---> Package glibc.x86_64 0:2.17-222.el7 will be an update\n---> Package glibc-headers.x86_64 0:2.17-222.el7 will be installed\n--> Processing Dependency: kernel-headers >= 2.2.1 for package: glibc-headers-2.17-222.el7.x86_64\n--> Processing Dependency: kernel-headers for package: glibc-headers-2.17-222.el7.x86_64\n---> Package libdb.x86_64 0:5.3.21-19.el7 will be updated\n--> Processing Dependency: libdb(x86-64) = 5.3.21-19.el7 for package: libdb-utils-5.3.21-19.el7.x86_64\n---> Package libdb.x86_64 0:5.3.21-24.el7 will be an update\n---> Package pyparsing.noarch 0:1.5.6-9.el7 will be installed\n--> Running transaction check\n---> Package glibc-common.x86_64 0:2.17-157.el7_3.5 will be updated\n---> Package glibc-common.x86_64 0:2.17-222.el7 will be an update\n---> Package kernel-headers.x86_64 0:3.10.0-862.14.4.el7 will be installed\n---> Package libdb-utils.x86_64 0:5.3.21-19.el7 will be updated\n---> Package libdb-utils.x86_64 0:5.3.21-24.el7 will be an update\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                    Arch      Version                  Repository  Size\n================================================================================\nInstalling:\n perl-ExtUtils-MakeMaker    noarch    6.68-3.el7               base       275 k\nInstalling for dependencies:\n gdbm-devel                 x86_64    1.10-8.el7               base        47 k\n glibc-devel                x86_64    2.17-222.el7             base       1.1 M\n glibc-headers              x86_64    2.17-222.el7             base       678 k\n kernel-headers             x86_64    3.10.0-862.14.4.el7      updates    7.1 M\n libdb-devel                x86_64    5.3.21-24.el7            base        38 k\n perl-ExtUtils-Install      noarch    1.58-292.el7             base        74 k\n perl-ExtUtils-Manifest     noarch    1.61-244.el7             base        31 k\n perl-ExtUtils-ParseXS      noarch    1:3.18-3.el7             base        77 k\n perl-Test-Harness          noarch    3.28-3.el7               base       302 k\n perl-devel                 x86_64    4:5.16.3-292.el7         base       453 k\n pyparsing                  noarch    1.5.6-9.el7              base        94 k\n systemtap-sdt-devel        x86_64    3.2-8.el7_5              updates     73 k\nUpdating for dependencies:\n glibc                      x86_64    2.17-222.el7             base       3.6 M\n glibc-common               x86_64    2.17-222.el7             base        11 M\n libdb                      x86_64    5.3.21-24.el7            base       720 k\n libdb-utils                x86_64    5.3.21-24.el7            base       132 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package  (+12 Dependent packages)\nUpgrade             (  4 Dependent packages)\n\nTotal download size: 26 M\nDownloading packages:\nDelta RPMs disabled because /usr/bin/applydeltarpm not installed.\n--------------------------------------------------------------------------------\nTotal                                              5.5 MB/s |  26 MB  00:04     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Updating   : glibc-2.17-222.el7.x86_64                                   1/21 \nwarning: /etc/nsswitch.conf created as /etc/nsswitch.conf.rpmnew\n  Updating   : glibc-common-2.17-222.el7.x86_64                            2/21 \n  Updating   : libdb-5.3.21-24.el7.x86_64                                  3/21 \n  Installing : libdb-devel-5.3.21-24.el7.x86_64                            4/21 \n  Installing : pyparsing-1.5.6-9.el7.noarch                                5/21 \n  Installing : systemtap-sdt-devel-3.2-8.el7_5.x86_64                      6/21 \n  Installing : gdbm-devel-1.10-8.el7.x86_64                                7/21 \n  Installing : kernel-headers-3.10.0-862.14.4.el7.x86_64                   8/21 \n  Installing : glibc-headers-2.17-222.el7.x86_64                           9/21 \n  Installing : glibc-devel-2.17-222.el7.x86_64                            10/21 \n  Installing : perl-ExtUtils-Manifest-1.61-244.el7.noarch                 11/21 \n  Installing : perl-Test-Harness-3.28-3.el7.noarch                        12/21 \n  Installing : perl-ExtUtils-MakeMaker-6.68-3.el7.noarch                  13/21 \n  Installing : perl-ExtUtils-Install-1.58-292.el7.noarch                  14/21 \n  Installing : 1:perl-ExtUtils-ParseXS-3.18-3.el7.noarch                  15/21 \n  Installing : 4:perl-devel-5.16.3-292.el7.x86_64                         16/21 \n  Updating   : libdb-utils-5.3.21-24.el7.x86_64                           17/21 \n  Cleanup    : libdb-utils-5.3.21-19.el7.x86_64                           18/21 \n  Cleanup    : libdb-5.3.21-19.el7.x86_64                                 19/21 \n  Cleanup    : glibc-common-2.17-157.el7_3.5.x86_64                       20/21 \n  Cleanup    : glibc-2.17-157.el7_3.5.x86_64                              21/21 \n  Verifying  : libdb-5.3.21-24.el7.x86_64                                  1/21 \n  Verifying  : perl-ExtUtils-Install-1.58-292.el7.noarch                   2/21 \n  Verifying  : 1:perl-ExtUtils-ParseXS-3.18-3.el7.noarch                   3/21 \n  Verifying  : perl-Test-Harness-3.28-3.el7.noarch                         4/21 \n  Verifying  : glibc-devel-2.17-222.el7.x86_64                             5/21 \n  Verifying  : systemtap-sdt-devel-3.2-8.el7_5.x86_64                      6/21 \n  Verifying  : libdb-devel-5.3.21-24.el7.x86_64                            7/21 \n  Verifying  : perl-ExtUtils-Manifest-1.61-244.el7.noarch                  8/21 \n  Verifying  : 4:perl-devel-5.16.3-292.el7.x86_64                          9/21 \n  Verifying  : glibc-headers-2.17-222.el7.x86_64                          10/21 \n  Verifying  : kernel-headers-3.10.0-862.14.4.el7.x86_64                  11/21 \n  Verifying  : glibc-common-2.17-222.el7.x86_64                           12/21 \n  Verifying  : glibc-2.17-222.el7.x86_64                                  13/21 \n  Verifying  : gdbm-devel-1.10-8.el7.x86_64                               14/21 \n  Verifying  : perl-ExtUtils-MakeMaker-6.68-3.el7.noarch                  15/21 \n  Verifying  : pyparsing-1.5.6-9.el7.noarch                               16/21 \n  Verifying  : libdb-utils-5.3.21-24.el7.x86_64                           17/21 \n  Verifying  : libdb-utils-5.3.21-19.el7.x86_64                           18/21 \n  Verifying  : glibc-common-2.17-157.el7_3.5.x86_64                       19/21 \n  Verifying  : libdb-5.3.21-19.el7.x86_64                                 20/21 \n  Verifying  : glibc-2.17-157.el7_3.5.x86_64                              21/21 \n\nInstalled:\n  perl-ExtUtils-MakeMaker.noarch 0:6.68-3.el7                                   \n\nDependency Installed:\n  gdbm-devel.x86_64 0:1.10-8.el7                                                \n  glibc-devel.x86_64 0:2.17-222.el7                                             \n  glibc-headers.x86_64 0:2.17-222.el7                                           \n  kernel-headers.x86_64 0:3.10.0-862.14.4.el7                                   \n  libdb-devel.x86_64 0:5.3.21-24.el7                                            \n  perl-ExtUtils-Install.noarch 0:1.58-292.el7                                   \n  perl-ExtUtils-Manifest.noarch 0:1.61-244.el7                                  \n  perl-ExtUtils-ParseXS.noarch 1:3.18-3.el7                                     \n  perl-Test-Harness.noarch 0:3.28-3.el7                                         \n  perl-devel.x86_64 4:5.16.3-292.el7                                            \n  pyparsing.noarch 0:1.5.6-9.el7                                                \n  systemtap-sdt-devel.x86_64 0:3.2-8.el7_5                                      \n\nDependency Updated:\n  glibc.x86_64 0:2.17-222.el7         glibc-common.x86_64 0:2.17-222.el7       \n  libdb.x86_64 0:5.3.21-24.el7        libdb-utils.x86_64 0:5.3.21-24.el7       \n\nComplete!\n"]}
    # changed: [atlassian1] => (item=autoconf) => {"changed": true, "item": "autoconf", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package autoconf.noarch 0:2.69-11.el7 will be installed\n--> Processing Dependency: perl(Data::Dumper) for package: autoconf-2.69-11.el7.noarch\n--> Running transaction check\n---> Package perl-Data-Dumper.x86_64 0:2.145-3.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                  Arch           Version             Repository    Size\n================================================================================\nInstalling:\n autoconf                 noarch         2.69-11.el7         base         701 k\nInstalling for dependencies:\n perl-Data-Dumper         x86_64         2.145-3.el7         base          47 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+1 Dependent package)\n\nTotal download size: 748 k\nInstalled size: 2.3 M\nDownloading packages:\n--------------------------------------------------------------------------------\nTotal                                              2.8 MB/s | 748 kB  00:00     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : perl-Data-Dumper-2.145-3.el7.x86_64                          1/2 \n  Installing : autoconf-2.69-11.el7.noarch                                  2/2 \n  Verifying  : perl-Data-Dumper-2.145-3.el7.x86_64                          1/2 \n  Verifying  : autoconf-2.69-11.el7.noarch                                  2/2 \n\nInstalled:\n  autoconf.noarch 0:2.69-11.el7                                                 \n\nDependency Installed:\n  perl-Data-Dumper.x86_64 0:2.145-3.el7                                         \n\nComplete!\n"]}
    # changed: [atlassian1] => (item=libcurl-devel) => {"changed": true, "item": "libcurl-devel", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.netcologne.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package libcurl-devel.x86_64 0:7.29.0-46.el7 will be installed\n--> Processing Dependency: libcurl = 7.29.0-46.el7 for package: libcurl-devel-7.29.0-46.el7.x86_64\n--> Running transaction check\n---> Package libcurl.x86_64 0:7.29.0-35.el7.centos will be updated\n--> Processing Dependency: libcurl = 7.29.0-35.el7.centos for package: curl-7.29.0-35.el7.centos.x86_64\n---> Package libcurl.x86_64 0:7.29.0-46.el7 will be an update\n--> Running transaction check\n---> Package curl.x86_64 0:7.29.0-35.el7.centos will be updated\n---> Package curl.x86_64 0:7.29.0-46.el7 will be an update\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package               Arch           Version                Repository    Size\n================================================================================\nInstalling:\n libcurl-devel         x86_64         7.29.0-46.el7          base         300 k\nUpdating for dependencies:\n curl                  x86_64         7.29.0-46.el7          base         268 k\n libcurl               x86_64         7.29.0-46.el7          base         220 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package\nUpgrade             ( 2 Dependent packages)\n\nTotal download size: 789 k\nDownloading packages:\nDelta RPMs disabled because /usr/bin/applydeltarpm not installed.\n--------------------------------------------------------------------------------\nTotal                                              2.5 MB/s | 789 kB  00:00     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Updating   : libcurl-7.29.0-46.el7.x86_64                                 1/5 \n  Updating   : curl-7.29.0-46.el7.x86_64                                    2/5 \n  Installing : libcurl-devel-7.29.0-46.el7.x86_64                           3/5 \n  Cleanup    : curl-7.29.0-35.el7.centos.x86_64                             4/5 \n  Cleanup    : libcurl-7.29.0-35.el7.centos.x86_64                          5/5 \n  Verifying  : curl-7.29.0-46.el7.x86_64                                    1/5 \n  Verifying  : libcurl-devel-7.29.0-46.el7.x86_64                           2/5 \n  Verifying  : libcurl-7.29.0-46.el7.x86_64                                 3/5 \n  Verifying  : curl-7.29.0-35.el7.centos.x86_64                             4/5 \n  Verifying  : libcurl-7.29.0-35.el7.centos.x86_64                          5/5 \n\nInstalled:\n  libcurl-devel.x86_64 0:7.29.0-46.el7                                          \n\nDependency Updated:\n  curl.x86_64 0:7.29.0-46.el7           libcurl.x86_64 0:7.29.0-46.el7          \n\nComplete!\n"]}
    # changed: [atlassian1] => (item=expat-devel) => {"changed": true, "item": "expat-devel", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package expat-devel.x86_64 0:2.1.0-10.el7_3 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package             Arch           Version                  Repository    Size\n================================================================================\nInstalling:\n expat-devel         x86_64         2.1.0-10.el7_3           base          57 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal download size: 57 k\nInstalled size: 178 k\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : expat-devel-2.1.0-10.el7_3.x86_64                            1/1 \n  Verifying  : expat-devel-2.1.0-10.el7_3.x86_64                            1/1 \n\nInstalled:\n  expat-devel.x86_64 0:2.1.0-10.el7_3                                           \n\nComplete!\n"]}
    # changed: [atlassian1] => (item=gettext-devel) => {"changed": true, "item": "gettext-devel", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package gettext-devel.x86_64 0:0.19.8.1-2.el7 will be installed\n--> Processing Dependency: gettext-libs = 0.19.8.1-2.el7 for package: gettext-devel-0.19.8.1-2.el7.x86_64\n--> Processing Dependency: gettext-common-devel = 0.19.8.1-2.el7 for package: gettext-devel-0.19.8.1-2.el7.x86_64\n--> Processing Dependency: gettext = 0.19.8.1-2.el7 for package: gettext-devel-0.19.8.1-2.el7.x86_64\n--> Processing Dependency: git for package: gettext-devel-0.19.8.1-2.el7.x86_64\n--> Running transaction check\n---> Package gettext.x86_64 0:0.18.2.1-4.el7 will be updated\n---> Package gettext.x86_64 0:0.19.8.1-2.el7 will be an update\n---> Package gettext-common-devel.noarch 0:0.19.8.1-2.el7 will be installed\n---> Package gettext-libs.x86_64 0:0.18.2.1-4.el7 will be updated\n---> Package gettext-libs.x86_64 0:0.19.8.1-2.el7 will be an update\n---> Package git.x86_64 0:1.8.3.1-14.el7_5 will be installed\n--> Processing Dependency: perl-Git = 1.8.3.1-14.el7_5 for package: git-1.8.3.1-14.el7_5.x86_64\n--> Processing Dependency: rsync for package: git-1.8.3.1-14.el7_5.x86_64\n--> Processing Dependency: perl(Term::ReadKey) for package: git-1.8.3.1-14.el7_5.x86_64\n--> Processing Dependency: perl(Git) for package: git-1.8.3.1-14.el7_5.x86_64\n--> Processing Dependency: perl(Error) for package: git-1.8.3.1-14.el7_5.x86_64\n--> Processing Dependency: libgnome-keyring.so.0()(64bit) for package: git-1.8.3.1-14.el7_5.x86_64\n--> Running transaction check\n---> Package libgnome-keyring.x86_64 0:3.12.0-1.el7 will be installed\n---> Package perl-Error.noarch 1:0.17020-2.el7 will be installed\n---> Package perl-Git.noarch 0:1.8.3.1-14.el7_5 will be installed\n---> Package perl-TermReadKey.x86_64 0:2.30-20.el7 will be installed\n---> Package rsync.x86_64 0:3.1.2-4.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                   Arch        Version               Repository    Size\n================================================================================\nInstalling:\n gettext-devel             x86_64      0.19.8.1-2.el7        base         320 k\nInstalling for dependencies:\n gettext-common-devel      noarch      0.19.8.1-2.el7        base         410 k\n git                       x86_64      1.8.3.1-14.el7_5      updates      4.4 M\n libgnome-keyring          x86_64      3.12.0-1.el7          base         109 k\n perl-Error                noarch      1:0.17020-2.el7       base          32 k\n perl-Git                  noarch      1.8.3.1-14.el7_5      updates       54 k\n perl-TermReadKey          x86_64      2.30-20.el7           base          31 k\n rsync                     x86_64      3.1.2-4.el7           base         403 k\nUpdating for dependencies:\n gettext                   x86_64      0.19.8.1-2.el7        base         1.0 M\n gettext-libs              x86_64      0.19.8.1-2.el7        base         501 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package  (+7 Dependent packages)\nUpgrade             ( 2 Dependent packages)\n\nTotal download size: 7.2 M\nDownloading packages:\nDelta RPMs disabled because /usr/bin/applydeltarpm not installed.\n--------------------------------------------------------------------------------\nTotal                                              5.2 MB/s | 7.2 MB  00:01     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Updating   : gettext-libs-0.19.8.1-2.el7.x86_64                          1/12 \n  Installing : 1:perl-Error-0.17020-2.el7.noarch                           2/12 \n  Updating   : gettext-0.19.8.1-2.el7.x86_64                               3/12 \n  Installing : libgnome-keyring-3.12.0-1.el7.x86_64                        4/12 \n  Installing : rsync-3.1.2-4.el7.x86_64                                    5/12 \n  Installing : gettext-common-devel-0.19.8.1-2.el7.noarch                  6/12 \n  Installing : perl-TermReadKey-2.30-20.el7.x86_64                         7/12 \n  Installing : perl-Git-1.8.3.1-14.el7_5.noarch                            8/12 \n  Installing : git-1.8.3.1-14.el7_5.x86_64                                 9/12 \n  Installing : gettext-devel-0.19.8.1-2.el7.x86_64                        10/12 \n  Cleanup    : gettext-0.18.2.1-4.el7.x86_64                              11/12 \n  Cleanup    : gettext-libs-0.18.2.1-4.el7.x86_64                         12/12 \n  Verifying  : gettext-devel-0.19.8.1-2.el7.x86_64                         1/12 \n  Verifying  : git-1.8.3.1-14.el7_5.x86_64                                 2/12 \n  Verifying  : perl-TermReadKey-2.30-20.el7.x86_64                         3/12 \n  Verifying  : 1:perl-Error-0.17020-2.el7.noarch                           4/12 \n  Verifying  : gettext-0.19.8.1-2.el7.x86_64                               5/12 \n  Verifying  : gettext-common-devel-0.19.8.1-2.el7.noarch                  6/12 \n  Verifying  : rsync-3.1.2-4.el7.x86_64                                    7/12 \n  Verifying  : libgnome-keyring-3.12.0-1.el7.x86_64                        8/12 \n  Verifying  : gettext-libs-0.19.8.1-2.el7.x86_64                          9/12 \n  Verifying  : perl-Git-1.8.3.1-14.el7_5.noarch                           10/12 \n  Verifying  : gettext-libs-0.18.2.1-4.el7.x86_64                         11/12 \n  Verifying  : gettext-0.18.2.1-4.el7.x86_64                              12/12 \n\nInstalled:\n  gettext-devel.x86_64 0:0.19.8.1-2.el7                                         \n\nDependency Installed:\n  gettext-common-devel.noarch 0:0.19.8.1-2.el7                                  \n  git.x86_64 0:1.8.3.1-14.el7_5                                                 \n  libgnome-keyring.x86_64 0:3.12.0-1.el7                                        \n  perl-Error.noarch 1:0.17020-2.el7                                             \n  perl-Git.noarch 0:1.8.3.1-14.el7_5                                            \n  perl-TermReadKey.x86_64 0:2.30-20.el7                                         \n  rsync.x86_64 0:3.1.2-4.el7                                                    \n\nDependency Updated:\n  gettext.x86_64 0:0.19.8.1-2.el7      gettext-libs.x86_64 0:0.19.8.1-2.el7     \n\nComplete!\n"]}
    # changed: [atlassian1] => (item=openssl-devel) => {"changed": true, "item": "openssl-devel", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package openssl-devel.x86_64 1:1.0.2k-12.el7 will be installed\n--> Processing Dependency: openssl-libs(x86-64) = 1:1.0.2k-12.el7 for package: 1:openssl-devel-1.0.2k-12.el7.x86_64\n--> Processing Dependency: zlib-devel(x86-64) for package: 1:openssl-devel-1.0.2k-12.el7.x86_64\n--> Processing Dependency: krb5-devel(x86-64) for package: 1:openssl-devel-1.0.2k-12.el7.x86_64\n--> Running transaction check\n---> Package krb5-devel.x86_64 0:1.15.1-19.el7 will be installed\n--> Processing Dependency: libkadm5(x86-64) = 1.15.1-19.el7 for package: krb5-devel-1.15.1-19.el7.x86_64\n--> Processing Dependency: krb5-libs(x86-64) = 1.15.1-19.el7 for package: krb5-devel-1.15.1-19.el7.x86_64\n--> Processing Dependency: libverto-devel for package: krb5-devel-1.15.1-19.el7.x86_64\n--> Processing Dependency: libselinux-devel for package: krb5-devel-1.15.1-19.el7.x86_64\n--> Processing Dependency: libcom_err-devel for package: krb5-devel-1.15.1-19.el7.x86_64\n--> Processing Dependency: keyutils-libs-devel for package: krb5-devel-1.15.1-19.el7.x86_64\n---> Package openssl-libs.x86_64 1:1.0.1e-60.el7_3.1 will be updated\n--> Processing Dependency: openssl-libs(x86-64) = 1:1.0.1e-60.el7_3.1 for package: 1:openssl-1.0.1e-60.el7_3.1.x86_64\n---> Package openssl-libs.x86_64 1:1.0.2k-12.el7 will be an update\n---> Package zlib-devel.x86_64 0:1.2.7-17.el7 will be installed\n--> Running transaction check\n---> Package keyutils-libs-devel.x86_64 0:1.5.8-3.el7 will be installed\n---> Package krb5-libs.x86_64 0:1.14.1-27.el7_3 will be updated\n---> Package krb5-libs.x86_64 0:1.15.1-19.el7 will be an update\n---> Package libcom_err-devel.x86_64 0:1.42.9-12.el7_5 will be installed\n--> Processing Dependency: libcom_err(x86-64) = 1.42.9-12.el7_5 for package: libcom_err-devel-1.42.9-12.el7_5.x86_64\n---> Package libkadm5.x86_64 0:1.15.1-19.el7 will be installed\n---> Package libselinux-devel.x86_64 0:2.5-12.el7 will be installed\n--> Processing Dependency: libselinux(x86-64) = 2.5-12.el7 for package: libselinux-devel-2.5-12.el7.x86_64\n--> Processing Dependency: libsepol-devel(x86-64) >= 2.5-6 for package: libselinux-devel-2.5-12.el7.x86_64\n--> Processing Dependency: pkgconfig(libsepol) for package: libselinux-devel-2.5-12.el7.x86_64\n--> Processing Dependency: pkgconfig(libpcre) for package: libselinux-devel-2.5-12.el7.x86_64\n---> Package libverto-devel.x86_64 0:0.2.5-4.el7 will be installed\n---> Package openssl.x86_64 1:1.0.1e-60.el7_3.1 will be updated\n---> Package openssl.x86_64 1:1.0.2k-12.el7 will be an update\n--> Running transaction check\n---> Package libcom_err.x86_64 0:1.42.9-9.el7 will be updated\n--> Processing Dependency: libcom_err(x86-64) = 1.42.9-9.el7 for package: libss-1.42.9-9.el7.x86_64\n--> Processing Dependency: libcom_err(x86-64) = 1.42.9-9.el7 for package: e2fsprogs-libs-1.42.9-9.el7.x86_64\n--> Processing Dependency: libcom_err(x86-64) = 1.42.9-9.el7 for package: e2fsprogs-1.42.9-9.el7.x86_64\n---> Package libcom_err.x86_64 0:1.42.9-12.el7_5 will be an update\n---> Package libselinux.x86_64 0:2.5-6.el7 will be updated\n--> Processing Dependency: libselinux(x86-64) = 2.5-6.el7 for package: libselinux-python-2.5-6.el7.x86_64\n--> Processing Dependency: libselinux(x86-64) = 2.5-6.el7 for package: libselinux-utils-2.5-6.el7.x86_64\n---> Package libselinux.x86_64 0:2.5-12.el7 will be an update\n---> Package libsepol-devel.x86_64 0:2.5-8.1.el7 will be installed\n--> Processing Dependency: libsepol(x86-64) = 2.5-8.1.el7 for package: libsepol-devel-2.5-8.1.el7.x86_64\n---> Package pcre-devel.x86_64 0:8.32-17.el7 will be installed\n--> Processing Dependency: pcre(x86-64) = 8.32-17.el7 for package: pcre-devel-8.32-17.el7.x86_64\n--> Running transaction check\n---> Package e2fsprogs.x86_64 0:1.42.9-9.el7 will be updated\n---> Package e2fsprogs.x86_64 0:1.42.9-12.el7_5 will be an update\n---> Package e2fsprogs-libs.x86_64 0:1.42.9-9.el7 will be updated\n---> Package e2fsprogs-libs.x86_64 0:1.42.9-12.el7_5 will be an update\n---> Package libselinux-python.x86_64 0:2.5-6.el7 will be updated\n---> Package libselinux-python.x86_64 0:2.5-12.el7 will be an update\n---> Package libselinux-utils.x86_64 0:2.5-6.el7 will be updated\n---> Package libselinux-utils.x86_64 0:2.5-12.el7 will be an update\n---> Package libsepol.x86_64 0:2.5-6.el7 will be updated\n---> Package libsepol.x86_64 0:2.5-8.1.el7 will be an update\n---> Package libss.x86_64 0:1.42.9-9.el7 will be updated\n---> Package libss.x86_64 0:1.42.9-12.el7_5 will be an update\n---> Package pcre.x86_64 0:8.32-15.el7_2.1 will be updated\n---> Package pcre.x86_64 0:8.32-17.el7 will be an update\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                  Arch        Version                Repository    Size\n================================================================================\nInstalling:\n openssl-devel            x86_64      1:1.0.2k-12.el7        base         1.5 M\nInstalling for dependencies:\n keyutils-libs-devel      x86_64      1.5.8-3.el7            base          37 k\n krb5-devel               x86_64      1.15.1-19.el7          updates      269 k\n libcom_err-devel         x86_64      1.42.9-12.el7_5        updates       31 k\n libkadm5                 x86_64      1.15.1-19.el7          updates      175 k\n libselinux-devel         x86_64      2.5-12.el7             base         186 k\n libsepol-devel           x86_64      2.5-8.1.el7            base          77 k\n libverto-devel           x86_64      0.2.5-4.el7            base          12 k\n pcre-devel               x86_64      8.32-17.el7            base         480 k\n zlib-devel               x86_64      1.2.7-17.el7           base          50 k\nUpdating for dependencies:\n e2fsprogs                x86_64      1.42.9-12.el7_5        updates      699 k\n e2fsprogs-libs           x86_64      1.42.9-12.el7_5        updates      167 k\n krb5-libs                x86_64      1.15.1-19.el7          updates      747 k\n libcom_err               x86_64      1.42.9-12.el7_5        updates       41 k\n libselinux               x86_64      2.5-12.el7             base         162 k\n libselinux-python        x86_64      2.5-12.el7             base         235 k\n libselinux-utils         x86_64      2.5-12.el7             base         151 k\n libsepol                 x86_64      2.5-8.1.el7            base         297 k\n libss                    x86_64      1.42.9-12.el7_5        updates       45 k\n openssl                  x86_64      1:1.0.2k-12.el7        base         492 k\n openssl-libs             x86_64      1:1.0.2k-12.el7        base         1.2 M\n pcre                     x86_64      8.32-17.el7            base         422 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package  (+ 9 Dependent packages)\nUpgrade             ( 12 Dependent packages)\n\nTotal download size: 7.4 M\nDownloading packages:\nDelta RPMs disabled because /usr/bin/applydeltarpm not installed.\n--------------------------------------------------------------------------------\nTotal                                              4.1 MB/s | 7.4 MB  00:01     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Updating   : libcom_err-1.42.9-12.el7_5.x86_64                           1/34 \n  Updating   : libsepol-2.5-8.1.el7.x86_64                                 2/34 \n  Updating   : pcre-8.32-17.el7.x86_64                                     3/34 \n  Updating   : libselinux-2.5-12.el7.x86_64                                4/34 \n  Updating   : 1:openssl-libs-1.0.2k-12.el7.x86_64                         5/34 \n  Updating   : krb5-libs-1.15.1-19.el7.x86_64                              6/34 \n  Installing : libkadm5-1.15.1-19.el7.x86_64                               7/34 \n  Installing : pcre-devel-8.32-17.el7.x86_64                               8/34 \n  Installing : libsepol-devel-2.5-8.1.el7.x86_64                           9/34 \n  Installing : libselinux-devel-2.5-12.el7.x86_64                         10/34 \n  Updating   : libss-1.42.9-12.el7_5.x86_64                               11/34 \n  Installing : libcom_err-devel-1.42.9-12.el7_5.x86_64                    12/34 \n  Updating   : e2fsprogs-libs-1.42.9-12.el7_5.x86_64                      13/34 \n  Installing : libverto-devel-0.2.5-4.el7.x86_64                          14/34 \n  Installing : keyutils-libs-devel-1.5.8-3.el7.x86_64                     15/34 \n  Installing : krb5-devel-1.15.1-19.el7.x86_64                            16/34 \n  Installing : zlib-devel-1.2.7-17.el7.x86_64                             17/34 \n  Installing : 1:openssl-devel-1.0.2k-12.el7.x86_64                       18/34 \n  Updating   : e2fsprogs-1.42.9-12.el7_5.x86_64                           19/34 \n  Updating   : 1:openssl-1.0.2k-12.el7.x86_64                             20/34 \n  Updating   : libselinux-python-2.5-12.el7.x86_64                        21/34 \n  Updating   : libselinux-utils-2.5-12.el7.x86_64                         22/34 \n  Cleanup    : 1:openssl-1.0.1e-60.el7_3.1.x86_64                         23/34 \n  Cleanup    : e2fsprogs-1.42.9-9.el7.x86_64                              24/34 \n  Cleanup    : 1:openssl-libs-1.0.1e-60.el7_3.1.x86_64                    25/34 \n  Cleanup    : krb5-libs-1.14.1-27.el7_3.x86_64                           26/34 \n  Cleanup    : libselinux-utils-2.5-6.el7.x86_64                          27/34 \n  Cleanup    : e2fsprogs-libs-1.42.9-9.el7.x86_64                         28/34 \n  Cleanup    : libss-1.42.9-9.el7.x86_64                                  29/34 \n  Cleanup    : libselinux-python-2.5-6.el7.x86_64                         30/34 \n  Cleanup    : libselinux-2.5-6.el7.x86_64                                31/34 \n  Cleanup    : pcre-8.32-15.el7_2.1.x86_64                                32/34 \n  Cleanup    : libsepol-2.5-6.el7.x86_64                                  33/34 \n  Cleanup    : libcom_err-1.42.9-9.el7.x86_64                             34/34 \n  Verifying  : krb5-devel-1.15.1-19.el7.x86_64                             1/34 \n  Verifying  : zlib-devel-1.2.7-17.el7.x86_64                              2/34 \n  Verifying  : keyutils-libs-devel-1.5.8-3.el7.x86_64                      3/34 \n  Verifying  : krb5-libs-1.15.1-19.el7.x86_64                              4/34 \n  Verifying  : pcre-devel-8.32-17.el7.x86_64                               5/34 \n  Verifying  : pcre-8.32-17.el7.x86_64                                     6/34 \n  Verifying  : libsepol-2.5-8.1.el7.x86_64                                 7/34 \n  Verifying  : 1:openssl-libs-1.0.2k-12.el7.x86_64                         8/34 \n  Verifying  : libselinux-python-2.5-12.el7.x86_64                         9/34 \n  Verifying  : 1:openssl-devel-1.0.2k-12.el7.x86_64                       10/34 \n  Verifying  : libverto-devel-0.2.5-4.el7.x86_64                          11/34 \n  Verifying  : libselinux-devel-2.5-12.el7.x86_64                         12/34 \n  Verifying  : libss-1.42.9-12.el7_5.x86_64                               13/34 \n  Verifying  : libcom_err-devel-1.42.9-12.el7_5.x86_64                    14/34 \n  Verifying  : e2fsprogs-1.42.9-12.el7_5.x86_64                           15/34 \n  Verifying  : e2fsprogs-libs-1.42.9-12.el7_5.x86_64                      16/34 \n  Verifying  : libsepol-devel-2.5-8.1.el7.x86_64                          17/34 \n  Verifying  : libcom_err-1.42.9-12.el7_5.x86_64                          18/34 \n  Verifying  : libselinux-2.5-12.el7.x86_64                               19/34 \n  Verifying  : libselinux-utils-2.5-12.el7.x86_64                         20/34 \n  Verifying  : libkadm5-1.15.1-19.el7.x86_64                              21/34 \n  Verifying  : 1:openssl-1.0.2k-12.el7.x86_64                             22/34 \n  Verifying  : 1:openssl-1.0.1e-60.el7_3.1.x86_64                         23/34 \n  Verifying  : libss-1.42.9-9.el7.x86_64                                  24/34 \n  Verifying  : libsepol-2.5-6.el7.x86_64                                  25/34 \n  Verifying  : libselinux-python-2.5-6.el7.x86_64                         26/34 \n  Verifying  : 1:openssl-libs-1.0.1e-60.el7_3.1.x86_64                    27/34 \n  Verifying  : krb5-libs-1.14.1-27.el7_3.x86_64                           28/34 \n  Verifying  : libselinux-utils-2.5-6.el7.x86_64                          29/34 \n  Verifying  : pcre-8.32-15.el7_2.1.x86_64                                30/34 \n  Verifying  : libselinux-2.5-6.el7.x86_64                                31/34 \n  Verifying  : libcom_err-1.42.9-9.el7.x86_64                             32/34 \n  Verifying  : e2fsprogs-libs-1.42.9-9.el7.x86_64                         33/34 \n  Verifying  : e2fsprogs-1.42.9-9.el7.x86_64                              34/34 \n\nInstalled:\n  openssl-devel.x86_64 1:1.0.2k-12.el7                                          \n\nDependency Installed:\n  keyutils-libs-devel.x86_64 0:1.5.8-3.el7  krb5-devel.x86_64 0:1.15.1-19.el7  \n  libcom_err-devel.x86_64 0:1.42.9-12.el7_5 libkadm5.x86_64 0:1.15.1-19.el7    \n  libselinux-devel.x86_64 0:2.5-12.el7      libsepol-devel.x86_64 0:2.5-8.1.el7\n  libverto-devel.x86_64 0:0.2.5-4.el7       pcre-devel.x86_64 0:8.32-17.el7    \n  zlib-devel.x86_64 0:1.2.7-17.el7         \n\nDependency Updated:\n  e2fsprogs.x86_64 0:1.42.9-12.el7_5    e2fsprogs-libs.x86_64 0:1.42.9-12.el7_5 \n  krb5-libs.x86_64 0:1.15.1-19.el7      libcom_err.x86_64 0:1.42.9-12.el7_5     \n  libselinux.x86_64 0:2.5-12.el7        libselinux-python.x86_64 0:2.5-12.el7   \n  libselinux-utils.x86_64 0:2.5-12.el7  libsepol.x86_64 0:2.5-8.1.el7           \n  libss.x86_64 0:1.42.9-12.el7_5        openssl.x86_64 1:1.0.2k-12.el7          \n  openssl-libs.x86_64 1:1.0.2k-12.el7   pcre.x86_64 0:8.32-17.el7               \n\nComplete!\n"]}
    # ok: [atlassian1] => (item=perl-devel) => {"changed": false, "item": "perl-devel", "msg": "", "rc": 0, "results": ["4:perl-devel-5.16.3-292.el7.x86_64 providing perl-devel is already installed"]}
    # ok: [atlassian1] => (item=zlib-devel) => {"changed": false, "item": "zlib-devel", "msg": "", "rc": 0, "results": ["zlib-devel-1.2.7-17.el7.x86_64 providing zlib-devel is already installed"]}
    # changed: [atlassian1] => (item=gcc) => {"changed": true, "item": "gcc", "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.23media.de\n * epel: mirror.23media.de\n * extras: mirror.eu.oneandone.net\n * updates: mirror.23media.de\nResolving Dependencies\n--> Running transaction check\n---> Package gcc.x86_64 0:4.8.5-28.el7_5.1 will be installed\n--> Processing Dependency: libgomp = 4.8.5-28.el7_5.1 for package: gcc-4.8.5-28.el7_5.1.x86_64\n--> Processing Dependency: cpp = 4.8.5-28.el7_5.1 for package: gcc-4.8.5-28.el7_5.1.x86_64\n--> Processing Dependency: libgcc >= 4.8.5-28.el7_5.1 for package: gcc-4.8.5-28.el7_5.1.x86_64\n--> Running transaction check\n---> Package cpp.x86_64 0:4.8.5-28.el7_5.1 will be installed\n---> Package libgcc.x86_64 0:4.8.5-11.el7 will be updated\n---> Package libgcc.x86_64 0:4.8.5-28.el7_5.1 will be an update\n---> Package libgomp.x86_64 0:4.8.5-11.el7 will be updated\n---> Package libgomp.x86_64 0:4.8.5-28.el7_5.1 will be an update\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package         Arch           Version                   Repository       Size\n================================================================================\nInstalling:\n gcc             x86_64         4.8.5-28.el7_5.1          updates          16 M\nInstalling for dependencies:\n cpp             x86_64         4.8.5-28.el7_5.1          updates         5.9 M\nUpdating for dependencies:\n libgcc          x86_64         4.8.5-28.el7_5.1          updates         101 k\n libgomp         x86_64         4.8.5-28.el7_5.1          updates         156 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package  (+1 Dependent package)\nUpgrade             ( 2 Dependent packages)\n\nTotal download size: 22 M\nDownloading packages:\nDelta RPMs disabled because /usr/bin/applydeltarpm not installed.\n--------------------------------------------------------------------------------\nTotal                                              5.2 MB/s |  22 MB  00:04     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : cpp-4.8.5-28.el7_5.1.x86_64                                  1/6 \n  Updating   : libgcc-4.8.5-28.el7_5.1.x86_64                               2/6 \n  Updating   : libgomp-4.8.5-28.el7_5.1.x86_64                              3/6 \n  Installing : gcc-4.8.5-28.el7_5.1.x86_64                                  4/6 \n  Cleanup    : libgcc-4.8.5-11.el7.x86_64                                   5/6 \n  Cleanup    : libgomp-4.8.5-11.el7.x86_64                                  6/6 \n  Verifying  : libgomp-4.8.5-28.el7_5.1.x86_64                              1/6 \n  Verifying  : libgcc-4.8.5-28.el7_5.1.x86_64                               2/6 \n  Verifying  : gcc-4.8.5-28.el7_5.1.x86_64                                  3/6 \n  Verifying  : cpp-4.8.5-28.el7_5.1.x86_64                                  4/6 \n  Verifying  : libgcc-4.8.5-11.el7.x86_64                                   5/6 \n  Verifying  : libgomp-4.8.5-11.el7.x86_64                                  6/6 \n\nInstalled:\n  gcc.x86_64 0:4.8.5-28.el7_5.1                                                 \n\nDependency Installed:\n  cpp.x86_64 0:4.8.5-28.el7_5.1                                                 \n\nDependency Updated:\n  libgcc.x86_64 0:4.8.5-28.el7_5.1       libgomp.x86_64 0:4.8.5-28.el7_5.1      \n\nComplete!\n"]}
    # ok: [atlassian1] => (item=make) => {"changed": false, "item": "make", "msg": "", "rc": 0, "results": ["1:make-3.82-23.el7.x86_64 providing make is already installed"]}
    # 
    # TASK [geerlingguy.git : Ensure git's dependencies are installed (Debian).] *********
    # [DEPRECATION WARNING]: Invoking "apt" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'libcurl4-gnutls-dev', 
    # u'libexpat1-dev', u'gettext', u'libssl-dev', u'build-essential', u'gcc']` and 
    # remove the loop. This feature will be removed in version 2.11. Deprecation warnings
    #  can be disabled by setting deprecation_warnings=False in ansible.cfg.
    # skipping: [atlassian1] => (item=[])  => {"changed": false, "item": [], "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.git : Get installed version] *************************************
    # ok: [atlassian1] => {"changed": false, "cmd": ["git", "--version"], "delta": "0:00:00.002832", "end": "2018-11-16 12:10:48.095893", "failed_when_result": false, "rc": 0, "start": "2018-11-16 12:10:48.093061", "stderr": "", "stderr_lines": [], "stdout": "git version 1.8.3.1", "stdout_lines": ["git version 1.8.3.1"]}
    # 
    # TASK [geerlingguy.git : Force git install if the version numbers do not match] *****
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|success` use `result is success`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|version_compare` use `result is version_compare`. This feature will be 
    # removed in version 2.9. Deprecation warnings can be disabled by setting 
    # deprecation_warnings=False in ansible.cfg.
    # ok: [atlassian1] => {"ansible_facts": {"git_reinstall_from_source": true}, "changed": false}
    # 
    # TASK [geerlingguy.git : Download git.] *********************************************
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|failed` use `result is failed`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "ae90c4e5008ae10c8a67a51ff3dbea8364d97168", "dest": "/root/git-2.9.3.tar.gz", "gid": 0, "group": "root", "md5sum": "c783361be894b8bfa5373811b1b65602", "mode": "0644", "msg": "OK (5918768 bytes)", "owner": "root", "secontext": "system_u:object_r:admin_home_t:s0", "size": 5918768, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542370248.49-189951611760702/tmpLC2Pyv", "state": "file", "status_code": 200, "uid": 0, "url": "https://www.kernel.org/pub/software/scm/git/git-2.9.3.tar.gz"}
    # 
    # TASK [geerlingguy.git : Expand git archive.] ***************************************
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|failed` use `result is failed`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # changed: [atlassian1] => {"changed": true, "dest": "/root", "extract_results": {"cmd": ["/bin/gtar", "--extract", "-C", "/root", "-z", "-f", "/root/git-2.9.3.tar.gz"], "err": "", "out": "", "rc": 0}, "gid": 0, "group": "root", "handler": "TgzArchive", "mode": "0550", "owner": "root", "secontext": "system_u:object_r:admin_home_t:s0", "size": 204, "src": "/root/git-2.9.3.tar.gz", "state": "directory", "uid": 0}
    # 
    # TASK [geerlingguy.git : Build git.] ************************************************
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|failed` use `result is failed`. This feature will be removed in version 
    # 2.9. Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # changed: [atlassian1] => (item=all) => {"changed": true, "cmd": ["make", "prefix=/usr", "all"], "delta": "0:02:09.197687", "end": "2018-11-16 12:13:05.090798", "item": "all", "rc": 0, "start": "2018-11-16 12:10:55.893111", "stderr": "GIT_VERSION = 2.9.3\n    * new build flags\n    * new link flags\n    * new prefix flags\n    * new script parameters\nWriting perl.mak for Git\n    * new perl-specific parameters\n    * new Python interpreter location\nGITGUI_VERSION = 0.20.GITGUI\n    * new locations or Tcl/Tk interpreter\n    * tclsh failed; using unoptimized loading\n    * new Tcl/Tk interpreter location\n307 translated messages.\n307 translated messages.\n307 translated messages.\n277 translated messages, 18 fuzzy translations, 12 untranslated messages.\n184 translated messages, 46 fuzzy translations, 77 untranslated messages.\n311 translated messages.\n311 translated messages.\n274 translated messages, 17 fuzzy translations, 16 untranslated messages.\n311 translated messages.\n279 translated messages, 16 fuzzy translations, 12 untranslated messages.\n311 translated messages.\n307 translated messages.\n2592 translated messages, 3 fuzzy translations, 2 untranslated messages.\n2597 translated messages.\n2597 translated messages.\n14 translated messages.\n2530 translated messages.\n2597 translated messages.\n2597 translated messages.\n2597 translated messages.\n716 translated messages, 350 untranslated messages.\n2597 translated messages.\n2597 translated messages.\n2597 translated messages.", "stderr_lines": ["GIT_VERSION = 2.9.3", "    * new build flags", "    * new link flags", "    * new prefix flags", "    * new script parameters", "Writing perl.mak for Git", "    * new perl-specific parameters", "    * new Python interpreter location", "GITGUI_VERSION = 0.20.GITGUI", "    * new locations or Tcl/Tk interpreter", "    * tclsh failed; using unoptimized loading", "    * new Tcl/Tk interpreter location", "307 translated messages.", "307 translated messages.", "307 translated messages.", "277 translated messages, 18 fuzzy translations, 12 untranslated messages.", "184 translated messages, 46 fuzzy translations, 77 untranslated messages.", "311 translated messages.", "311 translated messages.", "274 translated messages, 17 fuzzy translations, 16 untranslated messages.", "311 translated messages.", "279 translated messages, 16 fuzzy translations, 12 untranslated messages.", "311 translated messages.", "307 translated messages.", "2592 translated messages, 3 fuzzy translations, 2 untranslated messages.", "2597 translated messages.", "2597 translated messages.", "14 translated messages.", "2530 translated messages.", "2597 translated messages.", "2597 translated messages.", "2597 translated messages.", "716 translated messages, 350 untranslated messages.", "2597 translated messages.", "2597 translated messages.", "2597 translated messages."], "stdout": "    CC credential-store.o\n    CC abspath.o\n    CC advice.o\n    CC alias.o\n    CC alloc.o\n    CC archive.o\n    CC archive-tar.o\n    CC archive-zip.o\n    CC argv-array.o\n    CC attr.o\n    CC base85.o\n    CC bisect.o\n    CC blob.o\n    CC branch.o\n    CC bulk-checkin.o\n    CC bundle.o\n    CC cache-tree.o\n    CC color.o\n    CC column.o\n    CC combine-diff.o\n    CC commit.o\n    CC compat/obstack.o\n    CC compat/terminal.o\n    CC config.o\n    CC connect.o\n    CC connected.o\n    CC convert.o\n    CC copy.o\n    CC credential.o\n    CC csum-file.o\n    CC ctype.o\n    CC date.o\n    CC decorate.o\n    CC diffcore-break.o\n    CC diffcore-delta.o\n    CC diffcore-order.o\n    CC diffcore-pickaxe.o\n    CC diffcore-rename.o\n    CC diff-delta.o\n    CC diff-lib.o\n    CC diff-no-index.o\n    CC diff.o\n    CC dir.o\n    CC editor.o\n    CC entry.o\n    CC environment.o\n    CC ewah/bitmap.o\n    CC ewah/ewah_bitmap.o\n    CC ewah/ewah_io.o\n    CC ewah/ewah_rlw.o\n    CC exec_cmd.o\n    CC fetch-pack.o\n    CC fsck.o\n    CC gettext.o\n    CC gpg-interface.o\n    CC graph.o\n    CC grep.o\n    CC hashmap.o\n    GEN common-cmds.h\n    CC help.o\n    CC hex.o\n    CC ident.o\n    CC kwset.o\n    CC levenshtein.o\n    CC line-log.o\n    CC line-range.o\n    CC list-objects.o\n    CC ll-merge.o\n    CC lockfile.o\n    CC log-tree.o\n    CC mailinfo.o\n    CC mailmap.o\n    CC match-trees.o\n    CC merge.o\n    CC merge-blobs.o\n    CC merge-recursive.o\n    CC mergesort.o\n    CC name-hash.o\n    CC notes.o\n    CC notes-cache.o\n    CC notes-merge.o\n    CC notes-utils.o\n    CC object.o\n    CC pack-bitmap.o\n    CC pack-bitmap-write.o\n    CC pack-check.o\n    CC pack-objects.o\n    CC pack-revindex.o\n    CC pack-write.o\n    CC pager.o\n    CC parse-options.o\n    CC parse-options-cb.o\n    CC patch-delta.o\n    CC patch-ids.o\n    CC path.o\n    CC pathspec.o\n    CC pkt-line.o\n    CC preload-index.o\n    CC pretty.o\n    CC prio-queue.o\n    CC progress.o\n    CC prompt.o\n    CC quote.o\n    CC reachable.o\n    CC read-cache.o\n    CC reflog-walk.o\n    CC refs.o\n    CC refs/files-backend.o\n    CC ref-filter.o\n    CC remote.o\n    CC replace_object.o\n    CC rerere.o\n    CC resolve-undo.o\n    CC revision.o\n    CC run-command.o\n    CC send-pack.o\n    CC sequencer.o\n    CC server-info.o\n    CC setup.o\n    CC sha1-array.o\n    CC sha1-lookup.o\n    CC sha1_file.o\n    CC sha1_name.o\n    CC shallow.o\n    CC sideband.o\n    CC sigchain.o\n    CC split-index.o\n    CC strbuf.o\n    CC streaming.o\n    CC string-list.o\n    CC submodule.o\n    CC submodule-config.o\n    CC symlinks.o\n    CC tag.o\n    CC tempfile.o\n    CC trace.o\n    CC trailer.o\n    CC transport.o\n    CC transport-helper.o\n    CC tree-diff.o\n    CC tree.o\n    CC tree-walk.o\n    CC unpack-trees.o\n    CC url.o\n    CC urlmatch.o\n    CC usage.o\n    CC userdiff.o\n    CC utf8.o\n    CC varint.o\n    CC version.o\n    CC versioncmp.o\n    CC walker.o\n    CC wildmatch.o\n    CC worktree.o\n    CC wrapper.o\n    CC write_or_die.o\n    CC ws.o\n    CC wt-status.o\n    CC xdiff-interface.o\n    CC zlib.o\n    CC unix-socket.o\n    CC thread-utils.o\n    CC compat/strlcpy.o\n    AR libgit.a\n    CC xdiff/xdiffi.o\n    CC xdiff/xprepare.o\n    CC xdiff/xutils.o\n    CC xdiff/xemit.o\n    CC xdiff/xmerge.o\n    CC xdiff/xpatience.o\n    CC xdiff/xhistogram.o\n    AR xdiff/lib.a\n    LINK git-credential-store\n    CC daemon.o\n    LINK git-daemon\n    CC fast-import.o\n    LINK git-fast-import\n    CC http-backend.o\n    LINK git-http-backend\n    CC imap-send.o\n    LINK git-imap-send\n    CC sh-i18n--envsubst.o\n    LINK git-sh-i18n--envsubst\n    CC shell.o\n    LINK git-shell\n    CC show-index.o\n    LINK git-show-index\n    CC upload-pack.o\n    LINK git-upload-pack\n    CC remote-testsvn.o\n    CC vcs-svn/line_buffer.o\n    CC vcs-svn/sliding_window.o\n    CC vcs-svn/repo_tree.o\n    CC vcs-svn/fast_export.o\n    CC vcs-svn/svndiff.o\n    CC vcs-svn/svndump.o\n    AR vcs-svn/lib.a\n    LINK git-remote-testsvn\n    CC http.o\n    CC http-walker.o\n    CC http-fetch.o\n    LINK git-http-fetch\n    CC http-push.o\n    LINK git-http-push\n    CC credential-cache.o\n    LINK git-credential-cache\n    CC credential-cache--daemon.o\n    LINK git-credential-cache--daemon\n    CC remote-curl.o\n    LINK git-remote-http\n    LN/CP git-remote-https\n    LN/CP git-remote-ftp\n    LN/CP git-remote-ftps\n    GEN git-bisect\n    GEN git-difftool--helper\n    GEN git-filter-branch\n    GEN git-merge-octopus\n    GEN git-merge-one-file\n    GEN git-merge-resolve\n    GEN git-mergetool\n    GEN git-quiltimport\n    GEN git-rebase\n    GEN git-request-pull\n    GEN git-stash\n    GEN git-submodule\n    GEN git-web--browse\n    SUBDIR perl\n/usr/bin/perl Makefile.PL PREFIX='/usr' INSTALL_BASE='' --localedir='/usr/share/locale'\n    GEN git-add--interactive\n    GEN git-difftool\n    GEN git-archimport\n    GEN git-cvsexportcommit\n    GEN git-cvsimport\n    GEN git-cvsserver\n    GEN git-relink\n    GEN git-send-email\n    GEN git-svn\n    GEN git-p4\n    GEN git-instaweb\n    GEN git-mergetool--lib\n    GEN git-parse-remote\n    GEN git-rebase--am\n    GEN git-rebase--interactive\n    GEN git-rebase--merge\n    GEN git-sh-setup\n    GEN git-sh-i18n\n    CC git.o\n    CC builtin/add.o\n    CC builtin/am.o\n    CC builtin/annotate.o\n    CC builtin/apply.o\n    CC builtin/archive.o\n    CC builtin/bisect--helper.o\n    CC builtin/blame.o\n    CC builtin/branch.o\n    CC builtin/bundle.o\n    CC builtin/cat-file.o\n    CC builtin/check-attr.o\n    CC builtin/check-ignore.o\n    CC builtin/check-mailmap.o\n    CC builtin/check-ref-format.o\n    CC builtin/checkout-index.o\n    CC builtin/checkout.o\n    CC builtin/clean.o\n    CC builtin/clone.o\n    CC builtin/column.o\n    CC builtin/commit-tree.o\n    CC builtin/commit.o\n    CC builtin/config.o\n    CC builtin/count-objects.o\n    CC builtin/credential.o\n    CC builtin/describe.o\n    CC builtin/diff-files.o\n    CC builtin/diff-index.o\n    CC builtin/diff-tree.o\n    CC builtin/diff.o\n    CC builtin/fast-export.o\n    CC builtin/fetch-pack.o\n    CC builtin/fetch.o\n    CC builtin/fmt-merge-msg.o\n    CC builtin/for-each-ref.o\n    CC builtin/fsck.o\n    CC builtin/gc.o\n    CC builtin/get-tar-commit-id.o\n    CC builtin/grep.o\n    CC builtin/hash-object.o\n    CC builtin/help.o\n    CC builtin/index-pack.o\n    CC builtin/init-db.o\n    CC builtin/interpret-trailers.o\n    CC builtin/log.o\n    CC builtin/ls-files.o\n    CC builtin/ls-remote.o\n    CC builtin/ls-tree.o\n    CC builtin/mailinfo.o\n    CC builtin/mailsplit.o\n    CC builtin/merge.o\n    CC builtin/merge-base.o\n    CC builtin/merge-file.o\n    CC builtin/merge-index.o\n    CC builtin/merge-ours.o\n    CC builtin/merge-recursive.o\n    CC builtin/merge-tree.o\n    CC builtin/mktag.o\n    CC builtin/mktree.o\n    CC builtin/mv.o\n    CC builtin/name-rev.o\n    CC builtin/notes.o\n    CC builtin/pack-objects.o\n    CC builtin/pack-redundant.o\n    CC builtin/pack-refs.o\n    CC builtin/patch-id.o\n    CC builtin/prune-packed.o\n    CC builtin/prune.o\n    CC builtin/pull.o\n    CC builtin/push.o\n    CC builtin/read-tree.o\n    CC builtin/receive-pack.o\n    CC builtin/reflog.o\n    CC builtin/remote.o\n    CC builtin/remote-ext.o\n    CC builtin/remote-fd.o\n    CC builtin/repack.o\n    CC builtin/replace.o\n    CC builtin/rerere.o\n    CC builtin/reset.o\n    CC builtin/rev-list.o\n    CC builtin/rev-parse.o\n    CC builtin/revert.o\n    CC builtin/rm.o\n    CC builtin/send-pack.o\n    CC builtin/shortlog.o\n    CC builtin/show-branch.o\n    CC builtin/show-ref.o\n    CC builtin/stripspace.o\n    CC builtin/submodule--helper.o\n    CC builtin/symbolic-ref.o\n    CC builtin/tag.o\n    CC builtin/unpack-file.o\n    CC builtin/unpack-objects.o\n    CC builtin/update-index.o\n    CC builtin/update-ref.o\n    CC builtin/update-server-info.o\n    CC builtin/upload-archive.o\n    CC builtin/var.o\n    CC builtin/verify-commit.o\n    CC builtin/verify-pack.o\n    CC builtin/verify-tag.o\n    CC builtin/worktree.o\n    CC builtin/write-tree.o\n    LINK git\n    BUILTIN git-add\n    BUILTIN git-am\n    BUILTIN git-annotate\n    BUILTIN git-apply\n    BUILTIN git-archive\n    BUILTIN git-bisect--helper\n    BUILTIN git-blame\n    BUILTIN git-branch\n    BUILTIN git-bundle\n    BUILTIN git-cat-file\n    BUILTIN git-check-attr\n    BUILTIN git-check-ignore\n    BUILTIN git-check-mailmap\n    BUILTIN git-check-ref-format\n    BUILTIN git-checkout-index\n    BUILTIN git-checkout\n    BUILTIN git-clean\n    BUILTIN git-clone\n    BUILTIN git-column\n    BUILTIN git-commit-tree\n    BUILTIN git-commit\n    BUILTIN git-config\n    BUILTIN git-count-objects\n    BUILTIN git-credential\n    BUILTIN git-describe\n    BUILTIN git-diff-files\n    BUILTIN git-diff-index\n    BUILTIN git-diff-tree\n    BUILTIN git-diff\n    BUILTIN git-fast-export\n    BUILTIN git-fetch-pack\n    BUILTIN git-fetch\n    BUILTIN git-fmt-merge-msg\n    BUILTIN git-for-each-ref\n    BUILTIN git-fsck\n    BUILTIN git-gc\n    BUILTIN git-get-tar-commit-id\n    BUILTIN git-grep\n    BUILTIN git-hash-object\n    BUILTIN git-help\n    BUILTIN git-index-pack\n    BUILTIN git-init-db\n    BUILTIN git-interpret-trailers\n    BUILTIN git-log\n    BUILTIN git-ls-files\n    BUILTIN git-ls-remote\n    BUILTIN git-ls-tree\n    BUILTIN git-mailinfo\n    BUILTIN git-mailsplit\n    BUILTIN git-merge\n    BUILTIN git-merge-base\n    BUILTIN git-merge-file\n    BUILTIN git-merge-index\n    BUILTIN git-merge-ours\n    BUILTIN git-merge-recursive\n    BUILTIN git-merge-tree\n    BUILTIN git-mktag\n    BUILTIN git-mktree\n    BUILTIN git-mv\n    BUILTIN git-name-rev\n    BUILTIN git-notes\n    BUILTIN git-pack-objects\n    BUILTIN git-pack-redundant\n    BUILTIN git-pack-refs\n    BUILTIN git-patch-id\n    BUILTIN git-prune-packed\n    BUILTIN git-prune\n    BUILTIN git-pull\n    BUILTIN git-push\n    BUILTIN git-read-tree\n    BUILTIN git-receive-pack\n    BUILTIN git-reflog\n    BUILTIN git-remote\n    BUILTIN git-remote-ext\n    BUILTIN git-remote-fd\n    BUILTIN git-repack\n    BUILTIN git-replace\n    BUILTIN git-rerere\n    BUILTIN git-reset\n    BUILTIN git-rev-list\n    BUILTIN git-rev-parse\n    BUILTIN git-revert\n    BUILTIN git-rm\n    BUILTIN git-send-pack\n    BUILTIN git-shortlog\n    BUILTIN git-show-branch\n    BUILTIN git-show-ref\n    BUILTIN git-stripspace\n    BUILTIN git-submodule--helper\n    BUILTIN git-symbolic-ref\n    BUILTIN git-tag\n    BUILTIN git-unpack-file\n    BUILTIN git-unpack-objects\n    BUILTIN git-update-index\n    BUILTIN git-update-ref\n    BUILTIN git-update-server-info\n    BUILTIN git-upload-archive\n    BUILTIN git-var\n    BUILTIN git-verify-commit\n    BUILTIN git-verify-pack\n    BUILTIN git-verify-tag\n    BUILTIN git-worktree\n    BUILTIN git-write-tree\n    BUILTIN git-cherry\n    BUILTIN git-cherry-pick\n    BUILTIN git-format-patch\n    BUILTIN git-fsck-objects\n    BUILTIN git-init\n    BUILTIN git-merge-subtree\n    BUILTIN git-show\n    BUILTIN git-stage\n    BUILTIN git-status\n    BUILTIN git-whatchanged\n    SUBDIR git-gui\n    GEN git-gui\n    INDEX lib/\n    MSGFMT    po/de.msg 520 translated.\n    MSGFMT    po/vi.msg 543 translated.\n    MSGFMT    po/hu.msg 514 translated.\n    MSGFMT    po/nb.msg 474 translated, 39 untranslated.\n    MSGFMT    po/sv.msg 547 translated.\n    MSGFMT    po/fr.msg 520 translated.\n    MSGFMT    po/it.msg 519 translated, 1 untranslated.\n    MSGFMT    po/ja.msg 520 translated.\n    MSGFMT po/pt_br.msg 520 translated.\n    MSGFMT    po/bg.msg 547 translated.\n    MSGFMT    po/ru.msg 516 translated, 4 untranslated.\n    MSGFMT po/zh_cn.msg 366 translated, 7 fuzzy, 17 untranslated.\n    MSGFMT    po/el.msg 381 translated, 4 fuzzy, 6 untranslated.\n    SUBDIR gitk-git\n    GEN gitk-wish\nGenerating catalog po/de.msg\nmsgfmt --statistics --tcl po/de.po -l de -d po/\nGenerating catalog po/vi.msg\nmsgfmt --statistics --tcl po/vi.po -l vi -d po/\nGenerating catalog po/ca.msg\nmsgfmt --statistics --tcl po/ca.po -l ca -d po/\nGenerating catalog po/hu.msg\nmsgfmt --statistics --tcl po/hu.po -l hu -d po/\nGenerating catalog po/es.msg\nmsgfmt --statistics --tcl po/es.po -l es -d po/\nGenerating catalog po/sv.msg\nmsgfmt --statistics --tcl po/sv.po -l sv -d po/\nGenerating catalog po/fr.msg\nmsgfmt --statistics --tcl po/fr.po -l fr -d po/\nGenerating catalog po/it.msg\nmsgfmt --statistics --tcl po/it.po -l it -d po/\nGenerating catalog po/ja.msg\nmsgfmt --statistics --tcl po/ja.po -l ja -d po/\nGenerating catalog po/pt_br.msg\nmsgfmt --statistics --tcl po/pt_br.po -l pt_br -d po/\nGenerating catalog po/bg.msg\nmsgfmt --statistics --tcl po/bg.po -l bg -d po/\nGenerating catalog po/ru.msg\nmsgfmt --statistics --tcl po/ru.po -l ru -d po/\n    SUBDIR perl\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Editor.pm >blib/lib/Git/SVN/Editor.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Migration.pm >blib/lib/Git/SVN/Migration.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Log.pm >blib/lib/Git/SVN/Log.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN.pm >blib/lib/Git/SVN.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Memoize/YAML.pm >blib/lib/Git/SVN/Memoize/YAML.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Ra.pm >blib/lib/Git/SVN/Ra.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/I18N.pm >blib/lib/Git/I18N.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Prompt.pm >blib/lib/Git/SVN/Prompt.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/GlobSpec.pm >blib/lib/Git/SVN/GlobSpec.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Fetcher.pm >blib/lib/Git/SVN/Fetcher.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/IndexInfo.pm >blib/lib/Git/IndexInfo.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Utils.pm >blib/lib/Git/SVN/Utils.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git.pm >blib/lib/Git.pm\nManifying blib/man3/Git::SVN::Editor.3pm\nManifying blib/man3/Git::SVN::Memoize::YAML.3pm\nManifying blib/man3/Git::SVN::Ra.3pm\nManifying blib/man3/Git::I18N.3pm\nManifying blib/man3/Git::SVN::Prompt.3pm\nManifying blib/man3/Git::SVN::Fetcher.3pm\nManifying blib/man3/Git::SVN::Utils.3pm\nManifying blib/man3/Git.3pm\n    SUBDIR templates\n    MSGFMT po/build/locale/pt_PT/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/de/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/vi/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/is/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/ca/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/ko/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/sv/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/fr/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/it/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/bg/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/ru/LC_MESSAGES/git.mo\n    MSGFMT po/build/locale/zh_CN/LC_MESSAGES/git.mo\n    CC t/helper/test-chmtime.o\n    LINK t/helper/test-chmtime\n    CC t/helper/test-ctype.o\n    LINK t/helper/test-ctype\n    CC t/helper/test-config.o\n    LINK t/helper/test-config\n    CC t/helper/test-date.o\n    LINK t/helper/test-date\n    CC t/helper/test-delta.o\n    LINK t/helper/test-delta\n    CC t/helper/test-dump-cache-tree.o\n    LINK t/helper/test-dump-cache-tree\n    CC t/helper/test-dump-split-index.o\n    LINK t/helper/test-dump-split-index\n    CC t/helper/test-dump-untracked-cache.o\n    LINK t/helper/test-dump-untracked-cache\n    CC t/helper/test-fake-ssh.o\n    LINK t/helper/test-fake-ssh\n    CC t/helper/test-genrandom.o\n    LINK t/helper/test-genrandom\n    CC t/helper/test-hashmap.o\n    LINK t/helper/test-hashmap\n    CC t/helper/test-index-version.o\n    LINK t/helper/test-index-version\n    CC t/helper/test-line-buffer.o\n    LINK t/helper/test-line-buffer\n    CC t/helper/test-match-trees.o\n    LINK t/helper/test-match-trees\n    CC t/helper/test-mergesort.o\n    LINK t/helper/test-mergesort\n    CC t/helper/test-mktemp.o\n    LINK t/helper/test-mktemp\n    CC t/helper/test-parse-options.o\n    LINK t/helper/test-parse-options\n    CC t/helper/test-path-utils.o\n    LINK t/helper/test-path-utils\n    CC t/helper/test-prio-queue.o\n    LINK t/helper/test-prio-queue\n    CC t/helper/test-read-cache.o\n    LINK t/helper/test-read-cache\n    CC t/helper/test-regex.o\n    LINK t/helper/test-regex\n    CC t/helper/test-revision-walking.o\n    LINK t/helper/test-revision-walking\n    CC t/helper/test-run-command.o\n    LINK t/helper/test-run-command\n    CC t/helper/test-scrap-cache-tree.o\n    LINK t/helper/test-scrap-cache-tree\n    CC t/helper/test-sha1.o\n    LINK t/helper/test-sha1\n    CC t/helper/test-sha1-array.o\n    LINK t/helper/test-sha1-array\n    CC t/helper/test-sigchain.o\n    LINK t/helper/test-sigchain\n    CC t/helper/test-string-list.o\n    LINK t/helper/test-string-list\n    CC t/helper/test-submodule-config.o\n    LINK t/helper/test-submodule-config\n    CC t/helper/test-subprocess.o\n    LINK t/helper/test-subprocess\n    CC t/helper/test-svn-fe.o\n    LINK t/helper/test-svn-fe\n    CC t/helper/test-urlmatch-normalization.o\n    LINK t/helper/test-urlmatch-normalization\n    CC t/helper/test-wildmatch.o\n    LINK t/helper/test-wildmatch\n    GEN bin-wrappers/git\n    GEN bin-wrappers/git-upload-pack\n    GEN bin-wrappers/git-receive-pack\n    GEN bin-wrappers/git-upload-archive\n    GEN bin-wrappers/git-shell\n    GEN bin-wrappers/git-cvsserver\n    GEN bin-wrappers/test-chmtime\n    GEN bin-wrappers/test-ctype\n    GEN bin-wrappers/test-config\n    GEN bin-wrappers/test-date\n    GEN bin-wrappers/test-delta\n    GEN bin-wrappers/test-dump-cache-tree\n    GEN bin-wrappers/test-dump-split-index\n    GEN bin-wrappers/test-dump-untracked-cache\n    GEN bin-wrappers/test-fake-ssh\n    GEN bin-wrappers/test-genrandom\n    GEN bin-wrappers/test-hashmap\n    GEN bin-wrappers/test-index-version\n    GEN bin-wrappers/test-line-buffer\n    GEN bin-wrappers/test-match-trees\n    GEN bin-wrappers/test-mergesort\n    GEN bin-wrappers/test-mktemp\n    GEN bin-wrappers/test-parse-options\n    GEN bin-wrappers/test-path-utils\n    GEN bin-wrappers/test-prio-queue\n    GEN bin-wrappers/test-read-cache\n    GEN bin-wrappers/test-regex\n    GEN bin-wrappers/test-revision-walking\n    GEN bin-wrappers/test-run-command\n    GEN bin-wrappers/test-scrap-cache-tree\n    GEN bin-wrappers/test-sha1\n    GEN bin-wrappers/test-sha1-array\n    GEN bin-wrappers/test-sigchain\n    GEN bin-wrappers/test-string-list\n    GEN bin-wrappers/test-submodule-config\n    GEN bin-wrappers/test-subprocess\n    GEN bin-wrappers/test-svn-fe\n    GEN bin-wrappers/test-urlmatch-normalization\n    GEN bin-wrappers/test-wildmatch\n    GEN git-remote-testgit", "stdout_lines": ["    CC credential-store.o", "    CC abspath.o", "    CC advice.o", "    CC alias.o", "    CC alloc.o", "    CC archive.o", "    CC archive-tar.o", "    CC archive-zip.o", "    CC argv-array.o", "    CC attr.o", "    CC base85.o", "    CC bisect.o", "    CC blob.o", "    CC branch.o", "    CC bulk-checkin.o", "    CC bundle.o", "    CC cache-tree.o", "    CC color.o", "    CC column.o", "    CC combine-diff.o", "    CC commit.o", "    CC compat/obstack.o", "    CC compat/terminal.o", "    CC config.o", "    CC connect.o", "    CC connected.o", "    CC convert.o", "    CC copy.o", "    CC credential.o", "    CC csum-file.o", "    CC ctype.o", "    CC date.o", "    CC decorate.o", "    CC diffcore-break.o", "    CC diffcore-delta.o", "    CC diffcore-order.o", "    CC diffcore-pickaxe.o", "    CC diffcore-rename.o", "    CC diff-delta.o", "    CC diff-lib.o", "    CC diff-no-index.o", "    CC diff.o", "    CC dir.o", "    CC editor.o", "    CC entry.o", "    CC environment.o", "    CC ewah/bitmap.o", "    CC ewah/ewah_bitmap.o", "    CC ewah/ewah_io.o", "    CC ewah/ewah_rlw.o", "    CC exec_cmd.o", "    CC fetch-pack.o", "    CC fsck.o", "    CC gettext.o", "    CC gpg-interface.o", "    CC graph.o", "    CC grep.o", "    CC hashmap.o", "    GEN common-cmds.h", "    CC help.o", "    CC hex.o", "    CC ident.o", "    CC kwset.o", "    CC levenshtein.o", "    CC line-log.o", "    CC line-range.o", "    CC list-objects.o", "    CC ll-merge.o", "    CC lockfile.o", "    CC log-tree.o", "    CC mailinfo.o", "    CC mailmap.o", "    CC match-trees.o", "    CC merge.o", "    CC merge-blobs.o", "    CC merge-recursive.o", "    CC mergesort.o", "    CC name-hash.o", "    CC notes.o", "    CC notes-cache.o", "    CC notes-merge.o", "    CC notes-utils.o", "    CC object.o", "    CC pack-bitmap.o", "    CC pack-bitmap-write.o", "    CC pack-check.o", "    CC pack-objects.o", "    CC pack-revindex.o", "    CC pack-write.o", "    CC pager.o", "    CC parse-options.o", "    CC parse-options-cb.o", "    CC patch-delta.o", "    CC patch-ids.o", "    CC path.o", "    CC pathspec.o", "    CC pkt-line.o", "    CC preload-index.o", "    CC pretty.o", "    CC prio-queue.o", "    CC progress.o", "    CC prompt.o", "    CC quote.o", "    CC reachable.o", "    CC read-cache.o", "    CC reflog-walk.o", "    CC refs.o", "    CC refs/files-backend.o", "    CC ref-filter.o", "    CC remote.o", "    CC replace_object.o", "    CC rerere.o", "    CC resolve-undo.o", "    CC revision.o", "    CC run-command.o", "    CC send-pack.o", "    CC sequencer.o", "    CC server-info.o", "    CC setup.o", "    CC sha1-array.o", "    CC sha1-lookup.o", "    CC sha1_file.o", "    CC sha1_name.o", "    CC shallow.o", "    CC sideband.o", "    CC sigchain.o", "    CC split-index.o", "    CC strbuf.o", "    CC streaming.o", "    CC string-list.o", "    CC submodule.o", "    CC submodule-config.o", "    CC symlinks.o", "    CC tag.o", "    CC tempfile.o", "    CC trace.o", "    CC trailer.o", "    CC transport.o", "    CC transport-helper.o", "    CC tree-diff.o", "    CC tree.o", "    CC tree-walk.o", "    CC unpack-trees.o", "    CC url.o", "    CC urlmatch.o", "    CC usage.o", "    CC userdiff.o", "    CC utf8.o", "    CC varint.o", "    CC version.o", "    CC versioncmp.o", "    CC walker.o", "    CC wildmatch.o", "    CC worktree.o", "    CC wrapper.o", "    CC write_or_die.o", "    CC ws.o", "    CC wt-status.o", "    CC xdiff-interface.o", "    CC zlib.o", "    CC unix-socket.o", "    CC thread-utils.o", "    CC compat/strlcpy.o", "    AR libgit.a", "    CC xdiff/xdiffi.o", "    CC xdiff/xprepare.o", "    CC xdiff/xutils.o", "    CC xdiff/xemit.o", "    CC xdiff/xmerge.o", "    CC xdiff/xpatience.o", "    CC xdiff/xhistogram.o", "    AR xdiff/lib.a", "    LINK git-credential-store", "    CC daemon.o", "    LINK git-daemon", "    CC fast-import.o", "    LINK git-fast-import", "    CC http-backend.o", "    LINK git-http-backend", "    CC imap-send.o", "    LINK git-imap-send", "    CC sh-i18n--envsubst.o", "    LINK git-sh-i18n--envsubst", "    CC shell.o", "    LINK git-shell", "    CC show-index.o", "    LINK git-show-index", "    CC upload-pack.o", "    LINK git-upload-pack", "    CC remote-testsvn.o", "    CC vcs-svn/line_buffer.o", "    CC vcs-svn/sliding_window.o", "    CC vcs-svn/repo_tree.o", "    CC vcs-svn/fast_export.o", "    CC vcs-svn/svndiff.o", "    CC vcs-svn/svndump.o", "    AR vcs-svn/lib.a", "    LINK git-remote-testsvn", "    CC http.o", "    CC http-walker.o", "    CC http-fetch.o", "    LINK git-http-fetch", "    CC http-push.o", "    LINK git-http-push", "    CC credential-cache.o", "    LINK git-credential-cache", "    CC credential-cache--daemon.o", "    LINK git-credential-cache--daemon", "    CC remote-curl.o", "    LINK git-remote-http", "    LN/CP git-remote-https", "    LN/CP git-remote-ftp", "    LN/CP git-remote-ftps", "    GEN git-bisect", "    GEN git-difftool--helper", "    GEN git-filter-branch", "    GEN git-merge-octopus", "    GEN git-merge-one-file", "    GEN git-merge-resolve", "    GEN git-mergetool", "    GEN git-quiltimport", "    GEN git-rebase", "    GEN git-request-pull", "    GEN git-stash", "    GEN git-submodule", "    GEN git-web--browse", "    SUBDIR perl", "/usr/bin/perl Makefile.PL PREFIX='/usr' INSTALL_BASE='' --localedir='/usr/share/locale'", "    GEN git-add--interactive", "    GEN git-difftool", "    GEN git-archimport", "    GEN git-cvsexportcommit", "    GEN git-cvsimport", "    GEN git-cvsserver", "    GEN git-relink", "    GEN git-send-email", "    GEN git-svn", "    GEN git-p4", "    GEN git-instaweb", "    GEN git-mergetool--lib", "    GEN git-parse-remote", "    GEN git-rebase--am", "    GEN git-rebase--interactive", "    GEN git-rebase--merge", "    GEN git-sh-setup", "    GEN git-sh-i18n", "    CC git.o", "    CC builtin/add.o", "    CC builtin/am.o", "    CC builtin/annotate.o", "    CC builtin/apply.o", "    CC builtin/archive.o", "    CC builtin/bisect--helper.o", "    CC builtin/blame.o", "    CC builtin/branch.o", "    CC builtin/bundle.o", "    CC builtin/cat-file.o", "    CC builtin/check-attr.o", "    CC builtin/check-ignore.o", "    CC builtin/check-mailmap.o", "    CC builtin/check-ref-format.o", "    CC builtin/checkout-index.o", "    CC builtin/checkout.o", "    CC builtin/clean.o", "    CC builtin/clone.o", "    CC builtin/column.o", "    CC builtin/commit-tree.o", "    CC builtin/commit.o", "    CC builtin/config.o", "    CC builtin/count-objects.o", "    CC builtin/credential.o", "    CC builtin/describe.o", "    CC builtin/diff-files.o", "    CC builtin/diff-index.o", "    CC builtin/diff-tree.o", "    CC builtin/diff.o", "    CC builtin/fast-export.o", "    CC builtin/fetch-pack.o", "    CC builtin/fetch.o", "    CC builtin/fmt-merge-msg.o", "    CC builtin/for-each-ref.o", "    CC builtin/fsck.o", "    CC builtin/gc.o", "    CC builtin/get-tar-commit-id.o", "    CC builtin/grep.o", "    CC builtin/hash-object.o", "    CC builtin/help.o", "    CC builtin/index-pack.o", "    CC builtin/init-db.o", "    CC builtin/interpret-trailers.o", "    CC builtin/log.o", "    CC builtin/ls-files.o", "    CC builtin/ls-remote.o", "    CC builtin/ls-tree.o", "    CC builtin/mailinfo.o", "    CC builtin/mailsplit.o", "    CC builtin/merge.o", "    CC builtin/merge-base.o", "    CC builtin/merge-file.o", "    CC builtin/merge-index.o", "    CC builtin/merge-ours.o", "    CC builtin/merge-recursive.o", "    CC builtin/merge-tree.o", "    CC builtin/mktag.o", "    CC builtin/mktree.o", "    CC builtin/mv.o", "    CC builtin/name-rev.o", "    CC builtin/notes.o", "    CC builtin/pack-objects.o", "    CC builtin/pack-redundant.o", "    CC builtin/pack-refs.o", "    CC builtin/patch-id.o", "    CC builtin/prune-packed.o", "    CC builtin/prune.o", "    CC builtin/pull.o", "    CC builtin/push.o", "    CC builtin/read-tree.o", "    CC builtin/receive-pack.o", "    CC builtin/reflog.o", "    CC builtin/remote.o", "    CC builtin/remote-ext.o", "    CC builtin/remote-fd.o", "    CC builtin/repack.o", "    CC builtin/replace.o", "    CC builtin/rerere.o", "    CC builtin/reset.o", "    CC builtin/rev-list.o", "    CC builtin/rev-parse.o", "    CC builtin/revert.o", "    CC builtin/rm.o", "    CC builtin/send-pack.o", "    CC builtin/shortlog.o", "    CC builtin/show-branch.o", "    CC builtin/show-ref.o", "    CC builtin/stripspace.o", "    CC builtin/submodule--helper.o", "    CC builtin/symbolic-ref.o", "    CC builtin/tag.o", "    CC builtin/unpack-file.o", "    CC builtin/unpack-objects.o", "    CC builtin/update-index.o", "    CC builtin/update-ref.o", "    CC builtin/update-server-info.o", "    CC builtin/upload-archive.o", "    CC builtin/var.o", "    CC builtin/verify-commit.o", "    CC builtin/verify-pack.o", "    CC builtin/verify-tag.o", "    CC builtin/worktree.o", "    CC builtin/write-tree.o", "    LINK git", "    BUILTIN git-add", "    BUILTIN git-am", "    BUILTIN git-annotate", "    BUILTIN git-apply", "    BUILTIN git-archive", "    BUILTIN git-bisect--helper", "    BUILTIN git-blame", "    BUILTIN git-branch", "    BUILTIN git-bundle", "    BUILTIN git-cat-file", "    BUILTIN git-check-attr", "    BUILTIN git-check-ignore", "    BUILTIN git-check-mailmap", "    BUILTIN git-check-ref-format", "    BUILTIN git-checkout-index", "    BUILTIN git-checkout", "    BUILTIN git-clean", "    BUILTIN git-clone", "    BUILTIN git-column", "    BUILTIN git-commit-tree", "    BUILTIN git-commit", "    BUILTIN git-config", "    BUILTIN git-count-objects", "    BUILTIN git-credential", "    BUILTIN git-describe", "    BUILTIN git-diff-files", "    BUILTIN git-diff-index", "    BUILTIN git-diff-tree", "    BUILTIN git-diff", "    BUILTIN git-fast-export", "    BUILTIN git-fetch-pack", "    BUILTIN git-fetch", "    BUILTIN git-fmt-merge-msg", "    BUILTIN git-for-each-ref", "    BUILTIN git-fsck", "    BUILTIN git-gc", "    BUILTIN git-get-tar-commit-id", "    BUILTIN git-grep", "    BUILTIN git-hash-object", "    BUILTIN git-help", "    BUILTIN git-index-pack", "    BUILTIN git-init-db", "    BUILTIN git-interpret-trailers", "    BUILTIN git-log", "    BUILTIN git-ls-files", "    BUILTIN git-ls-remote", "    BUILTIN git-ls-tree", "    BUILTIN git-mailinfo", "    BUILTIN git-mailsplit", "    BUILTIN git-merge", "    BUILTIN git-merge-base", "    BUILTIN git-merge-file", "    BUILTIN git-merge-index", "    BUILTIN git-merge-ours", "    BUILTIN git-merge-recursive", "    BUILTIN git-merge-tree", "    BUILTIN git-mktag", "    BUILTIN git-mktree", "    BUILTIN git-mv", "    BUILTIN git-name-rev", "    BUILTIN git-notes", "    BUILTIN git-pack-objects", "    BUILTIN git-pack-redundant", "    BUILTIN git-pack-refs", "    BUILTIN git-patch-id", "    BUILTIN git-prune-packed", "    BUILTIN git-prune", "    BUILTIN git-pull", "    BUILTIN git-push", "    BUILTIN git-read-tree", "    BUILTIN git-receive-pack", "    BUILTIN git-reflog", "    BUILTIN git-remote", "    BUILTIN git-remote-ext", "    BUILTIN git-remote-fd", "    BUILTIN git-repack", "    BUILTIN git-replace", "    BUILTIN git-rerere", "    BUILTIN git-reset", "    BUILTIN git-rev-list", "    BUILTIN git-rev-parse", "    BUILTIN git-revert", "    BUILTIN git-rm", "    BUILTIN git-send-pack", "    BUILTIN git-shortlog", "    BUILTIN git-show-branch", "    BUILTIN git-show-ref", "    BUILTIN git-stripspace", "    BUILTIN git-submodule--helper", "    BUILTIN git-symbolic-ref", "    BUILTIN git-tag", "    BUILTIN git-unpack-file", "    BUILTIN git-unpack-objects", "    BUILTIN git-update-index", "    BUILTIN git-update-ref", "    BUILTIN git-update-server-info", "    BUILTIN git-upload-archive", "    BUILTIN git-var", "    BUILTIN git-verify-commit", "    BUILTIN git-verify-pack", "    BUILTIN git-verify-tag", "    BUILTIN git-worktree", "    BUILTIN git-write-tree", "    BUILTIN git-cherry", "    BUILTIN git-cherry-pick", "    BUILTIN git-format-patch", "    BUILTIN git-fsck-objects", "    BUILTIN git-init", "    BUILTIN git-merge-subtree", "    BUILTIN git-show", "    BUILTIN git-stage", "    BUILTIN git-status", "    BUILTIN git-whatchanged", "    SUBDIR git-gui", "    GEN git-gui", "    INDEX lib/", "    MSGFMT    po/de.msg 520 translated.", "    MSGFMT    po/vi.msg 543 translated.", "    MSGFMT    po/hu.msg 514 translated.", "    MSGFMT    po/nb.msg 474 translated, 39 untranslated.", "    MSGFMT    po/sv.msg 547 translated.", "    MSGFMT    po/fr.msg 520 translated.", "    MSGFMT    po/it.msg 519 translated, 1 untranslated.", "    MSGFMT    po/ja.msg 520 translated.", "    MSGFMT po/pt_br.msg 520 translated.", "    MSGFMT    po/bg.msg 547 translated.", "    MSGFMT    po/ru.msg 516 translated, 4 untranslated.", "    MSGFMT po/zh_cn.msg 366 translated, 7 fuzzy, 17 untranslated.", "    MSGFMT    po/el.msg 381 translated, 4 fuzzy, 6 untranslated.", "    SUBDIR gitk-git", "    GEN gitk-wish", "Generating catalog po/de.msg", "msgfmt --statistics --tcl po/de.po -l de -d po/", "Generating catalog po/vi.msg", "msgfmt --statistics --tcl po/vi.po -l vi -d po/", "Generating catalog po/ca.msg", "msgfmt --statistics --tcl po/ca.po -l ca -d po/", "Generating catalog po/hu.msg", "msgfmt --statistics --tcl po/hu.po -l hu -d po/", "Generating catalog po/es.msg", "msgfmt --statistics --tcl po/es.po -l es -d po/", "Generating catalog po/sv.msg", "msgfmt --statistics --tcl po/sv.po -l sv -d po/", "Generating catalog po/fr.msg", "msgfmt --statistics --tcl po/fr.po -l fr -d po/", "Generating catalog po/it.msg", "msgfmt --statistics --tcl po/it.po -l it -d po/", "Generating catalog po/ja.msg", "msgfmt --statistics --tcl po/ja.po -l ja -d po/", "Generating catalog po/pt_br.msg", "msgfmt --statistics --tcl po/pt_br.po -l pt_br -d po/", "Generating catalog po/bg.msg", "msgfmt --statistics --tcl po/bg.po -l bg -d po/", "Generating catalog po/ru.msg", "msgfmt --statistics --tcl po/ru.po -l ru -d po/", "    SUBDIR perl", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Editor.pm >blib/lib/Git/SVN/Editor.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Migration.pm >blib/lib/Git/SVN/Migration.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Log.pm >blib/lib/Git/SVN/Log.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN.pm >blib/lib/Git/SVN.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Memoize/YAML.pm >blib/lib/Git/SVN/Memoize/YAML.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Ra.pm >blib/lib/Git/SVN/Ra.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/I18N.pm >blib/lib/Git/I18N.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Prompt.pm >blib/lib/Git/SVN/Prompt.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/GlobSpec.pm >blib/lib/Git/SVN/GlobSpec.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Fetcher.pm >blib/lib/Git/SVN/Fetcher.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/IndexInfo.pm >blib/lib/Git/IndexInfo.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Utils.pm >blib/lib/Git/SVN/Utils.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git.pm >blib/lib/Git.pm", "Manifying blib/man3/Git::SVN::Editor.3pm", "Manifying blib/man3/Git::SVN::Memoize::YAML.3pm", "Manifying blib/man3/Git::SVN::Ra.3pm", "Manifying blib/man3/Git::I18N.3pm", "Manifying blib/man3/Git::SVN::Prompt.3pm", "Manifying blib/man3/Git::SVN::Fetcher.3pm", "Manifying blib/man3/Git::SVN::Utils.3pm", "Manifying blib/man3/Git.3pm", "    SUBDIR templates", "    MSGFMT po/build/locale/pt_PT/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/de/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/vi/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/is/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/ca/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/ko/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/sv/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/fr/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/it/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/bg/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/ru/LC_MESSAGES/git.mo", "    MSGFMT po/build/locale/zh_CN/LC_MESSAGES/git.mo", "    CC t/helper/test-chmtime.o", "    LINK t/helper/test-chmtime", "    CC t/helper/test-ctype.o", "    LINK t/helper/test-ctype", "    CC t/helper/test-config.o", "    LINK t/helper/test-config", "    CC t/helper/test-date.o", "    LINK t/helper/test-date", "    CC t/helper/test-delta.o", "    LINK t/helper/test-delta", "    CC t/helper/test-dump-cache-tree.o", "    LINK t/helper/test-dump-cache-tree", "    CC t/helper/test-dump-split-index.o", "    LINK t/helper/test-dump-split-index", "    CC t/helper/test-dump-untracked-cache.o", "    LINK t/helper/test-dump-untracked-cache", "    CC t/helper/test-fake-ssh.o", "    LINK t/helper/test-fake-ssh", "    CC t/helper/test-genrandom.o", "    LINK t/helper/test-genrandom", "    CC t/helper/test-hashmap.o", "    LINK t/helper/test-hashmap", "    CC t/helper/test-index-version.o", "    LINK t/helper/test-index-version", "    CC t/helper/test-line-buffer.o", "    LINK t/helper/test-line-buffer", "    CC t/helper/test-match-trees.o", "    LINK t/helper/test-match-trees", "    CC t/helper/test-mergesort.o", "    LINK t/helper/test-mergesort", "    CC t/helper/test-mktemp.o", "    LINK t/helper/test-mktemp", "    CC t/helper/test-parse-options.o", "    LINK t/helper/test-parse-options", "    CC t/helper/test-path-utils.o", "    LINK t/helper/test-path-utils", "    CC t/helper/test-prio-queue.o", "    LINK t/helper/test-prio-queue", "    CC t/helper/test-read-cache.o", "    LINK t/helper/test-read-cache", "    CC t/helper/test-regex.o", "    LINK t/helper/test-regex", "    CC t/helper/test-revision-walking.o", "    LINK t/helper/test-revision-walking", "    CC t/helper/test-run-command.o", "    LINK t/helper/test-run-command", "    CC t/helper/test-scrap-cache-tree.o", "    LINK t/helper/test-scrap-cache-tree", "    CC t/helper/test-sha1.o", "    LINK t/helper/test-sha1", "    CC t/helper/test-sha1-array.o", "    LINK t/helper/test-sha1-array", "    CC t/helper/test-sigchain.o", "    LINK t/helper/test-sigchain", "    CC t/helper/test-string-list.o", "    LINK t/helper/test-string-list", "    CC t/helper/test-submodule-config.o", "    LINK t/helper/test-submodule-config", "    CC t/helper/test-subprocess.o", "    LINK t/helper/test-subprocess", "    CC t/helper/test-svn-fe.o", "    LINK t/helper/test-svn-fe", "    CC t/helper/test-urlmatch-normalization.o", "    LINK t/helper/test-urlmatch-normalization", "    CC t/helper/test-wildmatch.o", "    LINK t/helper/test-wildmatch", "    GEN bin-wrappers/git", "    GEN bin-wrappers/git-upload-pack", "    GEN bin-wrappers/git-receive-pack", "    GEN bin-wrappers/git-upload-archive", "    GEN bin-wrappers/git-shell", "    GEN bin-wrappers/git-cvsserver", "    GEN bin-wrappers/test-chmtime", "    GEN bin-wrappers/test-ctype", "    GEN bin-wrappers/test-config", "    GEN bin-wrappers/test-date", "    GEN bin-wrappers/test-delta", "    GEN bin-wrappers/test-dump-cache-tree", "    GEN bin-wrappers/test-dump-split-index", "    GEN bin-wrappers/test-dump-untracked-cache", "    GEN bin-wrappers/test-fake-ssh", "    GEN bin-wrappers/test-genrandom", "    GEN bin-wrappers/test-hashmap", "    GEN bin-wrappers/test-index-version", "    GEN bin-wrappers/test-line-buffer", "    GEN bin-wrappers/test-match-trees", "    GEN bin-wrappers/test-mergesort", "    GEN bin-wrappers/test-mktemp", "    GEN bin-wrappers/test-parse-options", "    GEN bin-wrappers/test-path-utils", "    GEN bin-wrappers/test-prio-queue", "    GEN bin-wrappers/test-read-cache", "    GEN bin-wrappers/test-regex", "    GEN bin-wrappers/test-revision-walking", "    GEN bin-wrappers/test-run-command", "    GEN bin-wrappers/test-scrap-cache-tree", "    GEN bin-wrappers/test-sha1", "    GEN bin-wrappers/test-sha1-array", "    GEN bin-wrappers/test-sigchain", "    GEN bin-wrappers/test-string-list", "    GEN bin-wrappers/test-submodule-config", "    GEN bin-wrappers/test-subprocess", "    GEN bin-wrappers/test-svn-fe", "    GEN bin-wrappers/test-urlmatch-normalization", "    GEN bin-wrappers/test-wildmatch", "    GEN git-remote-testgit"]}
    # changed: [atlassian1] => (item=install) => {"changed": true, "cmd": ["make", "prefix=/usr", "install"], "delta": "0:00:02.526919", "end": "2018-11-16 12:13:08.071512", "item": "install", "rc": 0, "start": "2018-11-16 12:13:05.544593", "stderr": "Writing perl.mak for Git", "stderr_lines": ["Writing perl.mak for Git"], "stdout": "    SUBDIR perl\n/usr/bin/perl Makefile.PL PREFIX='/usr' INSTALL_BASE='' --localedir='/usr/share/locale'\n    GEN git-add--interactive\n    GEN git-difftool\n    GEN git-archimport\n    GEN git-cvsexportcommit\n    GEN git-cvsimport\n    GEN git-cvsserver\n    GEN git-relink\n    GEN git-send-email\n    GEN git-svn\n    SUBDIR git-gui\n    SUBDIR gitk-git\n    SUBDIR perl\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Editor.pm >blib/lib/Git/SVN/Editor.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Migration.pm >blib/lib/Git/SVN/Migration.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Log.pm >blib/lib/Git/SVN/Log.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN.pm >blib/lib/Git/SVN.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Memoize/YAML.pm >blib/lib/Git/SVN/Memoize/YAML.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Ra.pm >blib/lib/Git/SVN/Ra.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/I18N.pm >blib/lib/Git/I18N.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Prompt.pm >blib/lib/Git/SVN/Prompt.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/GlobSpec.pm >blib/lib/Git/SVN/GlobSpec.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Fetcher.pm >blib/lib/Git/SVN/Fetcher.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/IndexInfo.pm >blib/lib/Git/IndexInfo.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Utils.pm >blib/lib/Git/SVN/Utils.pm\n/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git.pm >blib/lib/Git.pm\n    SUBDIR templates\ninstall -d -m 755 '/usr/bin'\ninstall -d -m 755 '/usr/libexec/git-core'\ninstall   git-credential-store git-daemon git-fast-import git-http-backend git-imap-send git-sh-i18n--envsubst git-shell git-show-index git-upload-pack git-remote-testsvn git-http-fetch git-http-push git-credential-cache git-credential-cache--daemon git-remote-http git-remote-https git-remote-ftp git-remote-ftps git-bisect git-difftool--helper git-filter-branch git-merge-octopus git-merge-one-file git-merge-resolve git-mergetool git-quiltimport git-rebase git-request-pull git-stash git-submodule git-web--browse git-add--interactive git-difftool git-archimport git-cvsexportcommit git-cvsimport git-cvsserver git-relink git-send-email git-svn git-p4 git-instaweb '/usr/libexec/git-core'\ninstall -m 644  git-mergetool--lib git-parse-remote git-rebase--am git-rebase--interactive git-rebase--merge git-sh-setup git-sh-i18n '/usr/libexec/git-core'\ninstall git git-upload-pack git-receive-pack git-upload-archive git-shell git-cvsserver '/usr/bin'\nmake -C templates DESTDIR='' install\nmake[1]: Entering directory `/root/git-2.9.3/templates'\ninstall -d -m 755 '/usr/share/git-core/templates'\n(cd blt && tar cf - .) | \\\n(cd '/usr/share/git-core/templates' && umask 022 && tar xof -)\nmake[1]: Leaving directory `/root/git-2.9.3/templates'\ninstall -d -m 755 '/usr/libexec/git-core/mergetools'\ninstall -m 644 mergetools/* '/usr/libexec/git-core/mergetools'\ninstall -d -m 755 '/usr/share/locale'\n(cd po/build/locale && tar cf - .) | \\\n(cd '/usr/share/locale' && umask 022 && tar xof -)\nmake -C perl prefix='/usr' DESTDIR='' install\nmake[1]: Entering directory `/root/git-2.9.3/perl'\nmake[2]: Entering directory `/root/git-2.9.3/perl'\nInstalling /usr/share/perl5/Git.pm\nInstalling /usr/share/perl5/Git/SVN.pm\nInstalling /usr/share/perl5/Git/I18N.pm\nInstalling /usr/share/perl5/Git/IndexInfo.pm\nInstalling /usr/share/perl5/Git/SVN/Editor.pm\nInstalling /usr/share/perl5/Git/SVN/Migration.pm\nInstalling /usr/share/perl5/Git/SVN/Log.pm\nInstalling /usr/share/perl5/Git/SVN/Ra.pm\nInstalling /usr/share/perl5/Git/SVN/Prompt.pm\nInstalling /usr/share/perl5/Git/SVN/GlobSpec.pm\nInstalling /usr/share/perl5/Git/SVN/Fetcher.pm\nInstalling /usr/share/perl5/Git/SVN/Utils.pm\nInstalling /usr/share/perl5/Git/SVN/Memoize/YAML.pm\nInstalling /usr/share/man/man3/Git::SVN::Editor.3pm\nInstalling /usr/share/man/man3/Git::SVN::Memoize::YAML.3pm\nInstalling /usr/share/man/man3/Git::SVN::Ra.3pm\nInstalling /usr/share/man/man3/Git::I18N.3pm\nInstalling /usr/share/man/man3/Git::SVN::Prompt.3pm\nInstalling /usr/share/man/man3/Git::SVN::Fetcher.3pm\nInstalling /usr/share/man/man3/Git::SVN::Utils.3pm\nInstalling /usr/share/man/man3/Git.3pm\nAppending installation info to /usr/lib64/perl5/perllocal.pod\nmake[2]: Leaving directory `/root/git-2.9.3/perl'\nmake[1]: Leaving directory `/root/git-2.9.3/perl'\nmake -C gitweb install\nmake[1]: Entering directory `/root/git-2.9.3/gitweb'\nmake[2]: Entering directory `/root/git-2.9.3'\nmake[2]: `GIT-VERSION-FILE' is up to date.\nmake[2]: Leaving directory `/root/git-2.9.3'\n    GEN gitweb.cgi\n    GEN static/gitweb.js\ninstall -d -m 755 '/usr/share/gitweb'\ninstall -m 755 gitweb.cgi '/usr/share/gitweb'\ninstall -d -m 755 '/usr/share/gitweb/static'\ninstall -m 644 static/gitweb.js static/gitweb.css static/git-logo.png static/git-favicon.png '/usr/share/gitweb/static'\nmake[1]: Leaving directory `/root/git-2.9.3/gitweb'\nmake -C gitk-git install\nmake[1]: Entering directory `/root/git-2.9.3/gitk-git'\ninstall -m 755 gitk-wish '/usr/bin'/gitk\ninstall -d -m 755 '/usr/share/gitk/lib/msgs'\ninstall -m 644 po/de.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/ja.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/ca.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/sv.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/it.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/bg.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/fr.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/pt_br.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/ru.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/hu.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/vi.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/es.msg '/usr/share/gitk/lib/msgs' && true\nmake[1]: Leaving directory `/root/git-2.9.3/gitk-git'\nmake -C git-gui gitexecdir='/usr/libexec/git-core' install\nmake[1]: Entering directory `/root/git-2.9.3/git-gui'\n  DEST /usr/libexec/git-core\n    INSTALL 755 git-gui\n    INSTALL 755 git-gui--askpass\n    LINK        git-citool -> git-gui\n  DEST /usr/share/git-gui/lib\n    INSTALL 644 tclIndex\n    INSTALL 644 themed.tcl\n    INSTALL 644 line.tcl\n    INSTALL 644 console.tcl\n    INSTALL 644 checkout_op.tcl\n    INSTALL 644 transport.tcl\n    INSTALL 644 remote_add.tcl\n    INSTALL 644 browser.tcl\n    INSTALL 644 tools.tcl\n    INSTALL 644 branch_checkout.tcl\n    INSTALL 644 spellcheck.tcl\n    INSTALL 644 status_bar.tcl\n    INSTALL 644 diff.tcl\n    INSTALL 644 remote.tcl\n    INSTALL 644 choose_font.tcl\n    INSTALL 644 option.tcl\n    INSTALL 644 mergetool.tcl\n    INSTALL 644 tools_dlg.tcl\n    INSTALL 644 search.tcl\n    INSTALL 644 shortcut.tcl\n    INSTALL 644 branch_rename.tcl\n    INSTALL 644 class.tcl\n    INSTALL 644 remote_branch_delete.tcl\n    INSTALL 644 choose_repository.tcl\n    INSTALL 644 about.tcl\n    INSTALL 644 blame.tcl\n    INSTALL 644 branch.tcl\n    INSTALL 644 win32.tcl\n    INSTALL 644 sshkey.tcl\n    INSTALL 644 branch_create.tcl\n    INSTALL 644 commit.tcl\n    INSTALL 644 branch_delete.tcl\n    INSTALL 644 index.tcl\n    INSTALL 644 encoding.tcl\n    INSTALL 644 logo.tcl\n    INSTALL 644 date.tcl\n    INSTALL 644 choose_rev.tcl\n    INSTALL 644 database.tcl\n    INSTALL 644 error.tcl\n    INSTALL 644 merge.tcl\n    INSTALL 644 git-gui.ico\n    INSTALL 644 win32_shortcut.js\n  DEST /usr/share/git-gui/lib/msgs\n    INSTALL 644 pt_br.msg\n    INSTALL 644 hu.msg\n    INSTALL 644 zh_cn.msg\n    INSTALL 644 de.msg\n    INSTALL 644 ja.msg\n    INSTALL 644 sv.msg\n    INSTALL 644 it.msg\n    INSTALL 644 ru.msg\n    INSTALL 644 fr.msg\n    INSTALL 644 el.msg\n    INSTALL 644 vi.msg\n    INSTALL 644 bg.msg\n    INSTALL 644 nb.msg\nmake[1]: Leaving directory `/root/git-2.9.3/git-gui'\nbindir=$(cd '/usr/bin' && pwd) && \\\nexecdir=$(cd '/usr/libexec/git-core' && pwd) && \\\n{ test \"$bindir/\" = \"$execdir/\" || \\\n  for p in git git-shell git-upload-pack git-cvsserver; do \\\n\trm -f \"$execdir/$p\" && \\\n\ttest -z \"\" && \\\n\tln \"$bindir/$p\" \"$execdir/$p\" 2>/dev/null || \\\n\tcp \"$bindir/$p\" \"$execdir/$p\" || exit; \\\n  done; \\\n} && \\\nfor p in git-receive-pack git-upload-archive; do \\\n\trm -f \"$bindir/$p\" && \\\n\ttest -z \"\" && \\\n\tln \"$bindir/git\" \"$bindir/$p\" 2>/dev/null || \\\n\tln -s \"git\" \"$bindir/$p\" 2>/dev/null || \\\n\tcp \"$bindir/git\" \"$bindir/$p\" || exit; \\\ndone && \\\nfor p in  git-add git-am git-annotate git-apply git-archive git-bisect--helper git-blame git-branch git-bundle git-cat-file git-check-attr git-check-ignore git-check-mailmap git-check-ref-format git-checkout-index git-checkout git-clean git-clone git-column git-commit-tree git-commit git-config git-count-objects git-credential git-describe git-diff-files git-diff-index git-diff-tree git-diff git-fast-export git-fetch-pack git-fetch git-fmt-merge-msg git-for-each-ref git-fsck git-gc git-get-tar-commit-id git-grep git-hash-object git-help git-index-pack git-init-db git-interpret-trailers git-log git-ls-files git-ls-remote git-ls-tree git-mailinfo git-mailsplit git-merge git-merge-base git-merge-file git-merge-index git-merge-ours git-merge-recursive git-merge-tree git-mktag git-mktree git-mv git-name-rev git-notes git-pack-objects git-pack-redundant git-pack-refs git-patch-id git-prune-packed git-prune git-pull git-push git-read-tree git-receive-pack git-reflog git-remote git-remote-ext git-remote-fd git-repack git-replace git-rerere git-reset git-rev-list git-rev-parse git-revert git-rm git-send-pack git-shortlog git-show-branch git-show-ref git-stripspace git-submodule--helper git-symbolic-ref git-tag git-unpack-file git-unpack-objects git-update-index git-update-ref git-update-server-info git-upload-archive git-var git-verify-commit git-verify-pack git-verify-tag git-worktree git-write-tree git-cherry git-cherry-pick git-format-patch git-fsck-objects git-init git-merge-subtree git-show git-stage git-status git-whatchanged; do \\\n\trm -f \"$execdir/$p\" && \\\n\ttest -z \"\" && \\\n\tln \"$execdir/git\" \"$execdir/$p\" 2>/dev/null || \\\n\tln -s \"git\" \"$execdir/$p\" 2>/dev/null || \\\n\tcp \"$execdir/git\" \"$execdir/$p\" || exit; \\\ndone && \\\nremote_curl_aliases=\"git-remote-https git-remote-ftp git-remote-ftps\" && \\\nfor p in $remote_curl_aliases; do \\\n\trm -f \"$execdir/$p\" && \\\n\ttest -z \"\" && \\\n\tln \"$execdir/git-remote-http\" \"$execdir/$p\" 2>/dev/null || \\\n\tln -s \"git-remote-http\" \"$execdir/$p\" 2>/dev/null || \\\n\tcp \"$execdir/git-remote-http\" \"$execdir/$p\" || exit; \\\ndone && \\\n./check_bindir \"z$bindir\" \"z$execdir\" \"$bindir/git-add\"", "stdout_lines": ["    SUBDIR perl", "/usr/bin/perl Makefile.PL PREFIX='/usr' INSTALL_BASE='' --localedir='/usr/share/locale'", "    GEN git-add--interactive", "    GEN git-difftool", "    GEN git-archimport", "    GEN git-cvsexportcommit", "    GEN git-cvsimport", "    GEN git-cvsserver", "    GEN git-relink", "    GEN git-send-email", "    GEN git-svn", "    SUBDIR git-gui", "    SUBDIR gitk-git", "    SUBDIR perl", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Editor.pm >blib/lib/Git/SVN/Editor.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Migration.pm >blib/lib/Git/SVN/Migration.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Log.pm >blib/lib/Git/SVN/Log.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN.pm >blib/lib/Git/SVN.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Memoize/YAML.pm >blib/lib/Git/SVN/Memoize/YAML.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Ra.pm >blib/lib/Git/SVN/Ra.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/I18N.pm >blib/lib/Git/I18N.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Prompt.pm >blib/lib/Git/SVN/Prompt.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/GlobSpec.pm >blib/lib/Git/SVN/GlobSpec.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Fetcher.pm >blib/lib/Git/SVN/Fetcher.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/IndexInfo.pm >blib/lib/Git/IndexInfo.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git/SVN/Utils.pm >blib/lib/Git/SVN/Utils.pm", "/usr/bin/perl -pe \"s<\\Q++LOCALEDIR++\\E></usr/share/locale>\" <Git.pm >blib/lib/Git.pm", "    SUBDIR templates", "install -d -m 755 '/usr/bin'", "install -d -m 755 '/usr/libexec/git-core'", "install   git-credential-store git-daemon git-fast-import git-http-backend git-imap-send git-sh-i18n--envsubst git-shell git-show-index git-upload-pack git-remote-testsvn git-http-fetch git-http-push git-credential-cache git-credential-cache--daemon git-remote-http git-remote-https git-remote-ftp git-remote-ftps git-bisect git-difftool--helper git-filter-branch git-merge-octopus git-merge-one-file git-merge-resolve git-mergetool git-quiltimport git-rebase git-request-pull git-stash git-submodule git-web--browse git-add--interactive git-difftool git-archimport git-cvsexportcommit git-cvsimport git-cvsserver git-relink git-send-email git-svn git-p4 git-instaweb '/usr/libexec/git-core'", "install -m 644  git-mergetool--lib git-parse-remote git-rebase--am git-rebase--interactive git-rebase--merge git-sh-setup git-sh-i18n '/usr/libexec/git-core'", "install git git-upload-pack git-receive-pack git-upload-archive git-shell git-cvsserver '/usr/bin'", "make -C templates DESTDIR='' install", "make[1]: Entering directory `/root/git-2.9.3/templates'", "install -d -m 755 '/usr/share/git-core/templates'", "(cd blt && tar cf - .) | \\", "(cd '/usr/share/git-core/templates' && umask 022 && tar xof -)", "make[1]: Leaving directory `/root/git-2.9.3/templates'", "install -d -m 755 '/usr/libexec/git-core/mergetools'", "install -m 644 mergetools/* '/usr/libexec/git-core/mergetools'", "install -d -m 755 '/usr/share/locale'", "(cd po/build/locale && tar cf - .) | \\", "(cd '/usr/share/locale' && umask 022 && tar xof -)", "make -C perl prefix='/usr' DESTDIR='' install", "make[1]: Entering directory `/root/git-2.9.3/perl'", "make[2]: Entering directory `/root/git-2.9.3/perl'", "Installing /usr/share/perl5/Git.pm", "Installing /usr/share/perl5/Git/SVN.pm", "Installing /usr/share/perl5/Git/I18N.pm", "Installing /usr/share/perl5/Git/IndexInfo.pm", "Installing /usr/share/perl5/Git/SVN/Editor.pm", "Installing /usr/share/perl5/Git/SVN/Migration.pm", "Installing /usr/share/perl5/Git/SVN/Log.pm", "Installing /usr/share/perl5/Git/SVN/Ra.pm", "Installing /usr/share/perl5/Git/SVN/Prompt.pm", "Installing /usr/share/perl5/Git/SVN/GlobSpec.pm", "Installing /usr/share/perl5/Git/SVN/Fetcher.pm", "Installing /usr/share/perl5/Git/SVN/Utils.pm", "Installing /usr/share/perl5/Git/SVN/Memoize/YAML.pm", "Installing /usr/share/man/man3/Git::SVN::Editor.3pm", "Installing /usr/share/man/man3/Git::SVN::Memoize::YAML.3pm", "Installing /usr/share/man/man3/Git::SVN::Ra.3pm", "Installing /usr/share/man/man3/Git::I18N.3pm", "Installing /usr/share/man/man3/Git::SVN::Prompt.3pm", "Installing /usr/share/man/man3/Git::SVN::Fetcher.3pm", "Installing /usr/share/man/man3/Git::SVN::Utils.3pm", "Installing /usr/share/man/man3/Git.3pm", "Appending installation info to /usr/lib64/perl5/perllocal.pod", "make[2]: Leaving directory `/root/git-2.9.3/perl'", "make[1]: Leaving directory `/root/git-2.9.3/perl'", "make -C gitweb install", "make[1]: Entering directory `/root/git-2.9.3/gitweb'", "make[2]: Entering directory `/root/git-2.9.3'", "make[2]: `GIT-VERSION-FILE' is up to date.", "make[2]: Leaving directory `/root/git-2.9.3'", "    GEN gitweb.cgi", "    GEN static/gitweb.js", "install -d -m 755 '/usr/share/gitweb'", "install -m 755 gitweb.cgi '/usr/share/gitweb'", "install -d -m 755 '/usr/share/gitweb/static'", "install -m 644 static/gitweb.js static/gitweb.css static/git-logo.png static/git-favicon.png '/usr/share/gitweb/static'", "make[1]: Leaving directory `/root/git-2.9.3/gitweb'", "make -C gitk-git install", "make[1]: Entering directory `/root/git-2.9.3/gitk-git'", "install -m 755 gitk-wish '/usr/bin'/gitk", "install -d -m 755 '/usr/share/gitk/lib/msgs'", "install -m 644 po/de.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/ja.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/ca.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/sv.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/it.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/bg.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/fr.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/pt_br.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/ru.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/hu.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/vi.msg '/usr/share/gitk/lib/msgs' &&  install -m 644 po/es.msg '/usr/share/gitk/lib/msgs' && true", "make[1]: Leaving directory `/root/git-2.9.3/gitk-git'", "make -C git-gui gitexecdir='/usr/libexec/git-core' install", "make[1]: Entering directory `/root/git-2.9.3/git-gui'", "  DEST /usr/libexec/git-core", "    INSTALL 755 git-gui", "    INSTALL 755 git-gui--askpass", "    LINK        git-citool -> git-gui", "  DEST /usr/share/git-gui/lib", "    INSTALL 644 tclIndex", "    INSTALL 644 themed.tcl", "    INSTALL 644 line.tcl", "    INSTALL 644 console.tcl", "    INSTALL 644 checkout_op.tcl", "    INSTALL 644 transport.tcl", "    INSTALL 644 remote_add.tcl", "    INSTALL 644 browser.tcl", "    INSTALL 644 tools.tcl", "    INSTALL 644 branch_checkout.tcl", "    INSTALL 644 spellcheck.tcl", "    INSTALL 644 status_bar.tcl", "    INSTALL 644 diff.tcl", "    INSTALL 644 remote.tcl", "    INSTALL 644 choose_font.tcl", "    INSTALL 644 option.tcl", "    INSTALL 644 mergetool.tcl", "    INSTALL 644 tools_dlg.tcl", "    INSTALL 644 search.tcl", "    INSTALL 644 shortcut.tcl", "    INSTALL 644 branch_rename.tcl", "    INSTALL 644 class.tcl", "    INSTALL 644 remote_branch_delete.tcl", "    INSTALL 644 choose_repository.tcl", "    INSTALL 644 about.tcl", "    INSTALL 644 blame.tcl", "    INSTALL 644 branch.tcl", "    INSTALL 644 win32.tcl", "    INSTALL 644 sshkey.tcl", "    INSTALL 644 branch_create.tcl", "    INSTALL 644 commit.tcl", "    INSTALL 644 branch_delete.tcl", "    INSTALL 644 index.tcl", "    INSTALL 644 encoding.tcl", "    INSTALL 644 logo.tcl", "    INSTALL 644 date.tcl", "    INSTALL 644 choose_rev.tcl", "    INSTALL 644 database.tcl", "    INSTALL 644 error.tcl", "    INSTALL 644 merge.tcl", "    INSTALL 644 git-gui.ico", "    INSTALL 644 win32_shortcut.js", "  DEST /usr/share/git-gui/lib/msgs", "    INSTALL 644 pt_br.msg", "    INSTALL 644 hu.msg", "    INSTALL 644 zh_cn.msg", "    INSTALL 644 de.msg", "    INSTALL 644 ja.msg", "    INSTALL 644 sv.msg", "    INSTALL 644 it.msg", "    INSTALL 644 ru.msg", "    INSTALL 644 fr.msg", "    INSTALL 644 el.msg", "    INSTALL 644 vi.msg", "    INSTALL 644 bg.msg", "    INSTALL 644 nb.msg", "make[1]: Leaving directory `/root/git-2.9.3/git-gui'", "bindir=$(cd '/usr/bin' && pwd) && \\", "execdir=$(cd '/usr/libexec/git-core' && pwd) && \\", "{ test \"$bindir/\" = \"$execdir/\" || \\", "  for p in git git-shell git-upload-pack git-cvsserver; do \\", "\trm -f \"$execdir/$p\" && \\", "\ttest -z \"\" && \\", "\tln \"$bindir/$p\" \"$execdir/$p\" 2>/dev/null || \\", "\tcp \"$bindir/$p\" \"$execdir/$p\" || exit; \\", "  done; \\", "} && \\", "for p in git-receive-pack git-upload-archive; do \\", "\trm -f \"$bindir/$p\" && \\", "\ttest -z \"\" && \\", "\tln \"$bindir/git\" \"$bindir/$p\" 2>/dev/null || \\", "\tln -s \"git\" \"$bindir/$p\" 2>/dev/null || \\", "\tcp \"$bindir/git\" \"$bindir/$p\" || exit; \\", "done && \\", "for p in  git-add git-am git-annotate git-apply git-archive git-bisect--helper git-blame git-branch git-bundle git-cat-file git-check-attr git-check-ignore git-check-mailmap git-check-ref-format git-checkout-index git-checkout git-clean git-clone git-column git-commit-tree git-commit git-config git-count-objects git-credential git-describe git-diff-files git-diff-index git-diff-tree git-diff git-fast-export git-fetch-pack git-fetch git-fmt-merge-msg git-for-each-ref git-fsck git-gc git-get-tar-commit-id git-grep git-hash-object git-help git-index-pack git-init-db git-interpret-trailers git-log git-ls-files git-ls-remote git-ls-tree git-mailinfo git-mailsplit git-merge git-merge-base git-merge-file git-merge-index git-merge-ours git-merge-recursive git-merge-tree git-mktag git-mktree git-mv git-name-rev git-notes git-pack-objects git-pack-redundant git-pack-refs git-patch-id git-prune-packed git-prune git-pull git-push git-read-tree git-receive-pack git-reflog git-remote git-remote-ext git-remote-fd git-repack git-replace git-rerere git-reset git-rev-list git-rev-parse git-revert git-rm git-send-pack git-shortlog git-show-branch git-show-ref git-stripspace git-submodule--helper git-symbolic-ref git-tag git-unpack-file git-unpack-objects git-update-index git-update-ref git-update-server-info git-upload-archive git-var git-verify-commit git-verify-pack git-verify-tag git-worktree git-write-tree git-cherry git-cherry-pick git-format-patch git-fsck-objects git-init git-merge-subtree git-show git-stage git-status git-whatchanged; do \\", "\trm -f \"$execdir/$p\" && \\", "\ttest -z \"\" && \\", "\tln \"$execdir/git\" \"$execdir/$p\" 2>/dev/null || \\", "\tln -s \"git\" \"$execdir/$p\" 2>/dev/null || \\", "\tcp \"$execdir/git\" \"$execdir/$p\" || exit; \\", "done && \\", "remote_curl_aliases=\"git-remote-https git-remote-ftp git-remote-ftps\" && \\", "for p in $remote_curl_aliases; do \\", "\trm -f \"$execdir/$p\" && \\", "\ttest -z \"\" && \\", "\tln \"$execdir/git-remote-http\" \"$execdir/$p\" 2>/dev/null || \\", "\tln -s \"git-remote-http\" \"$execdir/$p\" 2>/dev/null || \\", "\tcp \"$execdir/git-remote-http\" \"$execdir/$p\" || exit; \\", "done && \\", "./check_bindir \"z$bindir\" \"z$execdir\" \"$bindir/git-add\""]}
    # 
    # TASK [srsp.oracle-java : precondition - java_version] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_subversion] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_install_jce] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_version": "1.8.0_192"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java architecture] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_arch": "x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Linux] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_os": "linux"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set rpm binary] *******************************************
    # ok: [atlassian1] => {"ansible_facts": {"use_dmg": false, "use_rpm": true, "use_tarball": false}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set tarball binary] ***************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set dmg binary] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 10] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 9.0.4] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_192] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_hash": "750e1c8617c5452694857ad95c3ee230", "jdk_version_detail": "8u192-b12"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_181] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_172] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_171] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_161] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_152] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_151] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_141] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_131] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_121] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_112] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_111] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for generic Java version] ***************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_file": "jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_url": "http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE zip file variables for java 8] ********************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_file": "jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE variables for java 8] *****************************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_folder": "UnlimitedJCEPolicyJDK8", "jce_zip_url": "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE download file] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Debian platforms] ******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Mac OS X] **************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on non-Debian platforms] ***
    # ok: [atlassian1] => {"ansible_facts": {"java_default_link_name": "default", "java_home": "/usr/java/default", "java_install_dir": "/usr/java"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : install libselinux-python binary for Ansible to work] *****
    # ok: [atlassian1] => {"changed": false, "msg": "", "rc": 0, "results": ["libselinux-python-2.5-12.el7.x86_64 providing libselinux-python is already installed"]}
    # 
    # TASK [srsp.oracle-java : copy scripts to server] ***********************************
    # ok: [atlassian1] => {"changed": false, "checksum": "2546647b60a8fffe888d8b73c924cfa0492c60b2", "dest": "/tmp/check-java-version.sh", "gid": 0, "group": "root", "mode": "0755", "owner": "root", "path": "/tmp/check-java-version.sh", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 416, "state": "file", "uid": 0}
    # 
    # TASK [srsp.oracle-java : check if specific version of Oracle JDK is installed?] ****
    # ok: [atlassian1] => {"changed": false, "cmd": "LC_ALL=\"en_US.UTF-8\" /tmp/check-java-version.sh \"1.8.0_192\"", "delta": "0:00:00.090828", "end": "2018-11-16 12:13:15.883687", "failed_when_result": false, "rc": 0, "start": "2018-11-16 12:13:15.792859", "stderr": "", "stderr_lines": [], "stdout": "{ \"found\": true  , \"not_found\": false }", "stdout_lines": ["{ \"found\": true  , \"not_found\": false }"]}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as RPM file)] ****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as tar.gz file)] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK package (as Mac OS X .dmg)] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy RPM from local] **************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy tarball from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy .dmg from local] *************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : uninstall messy packages to avoid blocking conditions] ****
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : delete messy .rpm files to avoid blocking conditions] *****
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with yum] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : symlink /usr/sbin/update-alternatives to /usr/sbin/alternatives] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if pkg already installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with rpm (for zypper)] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - uninstall messy packages] **********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - delete messy .rpm files] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for Java] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for specific Java version] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via tarball file] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mount the downloaded dmg] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install the pkg file from the dmg] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unmount the downloaded dmg] *******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : make sure /etc/profile.d exists] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : export JAVA_HOME] *****************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java"] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "javac"] ****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "jar"] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if "java_sdk" target exists] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java_sdk"] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded files, if requested] **********
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.rpm)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.rpm", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.tar.gz)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.tar.gz", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.dmg)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.dmg", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/check-tarball-installed.sh)  => {"changed": false, "item": "/tmp/check-tarball-installed.sh", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Mac] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Make sure 'which' is installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Linux] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Check if JCE is already installed] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JCE] **************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy JCE zip from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install unzip] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unzip JCE] ************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JCE policies] *************************************
    # skipping: [atlassian1] => (item=local_policy.jar)  => {"changed": false, "item": "local_policy.jar", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=US_export_policy.jar)  => {"changed": false, "item": "US_export_policy.jar", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded JCE files, if requested] ******
    # skipping: [atlassian1] => (item=/tmp/jce_policy-8.zip)  => {"changed": false, "item": "/tmp/jce_policy-8.zip", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/UnlimitedJCEPolicyJDK8)  => {"changed": false, "item": "/tmp/UnlimitedJCEPolicyJDK8", "skip_reason": "Conditional result was False"}
    # 
    # TASK [local.atlassian_bitbucket : download bitbucket installer] ********************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "cae3eab25a2febf978ba2a0ad2698cb1d9c385a4", "dest": "/tmp/atlassian-bitbucket-4.14.3-x64.bin", "gid": 0, "group": "root", "md5sum": "8f81b0d95697f0356e1aa5a8290b3dd1", "mode": "0754", "msg": "OK (272824891 bytes)", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 272824891, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542370401.29-46261533777126/tmpMi6Q2o", "state": "file", "status_code": 200, "uid": 0, "url": "https://downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-4.14.3-x64.bin"}
    # 
    # TASK [local.atlassian_bitbucket : create config file for silent install] ***********
    # changed: [atlassian1] => {"changed": true, "checksum": "6d65173bf5886c082385bb82429d237e9fa72a1a", "dest": "/tmp/bitbucket_installer.cfg", "gid": 0, "group": "root", "md5sum": "485355f3569fc650c17a7175a3339482", "mode": "0644", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 1100, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542370588.14-90449321380773/source", "state": "file", "uid": 0}
    # 
    # TASK [local.atlassian_bitbucket : ensure bitbucket service is stopped] *************
    #  [WARNING]: Consider using the service module rather than running service.  If you
    # need to use command because service is insufficient you can add warn=False to this
    # command task or set command_warnings=False in ansible.cfg to get rid of this
    # message.
    # fatal: [atlassian1]: FAILED! => {"changed": true, "cmd": ["service", "atlbitbucket", "stop"], "delta": "0:00:00.953438", "end": "2018-11-16 12:16:31.478992", "msg": "non-zero return code", "rc": 5, "start": "2018-11-16 12:16:30.525554", "stderr": "Redirecting to /bin/systemctl stop  atlbitbucket.service\nFailed to stop atlbitbucket.service: Unit atlbitbucket.service not loaded.", "stderr_lines": ["Redirecting to /bin/systemctl stop  atlbitbucket.service", "Failed to stop atlbitbucket.service: Unit atlbitbucket.service not loaded."], "stdout": "", "stdout_lines": []}
    # ...ignoring
    # 
    # TASK [local.atlassian_bitbucket : run installer] ***********************************
    # changed: [atlassian1] => {"changed": true, "cmd": "./atlassian-bitbucket-4.14.3-x64.bin -q -varfile ./bitbucket_installer.cfg", "delta": "0:00:44.496729", "end": "2018-11-16 12:17:16.575891", "failed_when_result": false, "rc": 0, "start": "2018-11-16 12:16:32.079162", "stderr": "", "stderr_lines": [], "stdout": "Starting Installer ...\nThe installation directory has been set to /opt/atlassian/bitbucket/4.14.3.\nExtracting files ...\nLaunching Bitbucket ...\nFinishing installation ...", "stdout_lines": ["Starting Installer ...", "The installation directory has been set to /opt/atlassian/bitbucket/4.14.3.", "Extracting files ...", "Launching Bitbucket ...", "Finishing installation ..."]}
    # 
    # TASK [local.atlassian_bitbucket : correct permissions] *****************************
    # ok: [atlassian1] => {"changed": false, "gid": 10003, "group": "atlbitbucket", "mode": "0755", "owner": "atlbitbucket", "path": "/srv/atlassian/bitbucket/shared", "secontext": "unconfined_u:object_r:var_t:s0", "size": 92, "state": "directory", "uid": 10003}
    # 
    # TASK [local.atlassian_bitbucket : Add proxy endpoint address to server.xml] ********
    # changed: [atlassian1] => {"changed": true, "checksum": "1058331fdabb430c60e44b524bf5684f9aa6c816", "dest": "/srv/atlassian/bitbucket/shared/server.xml", "gid": 10003, "group": "atlbitbucket", "md5sum": "12ebf18c69e6fb6c79c6d641bd09fb6d", "mode": "0674", "owner": "atlbitbucket", "secontext": "unconfined_u:object_r:var_t:s0", "size": 7694, "src": "/var/tmp/ansible-tmp-1542370638.47-227969870348929/source", "state": "file", "uid": 10003}
    # 
    # TASK [local.atlassian_bitbucket : add bitbucket configuration properties for automated setup] ***
    # changed: [atlassian1] => {"changed": true, "checksum": "a2223f315a9bb7744e52f0d60e95685615eceb5c", "dest": "/srv/atlassian/bitbucket/shared/bitbucket.properties", "gid": 10003, "group": "atlbitbucket", "md5sum": "8e4c5cfb36ab2d78bcc7d625eca32f5b", "mode": "0640", "owner": "atlbitbucket", "secontext": "system_u:object_r:var_t:s0", "size": 763, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542370640.11-246922442808059/source", "state": "file", "uid": 10003}
    # 
    # RUNNING HANDLER [local.atlassian_bitbucket : restart bitbucket] ********************
    # changed: [atlassian1] => {"changed": true, "cmd": ["service", "atlbitbucket", "restart"], "delta": "0:00:24.339026", "end": "2018-11-16 12:17:49.139005", "rc": 0, "start": "2018-11-16 12:17:24.799979", "stderr": "", "stderr_lines": [], "stdout": "Stopping Atlassian Bitbucket as dedicated user atlbitbucket\n\n\nBITBUCKET_HOME set to /srv/atlassian/bitbucket\n\n----------------------------------------------------------------------------------\nBitbucket is being run with a umask that contains potentially unsafe settings.\nThe following issues were found with the mask \"u=rwx,g=rwx,o=rx\" (0002):\n - access is allowed to 'others'. It is recommended that 'others' be denied\n   all access for security reasons.\n - write access is allowed to 'group'. It is recommend that 'group' be\n   denied write access. Read access to a restricted group is recommended\n   to allow access to the logs.\n\nThe recommended umask for Bitbucket is \"u=,g=w,o=rwx\" (0027) and can be\nconfigured in setenv.sh\n----------------------------------------------------------------------------------\nUsing BITBUCKET_HOME:      /srv/atlassian/bitbucket\nUsing CATALINA_BASE:   /opt/atlassian/bitbucket/4.14.3\nUsing CATALINA_HOME:   /opt/atlassian/bitbucket/4.14.3\nUsing CATALINA_TMPDIR: /opt/atlassian/bitbucket/4.14.3/temp\nUsing JRE_HOME:        /usr/java/jdk1.8.0_192-amd64/jre\nUsing CLASSPATH:       /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/bitbucket/4.14.3/work/catalina.pid\nTomcat stopped.\nStopped Atlassian Bitbucket at http://localhost:7990/\nTo run Bitbucket in the foreground, start the server with start-bitbucket.sh -fg\nThe current open files limit is set to less than 4096 \nAttempting to increase limit...\nLimit increased to 4096 open files\nStarting Atlassian Bitbucket as dedicated user atlbitbucket \n\nBITBUCKET_HOME set to /srv/atlassian/bitbucket\n\n----------------------------------------------------------------------------------\nBitbucket is being run with a umask that contains potentially unsafe settings.\nThe following issues were found with the mask \"u=rwx,g=rwx,o=rx\" (0002):\n - access is allowed to 'others'. It is recommended that 'others' be denied\n   all access for security reasons.\n - write access is allowed to 'group'. It is recommend that 'group' be\n   denied write access. Read access to a restricted group is recommended\n   to allow access to the logs.\n\nThe recommended umask for Bitbucket is \"u=,g=w,o=rwx\" (0027) and can be\nconfigured in setenv.sh\n----------------------------------------------------------------------------------\nUsing BITBUCKET_HOME:      /srv/atlassian/bitbucket\nUsing CATALINA_BASE:   /opt/atlassian/bitbucket/4.14.3\nUsing CATALINA_HOME:   /opt/atlassian/bitbucket/4.14.3\nUsing CATALINA_TMPDIR: /opt/atlassian/bitbucket/4.14.3/temp\nUsing JRE_HOME:        /usr/java/jdk1.8.0_192-amd64/jre\nUsing CLASSPATH:       /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/bitbucket/4.14.3/work/catalina.pid\nTomcat started.\n\nSuccess! You can now use Bitbucket at the following address:\n\nhttp://localhost:7990/\n\nIf you cannot access Bitbucket at the above location within 3 minutes, or encounter any other issues starting or stopping Atlassian Bitbucket, please see the troubleshooting guide at:\n\nhttps://confluence.atlassian.com/display/BitbucketServerKB/Troubleshooting+Installation", "stdout_lines": ["Stopping Atlassian Bitbucket as dedicated user atlbitbucket", "", "", "BITBUCKET_HOME set to /srv/atlassian/bitbucket", "", "----------------------------------------------------------------------------------", "Bitbucket is being run with a umask that contains potentially unsafe settings.", "The following issues were found with the mask \"u=rwx,g=rwx,o=rx\" (0002):", " - access is allowed to 'others'. It is recommended that 'others' be denied", "   all access for security reasons.", " - write access is allowed to 'group'. It is recommend that 'group' be", "   denied write access. Read access to a restricted group is recommended", "   to allow access to the logs.", "", "The recommended umask for Bitbucket is \"u=,g=w,o=rwx\" (0027) and can be", "configured in setenv.sh", "----------------------------------------------------------------------------------", "Using BITBUCKET_HOME:      /srv/atlassian/bitbucket", "Using CATALINA_BASE:   /opt/atlassian/bitbucket/4.14.3", "Using CATALINA_HOME:   /opt/atlassian/bitbucket/4.14.3", "Using CATALINA_TMPDIR: /opt/atlassian/bitbucket/4.14.3/temp", "Using JRE_HOME:        /usr/java/jdk1.8.0_192-amd64/jre", "Using CLASSPATH:       /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/bitbucket/4.14.3/work/catalina.pid", "Tomcat stopped.", "Stopped Atlassian Bitbucket at http://localhost:7990/", "To run Bitbucket in the foreground, start the server with start-bitbucket.sh -fg", "The current open files limit is set to less than 4096 ", "Attempting to increase limit...", "Limit increased to 4096 open files", "Starting Atlassian Bitbucket as dedicated user atlbitbucket ", "", "BITBUCKET_HOME set to /srv/atlassian/bitbucket", "", "----------------------------------------------------------------------------------", "Bitbucket is being run with a umask that contains potentially unsafe settings.", "The following issues were found with the mask \"u=rwx,g=rwx,o=rx\" (0002):", " - access is allowed to 'others'. It is recommended that 'others' be denied", "   all access for security reasons.", " - write access is allowed to 'group'. It is recommend that 'group' be", "   denied write access. Read access to a restricted group is recommended", "   to allow access to the logs.", "", "The recommended umask for Bitbucket is \"u=,g=w,o=rwx\" (0027) and can be", "configured in setenv.sh", "----------------------------------------------------------------------------------", "Using BITBUCKET_HOME:      /srv/atlassian/bitbucket", "Using CATALINA_BASE:   /opt/atlassian/bitbucket/4.14.3", "Using CATALINA_HOME:   /opt/atlassian/bitbucket/4.14.3", "Using CATALINA_TMPDIR: /opt/atlassian/bitbucket/4.14.3/temp", "Using JRE_HOME:        /usr/java/jdk1.8.0_192-amd64/jre", "Using CLASSPATH:       /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/bitbucket/4.14.3/work/catalina.pid", "Tomcat started.", "", "Success! You can now use Bitbucket at the following address:", "", "http://localhost:7990/", "", "If you cannot access Bitbucket at the above location within 3 minutes, or encounter any other issues starting or stopping Atlassian Bitbucket, please see the troubleshooting guide at:", "", "https://confluence.atlassian.com/display/BitbucketServerKB/Troubleshooting+Installation"]}
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=28   changed=11   unreachable=0    failed=0   


<a id="org300180d"></a>

#### Run Configuration Wizard

<http://192.168.56.31:7990>

Be patient. First time accessing this page takes some time.

On the configuration page you have the possibility to define the application
name, the base URL and to get an evaluation license or enter a valid license. If
you choose **I need an evaluation license** you can retrieve it from the my
atlassian page. Click on **I have an account**.

You will be redirected automatically.

Please confirm that you wish to install the license key on the following server:
192.168.56.31

Click on **Yes**

Click on **Next**

After adding the license you have to create a local Bitbucket administrator
account.

    Username: vzell
    Full name: Volker Zell
    Email address: volker.zell@opitz-consulting.com
    Password: opendevstack
    Confirm password: opendevstack

**Don’t** integrate Bitbucket with Jira at this point, but proceed with
**Go to Bitbucket**.


<a id="org201ec46"></a>

#### Configure Crowd access

If not already redirected, go to the Bitbucket start page at
<http://192.168.56.31:7990/>. Open the **Administration** settings and navigate to
the **User Directories** menu. Click on **Add Directory**, here you have to add a
directory of type **Atlassian Crowd**. Click **Next**. Here you have to add:

Name: Crowd Server
Crowd Server URL: <http://192.168.56.31:8095/crowd> 
Application Name: bitbucket
Application Password: bitbucket

These are the application name and the password you have defined for Bitbucket
in crowd. For the local test environment this is bitbucket bitbucket. Now
activate nested groups and deactivate the incremental synchronization:

[x] Enable Nested Groups
[ ] Enable Incremental Synchronisation

The group membership should be proofed every time a user logs in. Click on **Test
Settings** and after a successfull test click on **Save and Test**. 

Now change the **order** of the user directories. The **Crowd directory** has to be on
**first position**.


<a id="org4949221"></a>

#### Configure user groups

-   Add groups

    After configuring the crowd directory change to **Groups**. Here you have to add
    the groups defined in crowd in the previous steps, if they are not available
    yet.
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <thead>
    <tr>
    <th scope="col" class="org-left">Group</th>
    <th scope="col" class="org-left">Description</th>
    </tr>
    </thead>
    
    <tbody>
    <tr>
    <td class="org-left">bitbucket-administrators</td>
    <td class="org-left">Bitbucket administrator group</td>
    </tr>
    
    
    <tr>
    <td class="org-left">bitbucket-users</td>
    <td class="org-left">Bitbucket user group</td>
    </tr>
    </tbody>
    </table>

-   Add permissions

    The last step is to configure the permissions for the created groups. Go to the
    **Global permissions** menu. In the **Group access** section add the
    **bitbucket-administrators** group with **System Admin** rights and the
    **bitbucket-users** group with **Project Creator** rights. Do this by start typing
    in the **Add Groups** input form and after completion by clicking on the **Add** button.


<a id="orgca2cfb3"></a>

### Jira Setup


<a id="orgf23b7e9"></a>

#### Setup Application

    ansible-playbook -v -i inventories/dev playbooks/jira.yml --ask-vault
    opendevstack

    # Using /vagrant/ansible/ansible.cfg as config file
    # Vault password: opendevstack
    # 
    # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
    # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
    # [DEPRECATION WARNING]: The use of 'static' has been deprecated. Use 'import_tasks' 
    # for static inclusion, or 'include_tasks' for dynamic inclusion. This feature will 
    # be removed in version 2.12. Deprecation warnings can be disabled by setting 
    # deprecation_warnings=False in ansible.cfg.
    # 
    # PLAY [tag_hostgroup_jira_test] *****************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [srsp.oracle-java : precondition - java_version] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_subversion] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_install_jce] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_version": "1.8.0_192"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java architecture] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_arch": "x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Linux] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_os": "linux"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set rpm binary] *******************************************
    # ok: [atlassian1] => {"ansible_facts": {"use_dmg": false, "use_rpm": true, "use_tarball": false}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set tarball binary] ***************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set dmg binary] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 10] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 9.0.4] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_192] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_hash": "750e1c8617c5452694857ad95c3ee230", "jdk_version_detail": "8u192-b12"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_181] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_172] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_171] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_161] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_152] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_151] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_141] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_131] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_121] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_112] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_111] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for generic Java version] ***************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_file": "jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_url": "http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE zip file variables for java 8] ********************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_file": "jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE variables for java 8] *****************************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_folder": "UnlimitedJCEPolicyJDK8", "jce_zip_url": "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE download file] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Debian platforms] ******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Mac OS X] **************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on non-Debian platforms] ***
    # ok: [atlassian1] => {"ansible_facts": {"java_default_link_name": "default", "java_home": "/usr/java/default", "java_install_dir": "/usr/java"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : install libselinux-python binary for Ansible to work] *****
    # ok: [atlassian1] => {"changed": false, "msg": "", "rc": 0, "results": ["libselinux-python-2.5-12.el7.x86_64 providing libselinux-python is already installed"]}
    # 
    # TASK [srsp.oracle-java : copy scripts to server] ***********************************
    # ok: [atlassian1] => {"changed": false, "checksum": "2546647b60a8fffe888d8b73c924cfa0492c60b2", "dest": "/tmp/check-java-version.sh", "gid": 0, "group": "root", "mode": "0755", "owner": "root", "path": "/tmp/check-java-version.sh", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 416, "state": "file", "uid": 0}
    # 
    # TASK [srsp.oracle-java : check if specific version of Oracle JDK is installed?] ****
    # ok: [atlassian1] => {"changed": false, "cmd": "LC_ALL=\"en_US.UTF-8\" /tmp/check-java-version.sh \"1.8.0_192\"", "delta": "0:00:00.100977", "end": "2018-11-16 13:37:22.806570", "failed_when_result": false, "rc": 0, "start": "2018-11-16 13:37:22.705593", "stderr": "", "stderr_lines": [], "stdout": "{ \"found\": true  , \"not_found\": false }", "stdout_lines": ["{ \"found\": true  , \"not_found\": false }"]}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as RPM file)] ****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as tar.gz file)] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK package (as Mac OS X .dmg)] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy RPM from local] **************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy tarball from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy .dmg from local] *************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : uninstall messy packages to avoid blocking conditions] ****
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : delete messy .rpm files to avoid blocking conditions] *****
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with yum] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : symlink /usr/sbin/update-alternatives to /usr/sbin/alternatives] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if pkg already installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with rpm (for zypper)] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - uninstall messy packages] **********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - delete messy .rpm files] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for Java] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for specific Java version] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via tarball file] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mount the downloaded dmg] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install the pkg file from the dmg] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unmount the downloaded dmg] *******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : make sure /etc/profile.d exists] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : export JAVA_HOME] *****************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java"] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "javac"] ****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "jar"] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if "java_sdk" target exists] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java_sdk"] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded files, if requested] **********
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.rpm)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.rpm", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.tar.gz)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.tar.gz", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.dmg)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.dmg", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/check-tarball-installed.sh)  => {"changed": false, "item": "/tmp/check-tarball-installed.sh", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Mac] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Make sure 'which' is installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Linux] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Check if JCE is already installed] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JCE] **************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy JCE zip from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install unzip] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unzip JCE] ************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JCE policies] *************************************
    # skipping: [atlassian1] => (item=local_policy.jar)  => {"changed": false, "item": "local_policy.jar", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=US_export_policy.jar)  => {"changed": false, "item": "US_export_policy.jar", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded JCE files, if requested] ******
    # skipping: [atlassian1] => (item=/tmp/jce_policy-8.zip)  => {"changed": false, "item": "/tmp/jce_policy-8.zip", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/UnlimitedJCEPolicyJDK8)  => {"changed": false, "item": "/tmp/UnlimitedJCEPolicyJDK8", "skip_reason": "Conditional result was False"}
    # 
    # TASK [local.atlassian_jira : download jira installer] ******************************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "ecd57c7a2c3b98f3eeebbfcddba99e9fdb7ad9d4", "dest": "/tmp/atlassian-jira-software-7.3.6-x64.bin", "gid": 0, "group": "root", "md5sum": "811cf4c70857bfc4c56532bbd7d2d074", "mode": "0754", "msg": "OK (323764139 bytes)", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 323764139, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542375447.91-274808372825003/tmpQKowV2", "state": "file", "status_code": 200, "uid": 0, "url": "https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.3.6-x64.bin"}
    # 
    # TASK [local.atlassian_jira : create config file for silent install] ****************
    # changed: [atlassian1] => {"changed": true, "checksum": "079d6eaaa6f0c674f1360946efce88ab3949479a", "dest": "/tmp/jira_installer.cfg", "gid": 0, "group": "root", "md5sum": "93cacd88d11339f44a9edfdec7bf09ab", "mode": "0644", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 415, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542375540.01-209560744420320/source", "state": "file", "uid": 0}
    # 
    # TASK [local.atlassian_jira : run installer] ****************************************
    # changed: [atlassian1] => {"changed": true, "cmd": "./atlassian-jira-software-7.3.6-x64.bin -q -varfile ./jira_installer.cfg", "delta": "0:01:07.266136", "end": "2018-11-16 13:40:08.700623", "failed_when_result": false, "rc": 0, "start": "2018-11-16 13:39:01.434487", "stderr": "Nov 16, 2018 1:40:08 PM com.atlassian.modzdetector.HashRegistry store\nINFO: wrote 991 hashes to /opt/atlassian/jira/install.reg", "stderr_lines": ["Nov 16, 2018 1:40:08 PM com.atlassian.modzdetector.HashRegistry store", "INFO: wrote 991 hashes to /opt/atlassian/jira/install.reg"], "stdout": "Unpacking JRE ...\nStarting Installer ...\n\u001b[?7hExtracting files ...\nLaunching JIRA Software ...\nFinishing installation ...", "stdout_lines": ["Unpacking JRE ...", "Starting Installer ...", "\u001b[?7hExtracting files ...", "Launching JIRA Software ...", "Finishing installation ..."]}
    # 
    # TASK [local.atlassian_jira : Add proxy endpoint address to server.xml] *************
    # changed: [atlassian1] => {"changed": true, "checksum": "7b6e6537aa76b970a890023d0b7b4f291a638430", "dest": "/opt/atlassian/jira/conf/server.xml", "gid": 0, "group": "root", "md5sum": "d1b5bb58788536b43e5ce22916c32d96", "mode": "0644", "owner": "root", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 8049, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542375609.02-18136810047261/source", "state": "file", "uid": 0}
    # 
    # TASK [local.atlassian_jira : configure database] ***********************************
    # changed: [atlassian1] => {"changed": true, "checksum": "64e098ef4276446ca2bf6b7d911501602404c8ad", "dest": "/srv/atlassian/jira/dbconfig.xml", "gid": 10004, "group": "jira", "md5sum": "fb6490a1d858a397d1725cb3213acb7e", "mode": "0600", "owner": "jira", "secontext": "system_u:object_r:var_t:s0", "size": 1043, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542375612.9-172861185636795/source", "state": "file", "uid": 10004}
    # 
    # TASK [local.atlassian_jira : include] **********************************************
    # included: /vagrant/ansible/roles/local.atlassian_jira/tasks/configure-eazybi.yml for atlassian1
    # 
    # TASK [local.atlassian_jira : manipulate JVM max memory and file encoding for jira] ***
    # changed: [atlassian1] => (item={u'key': u'JVM_MAXIMUM_MEMORY', u'value': u'4096m'}) => {"backup": "", "changed": true, "item": {"key": "JVM_MAXIMUM_MEMORY", "value": "4096m"}, "msg": "line replaced"}
    # changed: [atlassian1] => (item={u'key': u'JVM_SUPPORT_RECOMMENDED_ARGS', u'value': u'-Dfile.encoding=UTF-8'}) => {"backup": "", "changed": true, "item": {"key": "JVM_SUPPORT_RECOMMENDED_ARGS", "value": "-Dfile.encoding=UTF-8"}, "msg": "line replaced"}
    # 
    # RUNNING HANDLER [local.atlassian_jira : stop jira] *********************************
    #  [WARNING]: Consider using the service module rather than running service.  If you
    # need to use command because service is insufficient you can add warn=False to this
    # command task or set command_warnings=False in ansible.cfg to get rid of this
    # message.
    # changed: [atlassian1] => {"changed": true, "cmd": ["service", "jira", "stop"], "delta": "0:00:22.221498", "end": "2018-11-16 13:40:37.870908", "rc": 0, "start": "2018-11-16 13:40:15.649410", "stderr": "", "stderr_lines": [], "stdout": "executing using dedicated user\n                .....\r\n          .... .NMMMD.  ...\r\n        .8MMM.  $MMN,..~MMMO.\r\n        .?MMM.         .MMM?.\r\n\r\n     OMMMMZ.           .,NMMMN~\r\n     .IMMMMMM. .NMMMN. .MMMMMN,\r\n       ,MMMMMM$..3MD..ZMMMMMM.\r\n        =NMMMMMM,. .,MMMMMMD.\r\n         .MMMMMMMM8MMMMMMM,\r\n           .ONMMMMMMMMMMZ.\r\n             ,NMMMMMMM8.\r\n            .:,.$MMMMMMM\r\n          .IMMMM..NMMMMMD.\r\n         .8MMMMM:  :NMMMMN.\r\n         .MMMMMM.   .MMMMM~.\r\n         .MMMMMN    .MMMMM?.\r\n\r\n      Atlassian JIRA\r\n      Version : 7.3.6\r\n                  \r\n\nIf you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide\n\n\nServer startup logs are located in /opt/atlassian/jira/logs/catalina.out\nUsing CATALINA_BASE:   /opt/atlassian/jira\nUsing CATALINA_HOME:   /opt/atlassian/jira\nUsing CATALINA_TMPDIR: /opt/atlassian/jira/temp\nUsing JRE_HOME:        /opt/atlassian/jira/jre/\nUsing CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid\nTomcat did not stop in time.\nTo aid diagnostics a thread dump has been written to standard out.\nKilling Tomcat with the PID: 8520\nThe Tomcat process has been killed.", "stdout_lines": ["executing using dedicated user", "                .....", "          .... .NMMMD.  ...", "        .8MMM.  $MMN,..~MMMO.", "        .?MMM.         .MMM?.", "", "     OMMMMZ.           .,NMMMN~", "     .IMMMMMM. .NMMMN. .MMMMMN,", "       ,MMMMMM$..3MD..ZMMMMMM.", "        =NMMMMMM,. .,MMMMMMD.", "         .MMMMMMMM8MMMMMMM,", "           .ONMMMMMMMMMMZ.", "             ,NMMMMMMM8.", "            .:,.$MMMMMMM", "          .IMMMM..NMMMMMD.", "         .8MMMMM:  :NMMMMN.", "         .MMMMMM.   .MMMMM~.", "         .MMMMMN    .MMMMM?.", "", "      Atlassian JIRA", "      Version : 7.3.6", "                  ", "", "If you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide", "", "", "Server startup logs are located in /opt/atlassian/jira/logs/catalina.out", "Using CATALINA_BASE:   /opt/atlassian/jira", "Using CATALINA_HOME:   /opt/atlassian/jira", "Using CATALINA_TMPDIR: /opt/atlassian/jira/temp", "Using JRE_HOME:        /opt/atlassian/jira/jre/", "Using CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid", "Tomcat did not stop in time.", "To aid diagnostics a thread dump has been written to standard out.", "Killing Tomcat with the PID: 8520", "The Tomcat process has been killed."]}
    # 
    # RUNNING HANDLER [local.atlassian_jira : start jira] ********************************
    # changed: [atlassian1] => {"changed": true, "cmd": ["service", "jira", "start"], "delta": "0:00:00.352101", "end": "2018-11-16 13:40:38.829206", "rc": 0, "start": "2018-11-16 13:40:38.477105", "stderr": "", "stderr_lines": [], "stdout": "\nTo run JIRA in the foreground, start the server with start-jira.sh -fg\nexecuting using dedicated user: jira\n                .....\r\n          .... .NMMMD.  ...\r\n        .8MMM.  $MMN,..~MMMO.\r\n        .?MMM.         .MMM?.\r\n\r\n     OMMMMZ.           .,NMMMN~\r\n     .IMMMMMM. .NMMMN. .MMMMMN,\r\n       ,MMMMMM$..3MD..ZMMMMMM.\r\n        =NMMMMMM,. .,MMMMMMD.\r\n         .MMMMMMMM8MMMMMMM,\r\n           .ONMMMMMMMMMMZ.\r\n             ,NMMMMMMM8.\r\n            .:,.$MMMMMMM\r\n          .IMMMM..NMMMMMD.\r\n         .8MMMMM:  :NMMMMN.\r\n         .MMMMMM.   .MMMMM~.\r\n         .MMMMMN    .MMMMM?.\r\n\r\n      Atlassian JIRA\r\n      Version : 7.3.6\r\n                  \r\n\nIf you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide\n\n\nServer startup logs are located in /opt/atlassian/jira/logs/catalina.out\nUsing CATALINA_BASE:   /opt/atlassian/jira\nUsing CATALINA_HOME:   /opt/atlassian/jira\nUsing CATALINA_TMPDIR: /opt/atlassian/jira/temp\nUsing JRE_HOME:        /opt/atlassian/jira/jre/\nUsing CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid\nTomcat started.", "stdout_lines": ["", "To run JIRA in the foreground, start the server with start-jira.sh -fg", "executing using dedicated user: jira", "                .....", "          .... .NMMMD.  ...", "        .8MMM.  $MMN,..~MMMO.", "        .?MMM.         .MMM?.", "", "     OMMMMZ.           .,NMMMN~", "     .IMMMMMM. .NMMMN. .MMMMMN,", "       ,MMMMMM$..3MD..ZMMMMMM.", "        =NMMMMMM,. .,MMMMMMD.", "         .MMMMMMMM8MMMMMMM,", "           .ONMMMMMMMMMMZ.", "             ,NMMMMMMM8.", "            .:,.$MMMMMMM", "          .IMMMM..NMMMMMD.", "         .8MMMMM:  :NMMMMN.", "         .MMMMMM.   .MMMMM~.", "         .MMMMMN    .MMMMM?.", "", "      Atlassian JIRA", "      Version : 7.3.6", "                  ", "", "If you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide", "", "", "Server startup logs are located in /opt/atlassian/jira/logs/catalina.out", "Using CATALINA_BASE:   /opt/atlassian/jira", "Using CATALINA_HOME:   /opt/atlassian/jira", "Using CATALINA_TMPDIR: /opt/atlassian/jira/temp", "Using JRE_HOME:        /opt/atlassian/jira/jre/", "Using CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid", "Tomcat started."]}
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=23   changed=8    unreachable=0    failed=0   


<a id="org8de5782"></a>

#### Run Configuration Wizard

<http://192.168.56.31:8080>

Be patient. First time accessing this page takes time.


<a id="org0a3ded7"></a>

#### Setup application properties

Here you have to choose the application title and the base URL. You can leave
the data as is for the test environment.


<a id="org6dab2f4"></a>

#### Specify your license key

Here you have to enter the license key for the Jira instance (Jira Software
(Server)). With the provided link **generate a JIRA trial license** in the
dialogue you are able to generate an evaluation license at Atlassian.

You will be redirected automatically.

Please confirm that you wish to install the license key on the following server:
192.168.56.31

Click on **Yes**

Click on **Next**


<a id="org7fb891f"></a>

#### Set up administrator account

Now you have to set up a Jira administrator account.

    Full name: Volker Zell
    Email address: volker.zell@opitz-consulting.com
    Username: vzell
    Password: opendevstack
    Confirm password: opendevstack

Click **Next**


<a id="org54cfea4"></a>

#### Set up email notifications

Unless you have configured a mail server, choose **Later** and click on **Finish**.


<a id="org0f6f267"></a>

#### Basic configuration

To finish this part of the Jira installation, you will have to provide some
informations to your prefered language, your avatar and you will have to create
an empty or a sample project. 

(o) English (United States) [Default]
**Choose an avatar** 

After these basic configurations, you have access
to the Jira board.


<a id="org2738219"></a>

#### Configure Crowd access

-   Configure user directory

    Open the **Jira administration** page
    
    <http://192.168.56.31:8080/secure/admin>
    
    Enter your admin user and credentials.
    
    Open the **User management** in the Jira administration. To enter the
    administration, you have to verify you have admin rights with the password for
    your admin user. Click the **User Directories** entry at the left. Now choose **Add
    Directory**. Here you have to add a directory of type **Atlassian Crowd**. Here you
    have to add the Crowd server URL <http://192.168.56.31:8095/crowd>. You also have
    to add the application name and the password you have defined for Jira in
    crowd. For the local test environment this is jira jira. Now activate nested
    groups and deactivate the incremental synchronization. The group membership
    should be proofed every time a user logs in. Test the settings and save
    them. Now change the order of the user directories. The Crowd directory has to
    be on first position.

-   Configure SSO with crowd

    To finish the SSO configuration, you will have to run the following playbook command:
    
        ansible-playbook -v -i inventories/dev playbooks/jira_enable_sso.yml --ask-vault
        opendevstack
    
        # Using /vagrant/ansible/ansible.cfg as config file
        # Vault password: opendevstack
        # 
        # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
        # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
        # 
        # PLAY [tag_hostgroup_jira_test] *****************************************************
        # 
        # TASK [Gathering Facts] *************************************************************
        # ok: [atlassian1]
        # 
        # TASK [remove CROWD comments] *******************************************************
        #  [WARNING]: Consider using the replace, lineinfile or template module rather than
        # running sed.  If you need to use command because replace, lineinfile or template is
        # insufficient you can add warn=False to this command task or set
        # command_warnings=False in ansible.cfg to get rid of this message.
        # changed: [atlassian1] => {"changed": true, "cmd": ["sed", "-i.orig", "-e", "/<!-- CROWD:START/,/<!-- CROWD:END/d", "/opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml"], "delta": "0:00:00.131696", "end": "2018-11-16 14:54:30.754820", "rc": 0, "start": "2018-11-16 14:54:30.623124", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
        # 
        # TASK [ensure we have the SSO authenticator enabled] ********************************
        # changed: [atlassian1] => {"backup": "/opt/atlassian/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml.26145.2018-11-16@14:54:32~", "changed": true, "msg": "line added"}
        # 
        # TASK [create crowd.properties files] ***********************************************
        # changed: [atlassian1] => {"changed": true, "checksum": "2f99022d35f418f5780a7a8513d89253c1b462a0", "dest": "/opt/atlassian/jira/atlassian-jira/WEB-INF/classes/crowd.properties", "gid": 0, "group": "root", "md5sum": "1e2f16d010335873d5dfa89b57d0ea34", "mode": "0644", "owner": "root", "secontext": "system_u:object_r:usr_t:s0", "size": 298, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542380072.78-22407249811668/source", "state": "file", "uid": 0}
        # 
        # RUNNING HANDLER [stop jira] ********************************************************
        #  [WARNING]: Consider using the service module rather than running service.  If you
        # need to use command because service is insufficient you can add warn=False to this
        # command task or set command_warnings=False in ansible.cfg to get rid of this
        # message.
        # changed: [atlassian1] => {"changed": true, "cmd": ["service", "jira", "stop"], "delta": "0:00:30.558704", "end": "2018-11-16 14:55:07.797674", "rc": 0, "start": "2018-11-16 14:54:37.238970", "stderr": "", "stderr_lines": [], "stdout": "executing using dedicated user\n                .....\r\n          .... .NMMMD.  ...\r\n        .8MMM.  $MMN,..~MMMO.\r\n        .?MMM.         .MMM?.\r\n\r\n     OMMMMZ.           .,NMMMN~\r\n     .IMMMMMM. .NMMMN. .MMMMMN,\r\n       ,MMMMMM$..3MD..ZMMMMMM.\r\n        =NMMMMMM,. .,MMMMMMD.\r\n         .MMMMMMMM8MMMMMMM,\r\n           .ONMMMMMMMMMMZ.\r\n             ,NMMMMMMM8.\r\n            .:,.$MMMMMMM\r\n          .IMMMM..NMMMMMD.\r\n         .8MMMMM:  :NMMMMN.\r\n         .MMMMMM.   .MMMMM~.\r\n         .MMMMMN    .MMMMM?.\r\n\r\n      Atlassian JIRA\r\n      Version : 7.3.6\r\n                  \r\n\nIf you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide\n\n\nServer startup logs are located in /opt/atlassian/jira/logs/catalina.out\nUsing CATALINA_BASE:   /opt/atlassian/jira\nUsing CATALINA_HOME:   /opt/atlassian/jira\nUsing CATALINA_TMPDIR: /opt/atlassian/jira/temp\nUsing JRE_HOME:        /opt/atlassian/jira/jre/\nUsing CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid\nTomcat did not stop in time.\nTo aid diagnostics a thread dump has been written to standard out.\nKilling Tomcat with the PID: 9306\nThe Tomcat process has been killed.", "stdout_lines": ["executing using dedicated user", "                .....", "          .... .NMMMD.  ...", "        .8MMM.  $MMN,..~MMMO.", "        .?MMM.         .MMM?.", "", "     OMMMMZ.           .,NMMMN~", "     .IMMMMMM. .NMMMN. .MMMMMN,", "       ,MMMMMM$..3MD..ZMMMMMM.", "        =NMMMMMM,. .,MMMMMMD.", "         .MMMMMMMM8MMMMMMM,", "           .ONMMMMMMMMMMZ.", "             ,NMMMMMMM8.", "            .:,.$MMMMMMM", "          .IMMMM..NMMMMMD.", "         .8MMMMM:  :NMMMMN.", "         .MMMMMM.   .MMMMM~.", "         .MMMMMN    .MMMMM?.", "", "      Atlassian JIRA", "      Version : 7.3.6", "                  ", "", "If you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide", "", "", "Server startup logs are located in /opt/atlassian/jira/logs/catalina.out", "Using CATALINA_BASE:   /opt/atlassian/jira", "Using CATALINA_HOME:   /opt/atlassian/jira", "Using CATALINA_TMPDIR: /opt/atlassian/jira/temp", "Using JRE_HOME:        /opt/atlassian/jira/jre/", "Using CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid", "Tomcat did not stop in time.", "To aid diagnostics a thread dump has been written to standard out.", "Killing Tomcat with the PID: 9306", "The Tomcat process has been killed."]}
        # 
        # RUNNING HANDLER [start jira] *******************************************************
        # changed: [atlassian1] => {"changed": true, "cmd": ["service", "jira", "start"], "delta": "0:00:01.279723", "end": "2018-11-16 14:55:11.198744", "rc": 0, "start": "2018-11-16 14:55:09.919021", "stderr": "", "stderr_lines": [], "stdout": "\nTo run JIRA in the foreground, start the server with start-jira.sh -fg\nexecuting using dedicated user: jira\n                .....\r\n          .... .NMMMD.  ...\r\n        .8MMM.  $MMN,..~MMMO.\r\n        .?MMM.         .MMM?.\r\n\r\n     OMMMMZ.           .,NMMMN~\r\n     .IMMMMMM. .NMMMN. .MMMMMN,\r\n       ,MMMMMM$..3MD..ZMMMMMM.\r\n        =NMMMMMM,. .,MMMMMMD.\r\n         .MMMMMMMM8MMMMMMM,\r\n           .ONMMMMMMMMMMZ.\r\n             ,NMMMMMMM8.\r\n            .:,.$MMMMMMM\r\n          .IMMMM..NMMMMMD.\r\n         .8MMMMM:  :NMMMMN.\r\n         .MMMMMM.   .MMMMM~.\r\n         .MMMMMN    .MMMMM?.\r\n\r\n      Atlassian JIRA\r\n      Version : 7.3.6\r\n                  \r\n\nIf you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide\n\n\nServer startup logs are located in /opt/atlassian/jira/logs/catalina.out\nUsing CATALINA_BASE:   /opt/atlassian/jira\nUsing CATALINA_HOME:   /opt/atlassian/jira\nUsing CATALINA_TMPDIR: /opt/atlassian/jira/temp\nUsing JRE_HOME:        /opt/atlassian/jira/jre/\nUsing CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid\nTomcat started.", "stdout_lines": ["", "To run JIRA in the foreground, start the server with start-jira.sh -fg", "executing using dedicated user: jira", "                .....", "          .... .NMMMD.  ...", "        .8MMM.  $MMN,..~MMMO.", "        .?MMM.         .MMM?.", "", "     OMMMMZ.           .,NMMMN~", "     .IMMMMMM. .NMMMN. .MMMMMN,", "       ,MMMMMM$..3MD..ZMMMMMM.", "        =NMMMMMM,. .,MMMMMMD.", "         .MMMMMMMM8MMMMMMM,", "           .ONMMMMMMMMMMZ.", "             ,NMMMMMMM8.", "            .:,.$MMMMMMM", "          .IMMMM..NMMMMMD.", "         .8MMMMM:  :NMMMMN.", "         .MMMMMM.   .MMMMM~.", "         .MMMMMN    .MMMMM?.", "", "      Atlassian JIRA", "      Version : 7.3.6", "                  ", "", "If you encounter issues starting or stopping JIRA, please see the Troubleshooting guide at http://confluence.atlassian.com/display/JIRA/Installation+Troubleshooting+Guide", "", "", "Server startup logs are located in /opt/atlassian/jira/logs/catalina.out", "Using CATALINA_BASE:   /opt/atlassian/jira", "Using CATALINA_HOME:   /opt/atlassian/jira", "Using CATALINA_TMPDIR: /opt/atlassian/jira/temp", "Using JRE_HOME:        /opt/atlassian/jira/jre/", "Using CLASSPATH:       /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/jira/work/catalina.pid", "Tomcat started."]}
        # 
        # PLAY RECAP *************************************************************************
        # atlassian1                 : ok=6    changed=5    unreachable=0    failed=0   
    
    This will configure the authenticator.
    
    <div class="info">
    After Jira has been restarted, you are not able to login with the local
    administrator anymore, but with your crowd credentials.
    
    </div>


<a id="orgfcf1c22"></a>

### Confluence Setup


<a id="orga96dadf"></a>

#### Setup Application

    ansible-playbook -v -i inventories/dev playbooks/confluence.yml --ask-vault
    opendevstack

    # Using /vagrant/ansible/ansible.cfg as config file
    # Vault password: opendevstack
    # 
    # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
    # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
    # 
    # PLAY [tag_hostgroup_confluence_test] ***********************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [srsp.oracle-java : precondition - java_version] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_subversion] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : precondition - java_install_jce] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_version": "1.8.0_192"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set general internal vars for 8] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java architecture] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_arch": "x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Linux] ************************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_os": "linux"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java OS for Mac OS X] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set rpm binary] *******************************************
    # ok: [atlassian1] => {"ansible_facts": {"use_dmg": false, "use_rpm": true, "use_tarball": false}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set tarball binary] ***************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set dmg binary] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 10] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 9.0.4] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_192] **************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_hash": "750e1c8617c5452694857ad95c3ee230", "jdk_version_detail": "8u192-b12"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_181] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_172] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_171] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_161] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_152] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_151] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_141] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_131] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_121] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_112] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for 1.8.0_111] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set internal vars for generic Java version] ***************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_file": "jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : compose filename, if necessary] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : compose url for downloading file, if necessary] ***********
    # ok: [atlassian1] => {"ansible_facts": {"jdk_tarball_url": "http://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE zip file variables for java 8] ********************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_file": "jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE variables for java 8] *****************************
    # ok: [atlassian1] => {"ansible_facts": {"jce_zip_folder": "UnlimitedJCEPolicyJDK8", "jce_zip_url": "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : set JCE download file] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Debian platforms] ******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on Mac OS X] **************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : set java installation directory on non-Debian platforms] ***
    # ok: [atlassian1] => {"ansible_facts": {"java_default_link_name": "default", "java_home": "/usr/java/default", "java_install_dir": "/usr/java"}, "changed": false}
    # 
    # TASK [srsp.oracle-java : install libselinux-python binary for Ansible to work] *****
    # ok: [atlassian1] => {"changed": false, "msg": "", "rc": 0, "results": ["libselinux-python-2.5-12.el7.x86_64 providing libselinux-python is already installed"]}
    # 
    # TASK [srsp.oracle-java : copy scripts to server] ***********************************
    # ok: [atlassian1] => {"changed": false, "checksum": "2546647b60a8fffe888d8b73c924cfa0492c60b2", "dest": "/tmp/check-java-version.sh", "gid": 0, "group": "root", "mode": "0755", "owner": "root", "path": "/tmp/check-java-version.sh", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 416, "state": "file", "uid": 0}
    # 
    # TASK [srsp.oracle-java : check if specific version of Oracle JDK is installed?] ****
    # ok: [atlassian1] => {"changed": false, "cmd": "LC_ALL=\"en_US.UTF-8\" /tmp/check-java-version.sh \"1.8.0_192\"", "delta": "0:00:00.313884", "end": "2018-11-16 13:57:19.828429", "failed_when_result": false, "rc": 0, "start": "2018-11-16 13:57:19.514545", "stderr": "", "stderr_lines": [], "stdout": "{ \"found\": true  , \"not_found\": false }", "stdout_lines": ["{ \"found\": true  , \"not_found\": false }"]}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as RPM file)] ****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK tarball (as tar.gz file)] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JDK package (as Mac OS X .dmg)] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy RPM from local] **************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy tarball from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy .dmg from local] *************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : uninstall messy packages to avoid blocking conditions] ****
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : delete messy .rpm files to avoid blocking conditions] *****
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with yum] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : symlink /usr/sbin/update-alternatives to /usr/sbin/alternatives] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if pkg already installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via RPM file with rpm (for zypper)] ***********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - uninstall messy packages] **********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : clean up - delete messy .rpm files] ***********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for Java] *******************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mkdir for specific Java version] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JDK via tarball file] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : mount the downloaded dmg] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install the pkg file from the dmg] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unmount the downloaded dmg] *******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : make sure /etc/profile.d exists] **************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : export JAVA_HOME] *****************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on rpm based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : link "/usr/java/default on tarball based systems for JDK > 8"] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java"] *****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "javac"] ****************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "jar"] ******************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : check if "java_sdk" target exists] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : alternatives link for "java_sdk"] *************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded files, if requested] **********
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.rpm)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.rpm", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.tar.gz)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.tar.gz", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/jdk-8u192-linux-x64.dmg)  => {"changed": false, "item": "/tmp/jdk-8u192-linux-x64.dmg", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/check-tarball-installed.sh)  => {"changed": false, "item": "/tmp/check-tarball-installed.sh", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Mac] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Make sure 'which' is installed] ***************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Find Java Home in Linux] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Set java_home] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : Check if JCE is already installed] ************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : get JCE] **************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : copy JCE zip from local] **********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install unzip] ********************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : unzip JCE] ************************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : install JCE policies] *************************************
    # skipping: [atlassian1] => (item=local_policy.jar)  => {"changed": false, "item": "local_policy.jar", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=US_export_policy.jar)  => {"changed": false, "item": "US_export_policy.jar", "skip_reason": "Conditional result was False"}
    # 
    # TASK [srsp.oracle-java : remove temporary downloaded JCE files, if requested] ******
    # skipping: [atlassian1] => (item=/tmp/jce_policy-8.zip)  => {"changed": false, "item": "/tmp/jce_policy-8.zip", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=/tmp/UnlimitedJCEPolicyJDK8)  => {"changed": false, "item": "/tmp/UnlimitedJCEPolicyJDK8", "skip_reason": "Conditional result was False"}
    # 
    # TASK [local.atlassian_confluence : download confluence installer] ******************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "60aba200153370b17bb6897e2ee8016de8d5835f", "dest": "/tmp/atlassian-confluence-6.1.3-x64.bin", "gid": 0, "group": "root", "md5sum": "79cf86f950bb90790e74bb735c9ad9d5", "mode": "0754", "msg": "OK (592116939 bytes)", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 592116939, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542376644.93-140902917562343/tmpW8mLIz", "state": "file", "status_code": 200, "uid": 0, "url": "https://downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-6.1.3-x64.bin"}
    # 
    # TASK [local.atlassian_confluence : create config file for silent install] **********
    # changed: [atlassian1] => {"changed": true, "checksum": "ba385c6219c054b1c08e68db17d43da989ea1bfe", "dest": "/tmp/confluence_installer.cfg", "gid": 0, "group": "root", "md5sum": "5bfb17f9ee50124ada8d7f2d2f865f77", "mode": "0644", "owner": "root", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 429, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542376777.49-183945107863722/source", "state": "file", "uid": 0}
    # 
    # TASK [local.atlassian_confluence : run installer] **********************************
    # changed: [atlassian1] => {"changed": true, "cmd": "./atlassian-confluence-6.1.3-x64.bin -q -varfile ./confluence_installer.cfg", "delta": "0:00:58.090728", "end": "2018-11-16 14:00:37.539968", "failed_when_result": false, "rc": 0, "start": "2018-11-16 13:59:39.449240", "stderr": "Nov 16, 2018 2:00:36 PM com.atlassian.modzdetector.HashRegistry store\nINFO: wrote 929 hashes to /opt/atlassian/confluence/install.reg", "stderr_lines": ["Nov 16, 2018 2:00:36 PM com.atlassian.modzdetector.HashRegistry store", "INFO: wrote 929 hashes to /opt/atlassian/confluence/install.reg"], "stdout": "Unpacking JRE ...\nStarting Installer ...\n\u001b[?7hExtracting files ...\nLaunching Confluence ...\nFinishing installation ...", "stdout_lines": ["Unpacking JRE ...", "Starting Installer ...", "\u001b[?7hExtracting files ...", "Launching Confluence ...", "Finishing installation ..."]}
    # 
    # TASK [local.atlassian_confluence : modify JVM properties] **************************
    # changed: [atlassian1] => {"changed": true, "checksum": "55abb961527b8c770998b815accfcf666ca65694", "dest": "/opt/atlassian/confluence/conf/server.xml", "gid": 0, "group": "root", "md5sum": "ded066022c3e6477c8867426fc82b8fd", "mode": "0644", "owner": "root", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 2516, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542376838.97-239817347910039/source", "state": "file", "uid": 0}
    # 
    # TASK [local.atlassian_confluence : modify JVM properties] **************************
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
    # 
    # RUNNING HANDLER [local.atlassian_confluence : stop confluence] *********************
    #  [WARNING]: Consider using the service module rather than running service.  If you
    # need to use command because service is insufficient you can add warn=False to this
    # command task or set command_warnings=False in ansible.cfg to get rid of this
    # message.
    # changed: [atlassian1] => {"changed": true, "cmd": ["service", "confluence", "stop"], "delta": "0:00:01.985972", "end": "2018-11-16 14:00:47.865074", "rc": 0, "start": "2018-11-16 14:00:45.879102", "stderr": "/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found", "stderr_lines": ["/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found"], "stdout": "executing using dedicated user\nIf you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide\n\nServer startup logs are located in /opt/atlassian/confluence/logs/catalina.out\n---------------------------------------------------------------------------\nUsing Java: /opt/atlassian/confluence/jre//bin/java\n2018-11-16 14:00:46,518 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required\n---------------------------------------------------------------------------\nUsing CATALINA_BASE:   /opt/atlassian/confluence\nUsing CATALINA_HOME:   /opt/atlassian/confluence\nUsing CATALINA_TMPDIR: /opt/atlassian/confluence/temp\nUsing JRE_HOME:        /opt/atlassian/confluence/jre/\nUsing CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid\nTomcat stopped.", "stdout_lines": ["executing using dedicated user", "If you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide", "", "Server startup logs are located in /opt/atlassian/confluence/logs/catalina.out", "---------------------------------------------------------------------------", "Using Java: /opt/atlassian/confluence/jre//bin/java", "2018-11-16 14:00:46,518 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required", "---------------------------------------------------------------------------", "Using CATALINA_BASE:   /opt/atlassian/confluence", "Using CATALINA_HOME:   /opt/atlassian/confluence", "Using CATALINA_TMPDIR: /opt/atlassian/confluence/temp", "Using JRE_HOME:        /opt/atlassian/confluence/jre/", "Using CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid", "Tomcat stopped."]}
    # 
    # RUNNING HANDLER [local.atlassian_confluence : start confluence] ********************
    # changed: [atlassian1] => {"changed": true, "cmd": ["service", "confluence", "start"], "delta": "0:00:00.610871", "end": "2018-11-16 14:00:49.061783", "rc": 0, "start": "2018-11-16 14:00:48.450912", "stderr": "/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found", "stderr_lines": ["/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found"], "stdout": "\nTo run Confluence in the foreground, start the server with start-confluence.sh -fg\nexecuting using dedicated user: confluence\nIf you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide\n\nServer startup logs are located in /opt/atlassian/confluence/logs/catalina.out\n---------------------------------------------------------------------------\nUsing Java: /opt/atlassian/confluence/jre//bin/java\n2018-11-16 14:00:49,045 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required\n---------------------------------------------------------------------------\nUsing CATALINA_BASE:   /opt/atlassian/confluence\nUsing CATALINA_HOME:   /opt/atlassian/confluence\nUsing CATALINA_TMPDIR: /opt/atlassian/confluence/temp\nUsing JRE_HOME:        /opt/atlassian/confluence/jre/\nUsing CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid\nTomcat started.", "stdout_lines": ["", "To run Confluence in the foreground, start the server with start-confluence.sh -fg", "executing using dedicated user: confluence", "If you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide", "", "Server startup logs are located in /opt/atlassian/confluence/logs/catalina.out", "---------------------------------------------------------------------------", "Using Java: /opt/atlassian/confluence/jre//bin/java", "2018-11-16 14:00:49,045 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required", "---------------------------------------------------------------------------", "Using CATALINA_BASE:   /opt/atlassian/confluence", "Using CATALINA_HOME:   /opt/atlassian/confluence", "Using CATALINA_TMPDIR: /opt/atlassian/confluence/temp", "Using JRE_HOME:        /opt/atlassian/confluence/jre/", "Using CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid", "Tomcat started."]}
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=21   changed=7    unreachable=0    failed=0   
    # 


<a id="org5abc280"></a>

#### Run Configuration Wizard

<http://192.168.56.31:8090>


<a id="orgc6b0518"></a>

#### Set up Confluence

Here you have to choose **Production Installation**, because we want to configure an external database.


<a id="org8310ba9"></a>

#### Get add-ons

Ensure the **add-ons** are **unchecked** and proceed.


<a id="org7a0284d"></a>

#### License key

Here you are able to **Get an evaluation license** from atlassian or to enter a valid license key.


<a id="orgff6ea78"></a>

#### Choose a Database Configuration

Here you have to choose **External Database** with the option **PostgreSQL**


<a id="orgc6cb425"></a>

#### Configure Database

Click the **Direct JDBC** button and configure the database with the following values:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Option</th>
<th scope="col" class="org-left">Value</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Driver Class Name</td>
<td class="org-left">org.postgresql.Driver</td>
</tr>


<tr>
<td class="org-left">Database URL</td>
<td class="org-left">jdbc:postgresql://localhost:5432/confluence</td>
</tr>


<tr>
<td class="org-left">User Name</td>
<td class="org-left">confluence</td>
</tr>


<tr>
<td class="org-left">Password</td>
<td class="org-left">confluence</td>
</tr>
</tbody>
</table>

Be patient. This step takes some time until next page appears.


<a id="orgca7ed7e"></a>

#### Load Content

Here you have to choose **Empty Site** or **Example Site**

Click on **Example Site**


<a id="orge882d70"></a>

#### Configure User Management

Choose **Manage users and groups within Confluence**. Crowd will be configured later.


<a id="orgae4f9f7"></a>

#### Configure System Administrator account

Here you have to configure a local administrator account.

    Username: vzell
    Name: Volker Zell
    Email address: volker.zell@opitz-consulting.com
    Password: opendevstack
    Confirm: opendevstack

After this step, you are able to work with Confluence. Just press **Start** and
create a **space**.


<a id="org4262b98"></a>

#### Configure Crowd access

-   Configure user directory

    Open the **User management** in the Confluence administration. To enter the
    administration, you have to verify you have admin rights with the password for
    your admin user. Click the User Directories entry at the left in the USERS &
    SECURITY section. Now choose Add Directory. Here you have to add a directory of
    type **Atlassian Crowd**. Here you have to add the Crowd server URL
    <http://192.168.56.31:8095/crowd> You also have to add the application name and
    the password you have defined for Confluence in crowd. For the local test
    environment this is confluence confluence Now activate nested groups and
    deactivate the incremental synchronization The group membership should be
    proofed every time a user logs in. Test the settings and save them. Now change
    the order of the user directories. The Crowd directory has to be on first
    position.

-   Configure SSO with crowd

    To finish the SSO configuration, you will have to run the following playbook command:
    
        ansible-playbook -v -i inventories/dev playbooks/confluence_enable_sso.yml --ask-vault
        opendevstack
    
        # Using /vagrant/ansible/ansible.cfg as config file
        # Vault password: opendevstack
        # 
        # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
        # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
        # 
        # PLAY [tag_hostgroup_confluence_test] ***********************************************
        # 
        # TASK [Gathering Facts] *************************************************************
        # ok: [atlassian1]
        # 
        # TASK [remove old authenticator] ****************************************************
        # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
        # 
        # TASK [ensure we have the SSO authenticator enabled] ********************************
        # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
        # 
        # TASK [create crowd.properties files] ***********************************************
        # changed: [atlassian1] => {"changed": true, "checksum": "c37379c6e1bab36f7fcf26160739700d2407c9b5", "dest": "/opt/atlassian/confluence/confluence/WEB-INF/classes/crowd.properties", "gid": 0, "group": "root", "md5sum": "5a6695622f29bc201ce5d47dbca82967", "mode": "0644", "owner": "root", "secontext": "unconfined_u:object_r:usr_t:s0", "size": 310, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542379951.39-259808136826893/source", "state": "file", "uid": 0}
        # 
        # RUNNING HANDLER [stop confluence] **************************************************
        #  [WARNING]: Consider using the service module rather than running service.  If you
        # need to use command because service is insufficient you can add warn=False to this
        # command task or set command_warnings=False in ansible.cfg to get rid of this
        # message.
        # changed: [atlassian1] => {"changed": true, "cmd": ["service", "confluence", "stop"], "delta": "0:00:25.353647", "end": "2018-11-16 14:52:58.872776", "rc": 0, "start": "2018-11-16 14:52:33.519129", "stderr": "/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found", "stderr_lines": ["/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found"], "stdout": "executing using dedicated user\nIf you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide\n\nServer startup logs are located in /opt/atlassian/confluence/logs/catalina.out\n---------------------------------------------------------------------------\nUsing Java: /opt/atlassian/confluence/jre//bin/java\n2018-11-16 14:52:36,561 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required\n---------------------------------------------------------------------------\nUsing CATALINA_BASE:   /opt/atlassian/confluence\nUsing CATALINA_HOME:   /opt/atlassian/confluence\nUsing CATALINA_TMPDIR: /opt/atlassian/confluence/temp\nUsing JRE_HOME:        /opt/atlassian/confluence/jre/\nUsing CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid\nTomcat did not stop in time.\nTo aid diagnostics a thread dump has been written to standard out.\nKilling Tomcat with the PID: 22463\nThe Tomcat process has been killed.", "stdout_lines": ["executing using dedicated user", "If you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide", "", "Server startup logs are located in /opt/atlassian/confluence/logs/catalina.out", "---------------------------------------------------------------------------", "Using Java: /opt/atlassian/confluence/jre//bin/java", "2018-11-16 14:52:36,561 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required", "---------------------------------------------------------------------------", "Using CATALINA_BASE:   /opt/atlassian/confluence", "Using CATALINA_HOME:   /opt/atlassian/confluence", "Using CATALINA_TMPDIR: /opt/atlassian/confluence/temp", "Using JRE_HOME:        /opt/atlassian/confluence/jre/", "Using CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid", "Tomcat did not stop in time.", "To aid diagnostics a thread dump has been written to standard out.", "Killing Tomcat with the PID: 22463", "The Tomcat process has been killed."]}
        # 
        # RUNNING HANDLER [start confluence] *************************************************
        # changed: [atlassian1] => {"changed": true, "cmd": ["service", "confluence", "start"], "delta": "0:00:00.803754", "end": "2018-11-16 14:53:00.261016", "rc": 0, "start": "2018-11-16 14:52:59.457262", "stderr": "/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found", "stderr_lines": ["/opt/atlassian/confluence/bin/setenv.sh: line 69: -Dsynchrony.proxy.enabled=true: command not found"], "stdout": "\nTo run Confluence in the foreground, start the server with start-confluence.sh -fg\nexecuting using dedicated user: confluence\nIf you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide\n\nServer startup logs are located in /opt/atlassian/confluence/logs/catalina.out\n---------------------------------------------------------------------------\nUsing Java: /opt/atlassian/confluence/jre//bin/java\n2018-11-16 14:53:00,213 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required\n---------------------------------------------------------------------------\nUsing CATALINA_BASE:   /opt/atlassian/confluence\nUsing CATALINA_HOME:   /opt/atlassian/confluence\nUsing CATALINA_TMPDIR: /opt/atlassian/confluence/temp\nUsing JRE_HOME:        /opt/atlassian/confluence/jre/\nUsing CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar\nUsing CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid\nTomcat started.", "stdout_lines": ["", "To run Confluence in the foreground, start the server with start-confluence.sh -fg", "executing using dedicated user: confluence", "If you encounter issues starting up Confluence, please see the Installation guide at http://confluence.atlassian.com/display/DOC/Confluence+Installation+Guide", "", "Server startup logs are located in /opt/atlassian/confluence/logs/catalina.out", "---------------------------------------------------------------------------", "Using Java: /opt/atlassian/confluence/jre//bin/java", "2018-11-16 14:53:00,213 INFO [main] [atlassian.confluence.bootstrap.SynchronyProxyWatchdog] A Context element for ${confluence.context.path}/synchrony-proxy is found in /opt/atlassian/confluence/conf/server.xml. No further action is required", "---------------------------------------------------------------------------", "Using CATALINA_BASE:   /opt/atlassian/confluence", "Using CATALINA_HOME:   /opt/atlassian/confluence", "Using CATALINA_TMPDIR: /opt/atlassian/confluence/temp", "Using JRE_HOME:        /opt/atlassian/confluence/jre/", "Using CLASSPATH:       /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar", "Using CATALINA_PID:    /opt/atlassian/confluence/work/catalina.pid", "Tomcat started."]}
        # 
        # PLAY RECAP *************************************************************************
        # atlassian1                 : ok=6    changed=5    unreachable=0    failed=0   
    
    This will configure the authenticator. After Confluence has been restarted, you
    are not able to login with the local administrator anymore, but with your crowd
    credentials.


<a id="org49324a1"></a>

### Create opendevstack project in Bitbucket

We will mirror the opendevstack project into this Bitbucket instance. Therefore, we need to create a new project.

-   Go to the Projects page in Bitbucket
-   Hit **Create project** button
-   Enter Project Name: OpenDevStack and key: OPENDEVSTACK
-   Hit **Create Project**
-   In the **Settings** section -> **Permissions**, allow the **bitbucket-users** group write access. Click **Add**
-   You will be directed to the projects dashboard. Using the ‘+’ sign you need to create a couple of repositories:

-   ods-core
-   ods-configuration
-   ods-configuration-sample
-   ods-jenkins-shared-library
-   ods-project-quickstarters
-   ods-provisioning-app

On the Project Dashboard Navigate to the **Settings** menu and grant the group
**opendevstack-users** admin access. Click **Add**

Navigate to the `/vagrant/scripts` directory in your control VM **atlcon** and
execute `mirror-repos.sh`.

Use your crowd login when asked for credentials.

    cd /vagrant/scripts

    bash mirror-repos.sh

    # Cloning into bare repository 'ods-configuration-sample.git'...
    # remote: Enumerating objects: 28, done.        
    # remote: Counting objects: 100% (28/28), done.        
    # remote: Compressing objects: 100% (16/16), done.        
    # remote: Total 283 (delta 8), reused 17 (delta 5), pack-reused 255        
    # Receiving objects: 100% (283/283), 40.41 KiB | 0 bytes/s, done.
    # Resolving deltas: 100% (79/79), done.
    # Cloning into bare repository 'ods-core.git'...
    # remote: Enumerating objects: 491, done.        
    # remote: Total 491 (delta 0), reused 0 (delta 0), pack-reused 491        
    # Receiving objects: 100% (491/491), 43.58 MiB | 5.44 MiB/s, done.
    # Resolving deltas: 100% (129/129), done.
    # Cloning into bare repository 'ods-jenkins-shared-library.git'...
    # remote: Enumerating objects: 122, done.        
    # remote: Counting objects: 100% (122/122), done.        
    # remote: Compressing objects: 100% (65/65), done.        
    # remote: Total 498 (delta 53), reused 87 (delta 33), pack-reused 376        
    # Receiving objects: 100% (498/498), 94.14 KiB | 0 bytes/s, done.
    # Resolving deltas: 100% (254/254), done.
    # Cloning into bare repository 'ods-provisioning-app.git'...
    # remote: Enumerating objects: 503, done.        
    # remote: Counting objects: 100% (503/503), done.        
    # remote: Compressing objects: 100% (237/237), done.        
    # remote: Total 866 (delta 209), reused 436 (delta 181), pack-reused 363        
    # Receiving objects: 100% (866/866), 307.71 KiB | 0 bytes/s, done.
    # Resolving deltas: 100% (377/377), done.
    # Cloning into bare repository 'ods-project-quickstarters.git'...
    # remote: Enumerating objects: 190, done.        
    # remote: Counting objects: 100% (190/190), done.        
    # remote: Compressing objects: 100% (118/118), done.        
    # remote: Total 934 (delta 70), reused 166 (delta 57), pack-reused 744        
    # Receiving objects: 100% (934/934), 5.91 MiB | 3.91 MiB/s, done.
    # Resolving deltas: 100% (366/366), done.
    # /tmp
    # /tmp
    # /tmp
    # /tmp
    # /tmp
    # Username for 'http://192.168.56.31:7990': vzell
    # Password for 'http://vzell@192.168.56.31:7990': 
    # Counting objects: 283, done.
    # Compressing objects: 100% (123/123), done.
    # Writing objects: 100% (283/283), 40.42 KiB | 0 bytes/s, done.
    # Total 283 (delta 79), reused 283 (delta 79)
    # To http://192.168.56.31:7990/scm//opendevstack/ods-configuration-sample.git
    #  * [new branch]      master -> master
    #  * [new tag]         0.1.0 -> 0.1.0
    # /tmp
    # Username for 'http://192.168.56.31:7990': vzell
    # Password for 'http://vzell@192.168.56.31:7990': 
    # Counting objects: 491, done.
    # Compressing objects: 100% (316/316), done.
    # Writing objects: 100% (491/491), 43.58 MiB | 22.15 MiB/s, done.
    # Total 491 (delta 129), reused 491 (delta 129)
    # To http://192.168.56.31:7990/scm//opendevstack/ods-core.git
    #  * [new branch]      master -> master
    #  * [new branch]      production -> production
    #  * [new tag]         0.1.0 -> 0.1.0
    # /tmp
    # Username for 'http://192.168.56.31:7990': vzell
    # Password for 'http://vzell@192.168.56.31:7990': 
    # Counting objects: 498, done.
    # Compressing objects: 100% (126/126), done.
    # Writing objects: 100% (498/498), 94.15 KiB | 0 bytes/s, done.
    # Total 498 (delta 254), reused 498 (delta 254)
    # To http://192.168.56.31:7990/scm//opendevstack/ods-jenkins-shared-library.git
    #  * [new branch]      0.1.x -> 0.1.x
    #  * [new branch]      master -> master
    #  * [new branch]      production -> production
    #  * [new tag]         0.1-latest -> 0.1-latest
    #  * [new tag]         0.1.0 -> 0.1.0
    # /tmp
    # Username for 'http://192.168.56.31:7990': vzell
    # Password for 'http://vzell@192.168.56.31:7990': 
    # Counting objects: 934, done.
    # Compressing objects: 100% (502/502), done.
    # Writing objects: 100% (934/934), 5.91 MiB | 5.35 MiB/s, done.
    # Total 934 (delta 366), reused 934 (delta 366)
    # To http://192.168.56.31:7990/scm//opendevstack/ods-project-quickstarters.git
    #  * [new branch]      master -> master
    #  * [new branch]      production -> production
    #  * [new tag]         0.1.0 -> 0.1.0
    # /tmp
    # Username for 'http://192.168.56.31:7990': vzell
    # Password for 'http://vzell@192.168.56.31:7990': 
    # Counting objects: 866, done.
    # Compressing objects: 100% (376/376), done.
    # Writing objects: 100% (866/866), 307.70 KiB | 0 bytes/s, done.
    # Total 866 (delta 377), reused 866 (delta 377)
    # To http://192.168.56.31:7990/scm//opendevstack/ods-provisioning-app.git
    #  * [new branch]      master -> master
    #  * [new branch]      production -> production
    #  * [new tag]         0.1.0 -> 0.1.0
    # /tmp

Verify that you have mirrored the github repos and that they have been populated
in your Bitbucket instance. The ods-configuration repositpory will remain empty.

Setup project branch permissions - **production** should be guarded against direct
merges except through admins.


<a id="org699964b"></a>

### Rundeck Setup


<a id="org2d6817d"></a>

#### Setup Application

Rundeck needs an account to access Bitbucket later. We will create an ssh
keypair for this and add this later to the Bitbucket **cd\_user** account.

Open the shell and generate a ssh key.

    ssh-keygen -f /home/vagrant/cd_user -t rsa -C "CD User"

This saves the public and private key in a file `cd_user.pub` and `cd_user`.

    cd /home/vagrant && ls -lt

    # total 8
    # -rw-------. 1 vagrant vagrant 1675 Nov 18 07:24 cd_user
    # -rw-r--r--. 1 vagrant vagrant  389 Nov 18 07:24 cd_user.pub

    cat cd_user.pub

    # ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIFfxfrg+A/QOpnNcISlcK1mX37UWHi3g5Xq7ORhVbUd2Fe5L9q8QqJlILN5z20uL285KS1LqZ8HYmDCnpis0CMMvuXjK4SSFzfJx0Yizz8+4wcry2HSuAlWafV2oDDr7n0215otgqi2HFxNikyXfhss6fTgERqAZHKLHT8fNX4hNajspkweqlUyOcgLvYd07HiR/n08lUp7TdAze1DYk/wVsSq0yiGLp3kIg1B0EwITuyHaoPlxRVEGuceAgBTZ3r3j0rxlJGFEIo8CpzQwH+vV80CNXrFMfzagLrXpzIUDj6gdieDp2aQvDg2tL9U6booQFg4y8iC0M2O6BcJ2uj CD User

    cat cd_user

    # -----BEGIN RSA PRIVATE KEY-----
    # MIIEogIBAAKCAQEAyBX8X64PgP0DqZzXCEpXCtZl9+1Fh4t4OV6uzkYVW1HdhXuS
    # /avEKiZSCzec9tLi9vOSktS6mfB2Jgwp6YrNAjDL7l4yuEkhc3ycdGIs8/PuMHK8
    # th0rgJVmn1dqAw6+59NteaLYKothxcTYpMl34bLOn04BEagGRyix0/HzV+ITWo7K
    # ZMHqpVMjnIC72HdOx4kf59PJVKe03QM3tQ2JP8FbEqtMohi6d5CINQdBMCE7sh2q
    # D5cUVRBrnHgIAU2d6949K8ZSRhRCKPAqc0MB/r1fNAjV6xTH82oC616cyFA4+oHY
    # ng6dmkLw4NrS/VOm6KEBYOMvIgtDNjugXCdrowIDAQABAoIBADIuuXZx3HeYfbOr
    # n473vi78qORuwRKG22dgJO2dTDv0I2AYJzyyOOftZoRjtV1+dOhFHMzwx8BWO/u8
    # 70IgytwyyuMFAymPRfGGHmNeQDILSwEhtczjMgb08aEjNnZ/20efkoSAYEEDZklI
    # 3qEt2oBj7UitMr1v6+sq/LbQpxyyKGcopv80IqlwV9IA6zOrSmyX7Orezr7P+Wig
    # zj6Y4vRQ2dY3qjnLsOwU8wnz1ahglrq0XrRh6Sz+OYAy+LNmtweg+FZfH3TJoa8S
    # i5tfwwWQUB9/0BagCO96V99/6dx8IPbjG3TvI2DobcuCLCne4EAWZK2CYZ6PW0XA
    # qKyrEJECgYEA5kChdr2IB3F7H3ESZNbzCeyuVCMNVXBjiAOcTZZgok9Ky7Vc9ZTo
    # Ob3lcJmGNmDmP6vGf/UgCdqVb18GDdRUu3pdcpI0Vgg3zjdgZm0mEgJq9GExnt4g
    # +GjxfsR4f76ylDzoU+dA0nqCBBRmg0CMb2oHAIUGMsxvlOW9MtRT8wkCgYEA3nXJ
    # CRWN/hdHpq92C81xbBbTu5MAxSKBwPhUceyZ2IOZfdOOaDkgcyXSCt5yHLuKTela
    # xXrI0IbbIqPzM4/1P7rgB9136oTlRsArwCGoprO1NkMefay3A6VFNTzgxAW85RBE
    # xYT4rltkTq+kTU6eSOhT39+Rri6QHJDBfEpLeEsCgYAPcAHjXi3Cof8pSoF7NVYy
    # MiY2CeuY8OIbenJ+WTi9aSeQpOZIqOUxCeRaOlDfUHvfhPrYFW1Ce99NCkfzoWrU
    # 7w1Y4yiTJBXpw5i5BVRqHLNjEykqh6YaQZ7/atjRZ829VqAVEAouknwpHd0Jq8g+
    # qBM0G7cgrMhGaWjYAZhnUQKBgGHz6R5X4Frmc0VA8zCFOJEIiBiKxQcIh6upbL1x
    # GdjNMXPHCGh55wDswUzJ3+Mo7OAbhT15MB0plCnvmPG2TJ3QMj8kVF3uQGpjyZ/i
    # 8jjc3kjTSwS5XSh8yDmF4c5OXHtcK3vxbfKQCV3gVu83U9j0e6IS9jmFBS2ey6Nn
    # r017AoGAAWiXA2M8fGmd4EoO0CicShyX+eVhXULTt+k030iVpCmlpBjG7ifNWPZb
    # A9hW+FWOjopF2gJM0ZUJrQLKcX/XayJpQJ+PK2aTZTUGDAFMadMxzgN70heuOk2c
    # N5P2/mAQjuC4uleZBUrPyW1CnpROfrPR2CxCgcqBPj3ggEVEpus=
    # -----END RSA PRIVATE KEY-----

Create a file called `/home/vagrant/rundeck_vars.yml` that customizes some of the
rundeck configuration, e.g. the ssh key.

This is a yaml file, looking structurally like this example

    cat > rundeck_vars.yml <<-"_EOF"
    rundeck_bitbucket_host_external: 192.168.56.31
    rundeck_bitbucket_host_internal: localhost
    rundeck_bitbucket_port: 7999
    rundeck_cduser_name: cd_user
    rundeck_cduser_private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEogIBAAKCAQEAyBX8X64PgP0DqZzXCEpXCtZl9+1Fh4t4OV6uzkYVW1HdhXuS
      /avEKiZSCzec9tLi9vOSktS6mfB2Jgwp6YrNAjDL7l4yuEkhc3ycdGIs8/PuMHK8
      th0rgJVmn1dqAw6+59NteaLYKothxcTYpMl34bLOn04BEagGRyix0/HzV+ITWo7K
      ZMHqpVMjnIC72HdOx4kf59PJVKe03QM3tQ2JP8FbEqtMohi6d5CINQdBMCE7sh2q
      D5cUVRBrnHgIAU2d6949K8ZSRhRCKPAqc0MB/r1fNAjV6xTH82oC616cyFA4+oHY
      ng6dmkLw4NrS/VOm6KEBYOMvIgtDNjugXCdrowIDAQABAoIBADIuuXZx3HeYfbOr
      n473vi78qORuwRKG22dgJO2dTDv0I2AYJzyyOOftZoRjtV1+dOhFHMzwx8BWO/u8
      70IgytwyyuMFAymPRfGGHmNeQDILSwEhtczjMgb08aEjNnZ/20efkoSAYEEDZklI
      3qEt2oBj7UitMr1v6+sq/LbQpxyyKGcopv80IqlwV9IA6zOrSmyX7Orezr7P+Wig
      zj6Y4vRQ2dY3qjnLsOwU8wnz1ahglrq0XrRh6Sz+OYAy+LNmtweg+FZfH3TJoa8S
      i5tfwwWQUB9/0BagCO96V99/6dx8IPbjG3TvI2DobcuCLCne4EAWZK2CYZ6PW0XA
      qKyrEJECgYEA5kChdr2IB3F7H3ESZNbzCeyuVCMNVXBjiAOcTZZgok9Ky7Vc9ZTo
      Ob3lcJmGNmDmP6vGf/UgCdqVb18GDdRUu3pdcpI0Vgg3zjdgZm0mEgJq9GExnt4g
      +GjxfsR4f76ylDzoU+dA0nqCBBRmg0CMb2oHAIUGMsxvlOW9MtRT8wkCgYEA3nXJ
      CRWN/hdHpq92C81xbBbTu5MAxSKBwPhUceyZ2IOZfdOOaDkgcyXSCt5yHLuKTela
      xXrI0IbbIqPzM4/1P7rgB9136oTlRsArwCGoprO1NkMefay3A6VFNTzgxAW85RBE
      xYT4rltkTq+kTU6eSOhT39+Rri6QHJDBfEpLeEsCgYAPcAHjXi3Cof8pSoF7NVYy
      MiY2CeuY8OIbenJ+WTi9aSeQpOZIqOUxCeRaOlDfUHvfhPrYFW1Ce99NCkfzoWrU
      7w1Y4yiTJBXpw5i5BVRqHLNjEykqh6YaQZ7/atjRZ829VqAVEAouknwpHd0Jq8g+
      qBM0G7cgrMhGaWjYAZhnUQKBgGHz6R5X4Frmc0VA8zCFOJEIiBiKxQcIh6upbL1x
      GdjNMXPHCGh55wDswUzJ3+Mo7OAbhT15MB0plCnvmPG2TJ3QMj8kVF3uQGpjyZ/i
      8jjc3kjTSwS5XSh8yDmF4c5OXHtcK3vxbfKQCV3gVu83U9j0e6IS9jmFBS2ey6Nn
      r017AoGAAWiXA2M8fGmd4EoO0CicShyX+eVhXULTt+k030iVpCmlpBjG7ifNWPZb
      A9hW+FWOjopF2gJM0ZUJrQLKcX/XayJpQJ+PK2aTZTUGDAFMadMxzgN70heuOk2c
      N5P2/mAQjuC4uleZBUrPyW1CnpROfrPR2CxCgcqBPj3ggEVEpus=
      -----END RSA PRIVATE KEY-----
    _EOF

You have to replace the private key with the key you created earlier and change
other variables according to your environment. Be careful about the 2 spaces at
the beginning of every line of the private key.

    cd /vagrant/ansible

Now execute the playbook:

    ansible-playbook -v -i inventories/dev playbooks/rundeck.yml -e "@/home/vagrant/rundeck_vars.yml" --ask-vault
    opendevstack

    # Using /vagrant/ansible/ansible.cfg as config file
    # Vault password: opendevstack
    # 
    # /vagrant/ansible/inventories/dev/hosts did not meet host_list requirements, check plugin documentation if this is unexpected
    # /vagrant/ansible/inventories/dev/hosts did not meet script requirements, check plugin documentation if this is unexpected
    # 
    # PLAY [tag_hostgroup_bitbucket_test] ************************************************
    # 
    # TASK [Gathering Facts] *************************************************************
    # ok: [atlassian1]
    # 
    # TASK [modified.neel.rundeck : Debian | Install supporting packages] ****************
    # [DEPRECATION WARNING]: Invoking "apt" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'python-pip', u'python-
    # setuptools']` and remove the loop. This feature will be removed in version 2.11. 
    # Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # skipping: [atlassian1] => (item=[])  => {"changed": false, "item": [], "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | Install supporting python packages] *********
    # [DEPRECATION WARNING]: Invoking "pip" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'httplib2']` and remove the 
    # loop. This feature will be removed in version 2.11. Deprecation warnings can be 
    # disabled by setting deprecation_warnings=False in ansible.cfg.
    # skipping: [atlassian1] => (item=[])  => {"changed": false, "item": [], "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | Add Bintray GPG key for rundeck repo] *******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | Add Debian Build GPG key] *******************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | Add Debian APT repository on Bintray] *******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | install from APT repository] ****************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | check upstart configuration exists] *********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | remove System V init.d script if upstart config exists] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | add systemd service helper] *****************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | add systemd service unit] *******************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | ensure service log directory has correct ownership] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | See if there are more log files] ************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Debian | ensure service log files have correct ownership] ***
    # 
    # TASK [modified.neel.rundeck : Redhat | get rundeck rpm] ****************************
    # changed: [atlassian1] => {"changed": true, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nExamining /home/vagrant/.ansible/tmp/ansible-tmp-1542526719.27-232904809127680/latestvOjdZr.rpm: rundeck-repo-4-0.noarch\nMarking /home/vagrant/.ansible/tmp/ansible-tmp-1542526719.27-232904809127680/latestvOjdZr.rpm to be installed\nResolving Dependencies\n--> Running transaction check\n---> Package rundeck-repo.noarch 0:4-0 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package              Arch           Version        Repository             Size\n================================================================================\nInstalling:\n rundeck-repo         noarch         4-0            /latestvOjdZr         181  \n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal size: 181  \nInstalled size: 181  \nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : rundeck-repo-4-0.noarch                                      1/1 \n  Verifying  : rundeck-repo-4-0.noarch                                      1/1 \n\nInstalled:\n  rundeck-repo.noarch 0:4-0                                                     \n\nComplete!\n"]}
    # 
    # TASK [modified.neel.rundeck : Redhat | get rundeck rpm] ****************************
    # changed: [atlassian1] => {"changed": true, "msg": "warning: /var/cache/yum/x86_64/7/rundeck-release-bintray/packages/rundeck-config-2.8.2-1.31.GA.noarch.rpm: Header V3 RSA/SHA1 Signature, key ID e2d1065b: NOKEY\nImporting GPG key 0xE2D1065B:\n Userid     : \"Rundeck Build (automated builds) <build@rundeck.org>\"\n Fingerprint: 85e9 dbc7 4fcb 329e deda dd2e 9077 0e1b e2d1 065b\n From       : http://rundeck.org/keys/BUILD-GPG-KEY-Rundeck.org.key\n", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.fra10.de.leaseweb.net\n * epel: mirror.netcologne.de\n * extras: mirror.23media.de\n * updates: ftp.rz.uni-frankfurt.de\nResolving Dependencies\n--> Running transaction check\n---> Package rundeck.noarch 0:2.8.2-1.31.GA will be installed\n---> Package rundeck-config.noarch 0:2.8.2-1.31.GA will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package           Arch      Version           Repository                  Size\n================================================================================\nInstalling:\n rundeck           noarch    2.8.2-1.31.GA     rundeck-release-bintray    101 M\n rundeck-config    noarch    2.8.2-1.31.GA     rundeck-release-bintray     10 k\n\nTransaction Summary\n================================================================================\nInstall  2 Packages\n\nTotal download size: 101 M\nInstalled size: 146 M\nDownloading packages:\nPublic key for rundeck-config-2.8.2-1.31.GA.noarch.rpm is not installed\n--------------------------------------------------------------------------------\nTotal                                              1.5 MB/s | 101 MB  01:05     \nRetrieving key from http://rundeck.org/keys/BUILD-GPG-KEY-Rundeck.org.key\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : rundeck-2.8.2-1.31.GA.noarch                                 1/2 \n  Installing : rundeck-config-2.8.2-1.31.GA.noarch                          2/2 \n  Verifying  : rundeck-config-2.8.2-1.31.GA.noarch                          1/2 \n  Verifying  : rundeck-2.8.2-1.31.GA.noarch                                 2/2 \n\nInstalled:\n  rundeck.noarch 0:2.8.2-1.31.GA      rundeck-config.noarch 0:2.8.2-1.31.GA     \n\nComplete!\n"]}
    # 
    # TASK [modified.neel.rundeck : Debian | discover version number] ********************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : RedHat | discover version number] ********************
    #  [WARNING]: Consider using the yum module rather than running yum.  If you need to
    # use command because yum is insufficient you can add warn=False to this command task
    # or set command_warnings=False in ansible.cfg to get rid of this message.
    # changed: [atlassian1] => {"changed": true, "cmd": "yum info rundeck | grep -i version", "delta": "0:00:04.036892", "end": "2018-11-18 07:40:35.653880", "rc": 0, "start": "2018-11-18 07:40:31.616988", "stderr": "", "stderr_lines": [], "stdout": "Version     : 2.8.2\nVersion     : 3.0.8.20181029", "stdout_lines": ["Version     : 2.8.2", "Version     : 3.0.8.20181029"]}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure jetty group exists] *****************
    # changed: [atlassian1] => {"changed": true, "gid": 992, "name": "jetty", "state": "present", "system": true}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure rundeck user is apart of jetty group] ***
    # changed: [atlassian1] => {"append": false, "changed": true, "comment": "", "group": 10006, "groups": "jetty", "home": "/var/lib/rundeck", "move_home": false, "name": "rundeck", "shell": "/bin/bash", "state": "present", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : Install | Allow rundeck user to have passwordless sudo] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : Install | configure ssh private key for bitbucket] ***
    # changed: [atlassian1] => {"changed": true, "checksum": "75166436409fb712e6dc4cbf679d9bcdc6c18028", "dest": "/var/lib/rundeck/.ssh/config", "gid": 10006, "group": "rundeck", "md5sum": "84eebb4de6a73e4e49299b7880db55d1", "mode": "0644", "owner": "rundeck", "secontext": "system_u:object_r:ssh_home_t:s0", "size": 94, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526838.69-200400063965920/source", "state": "file", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : Install | Add private ssh key of cd_user] ************
    # changed: [atlassian1] => {"changed": true, "checksum": "3f1c4722dcbaab8128f6c62366a94e1a382c973a", "dest": "/var/lib/rundeck/.ssh/id_rsa_bitbucket", "gid": 10006, "group": "rundeck", "md5sum": "b9a6c7be13cd23a451bd935113f0b0ba", "mode": "0600", "owner": "rundeck", "secontext": "system_u:object_r:ssh_home_t:s0", "size": 1675, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526840.05-91733197921569/source", "state": "file", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure home directory has correct permissions] ***
    # ok: [atlassian1] => {"changed": false, "gid": 10006, "group": "rundeck", "mode": "0755", "owner": "rundeck", "path": "/var/lib/rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 174, "state": "directory", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure tmp directory has correct permissions] ***
    # changed: [atlassian1] => {"changed": true, "gid": 10006, "group": "rundeck", "mode": "0755", "owner": "rundeck", "path": "/tmp/rundeck", "secontext": "unconfined_u:object_r:user_tmp_t:s0", "size": 6, "state": "directory", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure upstart setgid is set to jetty group] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure server url is configured (rundeck-config.properties)] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
    # 
    # TASK [modified.neel.rundeck : Install | Ensure server url is configured (framework.properties)] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | make server lib directory] ****
    # changed: [atlassian1] => {"changed": true, "gid": 10006, "group": "rundeck", "mode": "0655", "owner": "rundeck", "path": "/var/lib/rundeck/lib", "secontext": "unconfined_u:object_r:var_lib_t:s0", "size": 6, "state": "directory", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | download postgreSQL jdbc driver] ***
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "309373613ac03e336e6ff845bccd90af76a0e719", "dest": "/var/lib/rundeck/lib/postgresql-9.3-1103.jdbc3.jar", "gid": 10006, "group": "rundeck", "md5sum": "4dafbbfa0c259a3c288870d993e68336", "mode": "0655", "msg": "OK (540333 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 540333, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526843.89-201616998352792/tmpKXHeEY", "state": "file", "status_code": 200, "uid": 10006, "url": "https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc3.jar"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | update database connection in configuration] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | update database driver in configuration] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | update database dialect in configuration] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | update database username in configuration] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | update database password in configuration] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - PostgreSQL | ensure database is used to store projects] ***
    # [DEPRECATION WARNING]: Using tests as filters is deprecated. Instead of using 
    # `result|version_compare` use `result is version_compare`. This feature will be 
    # removed in version 2.9. Deprecation warnings can be disabled by setting 
    # deprecation_warnings=False in ansible.cfg.
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | make server lib directory] *********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | download jdbc driver] **************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | unarchive jdbc driver] *************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | copy jdbc driver] ******************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | update database connection in configuration] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | update database driver in configuration] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | update database dialect in configuration] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | update database username in configuration] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | update database password in configuration] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Rundeck - MySQL | ensure database is used to store projects] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : Users | determine jetty jar] *************************
    # ok: [atlassian1] => {"changed": false, "examined": 13, "files": [{"atime": 1492645656.0, "ctime": 1542526818.506261, "dev": 64768, "gid": 10006, "gr_name": "rundeck", "inode": 37411130, "isblk": false, "ischr": false, "isdir": false, "isfifo": false, "isgid": false, "islnk": false, "isreg": true, "issock": false, "isuid": false, "mode": "0644", "mtime": 1492645656.0, "nlink": 1, "path": "/var/lib/rundeck/bootstrap/jetty-all-9.0.7.v20131107.jar", "pw_name": "rundeck", "rgrp": true, "roth": true, "rusr": true, "size": 2315396, "uid": 10006, "wgrp": false, "woth": false, "wusr": true, "xgrp": false, "xoth": false, "xusr": false}], "matched": 1, "msg": ""}
    # 
    # TASK [modified.neel.rundeck : Users | encode users password] ***********************
    # skipping: [atlassian1] => {"censored": "the output has been hidden due to the fact that 'no_log: true' was specified for this result", "changed": false}
    # 
    # TASK [modified.neel.rundeck : Users | update basic security to have users] *********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : ensure LDAP longin module configuration exists] ******
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : ensure profile is updated to use LDAP configuration] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : ensure profile is updated to use LDAP module] ********
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [modified.neel.rundeck : download JAAS LoginModule for Crowd into bootstrap dir] ***
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/commons-codec-1.2.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "397f4731a9f9b6eb1907e224911c77ea3aa27a8b", "dest": "/var/lib/rundeck/bootstrap/commons-codec-1.2.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/commons-codec-1.2.jar", "md5sum": "2617b220009f952bb9542af167d040cf", "mode": "0644", "msg": "OK (30085 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 30085, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526852.52-255697236255798/tmpAs24wK", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/commons-codec-1.2.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/commons-httpclient-3.1.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "964cd74171f427720480efdec40a7c7f6e58426a", "dest": "/var/lib/rundeck/bootstrap/commons-httpclient-3.1.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/commons-httpclient-3.1.jar", "md5sum": "8ad8c9229ef2d59ab9f59f7050e846a5", "mode": "0644", "msg": "OK (305001 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 305001, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526855.08-121463945834184/tmpb7h5PD", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/commons-httpclient-3.1.jar"}
    # changed: [atlassian1] => (item=http://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.1/commons-logging-1.1.1.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "5043bfebc3db072ed80fbd362e7caf00e885d8ae", "dest": "/var/lib/rundeck/bootstrap/commons-logging-1.1.1.jar", "gid": 10006, "group": "rundeck", "item": "http://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.1/commons-logging-1.1.1.jar", "md5sum": "ed448347fc0104034aa14c8189bf37de", "mode": "0644", "msg": "OK (60686 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 60686, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526858.06-281248443112987/tmpKgMYiW", "state": "file", "status_code": 200, "uid": 10006, "url": "http://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.1/commons-logging-1.1.1.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jaas-jetty-crowd-1.0.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "0cee145106186bfa4e39c13b76a6549b18953a2e", "dest": "/var/lib/rundeck/bootstrap/jaas-jetty-crowd-1.0.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jaas-jetty-crowd-1.0.jar", "md5sum": "afa020cdeca95e5985b79d73017b0f23", "mode": "0644", "msg": "OK (12880 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 12880, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526858.65-28452969201812/tmphrr5uO", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jaas-jetty-crowd-1.0.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-apache-client-1.19.3.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "52b1ff72d7b265a954d414468378cd7617316824", "dest": "/var/lib/rundeck/bootstrap/jersey-apache-client-1.19.3.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-apache-client-1.19.3.jar", "md5sum": "6a737f39156c85148cf1820780d39bfc", "mode": "0644", "msg": "OK (22288 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 22288, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526861.18-43844544647131/tmpiAiEVM", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-apache-client-1.19.3.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-client-1.19.3.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "dbe8c3a448eed6d0cd8360915d0a46bc31b33485", "dest": "/var/lib/rundeck/bootstrap/jersey-client-1.19.3.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-client-1.19.3.jar", "md5sum": "8e634c2c7213f447b37ea40dfe0945b8", "mode": "0644", "msg": "OK (133824 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 133824, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526863.7-178889136912974/tmpmCmx_Y", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-client-1.19.3.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-core-1.19.3.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "b349a0676f4de60ce0ab5d36caf508bf90251c59", "dest": "/var/lib/rundeck/bootstrap/jersey-core-1.19.3.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-core-1.19.3.jar", "md5sum": "97a92c7a6c213e1d63791f747d5c4fde", "mode": "0644", "msg": "OK (434518 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 434518, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526866.5-226218917466016/tmpFWgpdo", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jersey-core-1.19.3.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jsr311-api-1.1.1.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "59033da2a1afd56af1ac576750a8d0b1830d59e6", "dest": "/var/lib/rundeck/bootstrap/jsr311-api-1.1.1.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jsr311-api-1.1.1.jar", "md5sum": "c9803468299ec255c047a280ddec510f", "mode": "0644", "msg": "OK (46367 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 46367, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526869.54-21243862425780/tmpuN0XVt", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/jsr311-api-1.1.1.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/slf4j-api-1.7.5.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "6b262da268f8ad9eff941b25503a9198f0a0ac93", "dest": "/var/lib/rundeck/bootstrap/slf4j-api-1.7.5.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/slf4j-api-1.7.5.jar", "md5sum": "3b1ececad9ebc3fbad2953ccf4a070ca", "mode": "0644", "msg": "OK (26084 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 26084, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526872.19-112754071128073/tmpqEMXNM", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/slf4j-api-1.7.5.jar"}
    # changed: [atlassian1] => (item=https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/slf4j-simple-1.7.5.jar) => {"changed": true, "checksum_dest": null, "checksum_src": "4a950c50bbc67fdbc908190dc8e25d7a0251f74a", "dest": "/var/lib/rundeck/bootstrap/slf4j-simple-1.7.5.jar", "gid": 10006, "group": "rundeck", "item": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/slf4j-simple-1.7.5.jar", "md5sum": "34688046949b94e90250924e32da85d5", "mode": "0644", "msg": "OK (10680 bytes)", "owner": "rundeck", "secontext": "system_u:object_r:var_lib_t:s0", "size": 10680, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526874.76-161524812179098/tmpfKpIQu", "state": "file", "status_code": 200, "uid": 10006, "url": "https://github.com/realloc/crowd-jaas/releases/download/v0.0.2/slf4j-simple-1.7.5.jar"}
    # 
    # TASK [modified.neel.rundeck : ensure Crowd login module configuration exists] ******
    # changed: [atlassian1] => {"changed": true, "checksum": "443bd24c1319daca9e51c98921b26181acff4386", "dest": "/etc/rundeck/jaas-crowd.conf", "gid": 10006, "group": "rundeck", "md5sum": "61e1c2c338643438a9d28e0a12e9d25d", "mode": "0600", "owner": "rundeck", "secontext": "system_u:object_r:etc_t:s0", "size": 248, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526877.49-81191357092414/source", "state": "file", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : ensure profile is updated to use CROWD configuration] ***
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
    # 
    # TASK [modified.neel.rundeck : ensure profile is updated to use CROWD module] *******
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line replaced"}
    # 
    # TASK [modified.neel.rundeck : replace default user group with crowd user group] ****
    # changed: [atlassian1] => {"backup_file": "/var/lib/rundeck/exp/webapp/WEB-INF/web.xml.31296.2018-11-18@07:41:19~", "changed": true, "msg": "1 replacements made"}
    # 
    # TASK [modified.neel.rundeck : replace default admin group with crowd admin group] ***
    # changed: [atlassian1] => (item=/etc/rundeck/admin.aclpolicy) => {"backup_file": "/etc/rundeck/admin.aclpolicy.31371.2018-11-18@07:41:20~", "changed": true, "item": "/etc/rundeck/admin.aclpolicy", "msg": "2 replacements made"}
    # changed: [atlassian1] => (item=/etc/rundeck/apitoken.aclpolicy) => {"backup_file": "/etc/rundeck/apitoken.aclpolicy.31446.2018-11-18@07:41:20~", "changed": true, "item": "/etc/rundeck/apitoken.aclpolicy", "msg": "2 replacements made"}
    # 
    # TASK [modified.neel.rundeck : set context directory of rundeck installation] *******
    # changed: [atlassian1] => {"backup": "", "changed": true, "msg": "line added"}
    # 
    # TASK [modified.neel.rundeck : download rundeck plugins] ****************************
    # 
    # TASK [modified.neel.rundeck : Rundeck | Ensure .ssh directory exists] **************
    # ok: [atlassian1] => {"changed": false, "gid": 10006, "group": "rundeck", "mode": "0700", "owner": "rundeck", "path": "/var/lib/rundeck/.ssh", "secontext": "system_u:object_r:ssh_home_t:s0", "size": 76, "state": "directory", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : generate a ssh key] **********************************
    # ok: [atlassian1] => {"append": false, "changed": false, "comment": "", "group": 10006, "home": "/var/lib/rundeck", "move_home": false, "name": "rundeck", "shell": "/bin/bash", "ssh_fingerprint": "2048 8e:db:3e:f2:37:f1:c4:b0:14:49:50:fe:56:99:15:d9   (RSA)", "ssh_key_file": "/var/lib/rundeck/.ssh/id_rsa", "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKpMAGjgBpq2IQbw7q6mR4Kunxhd00GsqSUmnzSgCRW8H2AISS2Uat+QGlJkuiZ7P3qQivmeSwbBygv2Xj3kWCRWA5yliLHZj8oJ2u8MbZ0TC4cM8WVmNRYLcA1X5zCxIj1ga8r07SVw8oXLK/xgy+XBMYM7W13ti+rjDTDIbQU+Mu6WYl/hs42puEPV5O1jdn0bim9fMjduEzrEPzXidRtcsTZu97hcoiupZx00evgcxBwjVCiT4vK5MzWHfr8B3r0pvjXlpT6U6+VyxBVpG/z/1ha8UwkVeiBl57En5vuMJ3SPhDdDjr2Lk0TuZBfhxa+KlbTW2V9nuq8KRuBWRB", "state": "present", "uid": 10006}
    # 
    # TASK [modified.neel.rundeck : configure email servers] *****************************
    # changed: [atlassian1] => {"changed": true, "msg": "Block inserted"}
    # 
    # TASK [geerlingguy.docker : Ensure old versions of Docker are not installed.] *******
    # ok: [atlassian1] => (item=docker) => {"changed": false, "item": "docker", "msg": "", "rc": 0, "results": ["docker is not installed"]}
    # ok: [atlassian1] => (item=docker-common) => {"changed": false, "item": "docker-common", "msg": "", "rc": 0, "results": ["docker-common is not installed"]}
    # ok: [atlassian1] => (item=container-selinux) => {"changed": false, "item": "container-selinux", "msg": "", "rc": 0, "results": ["container-selinux is not installed"]}
    # ok: [atlassian1] => (item=docker-selinux) => {"changed": false, "item": "docker-selinux", "msg": "", "rc": 0, "results": ["docker-selinux is not installed"]}
    # ok: [atlassian1] => (item=docker-engine) => {"changed": false, "item": "docker-engine", "msg": "", "rc": 0, "results": ["docker-engine is not installed"]}
    # 
    # TASK [geerlingguy.docker : Add Docker GPG key.] ************************************
    # changed: [atlassian1] => {"changed": true}
    # 
    # TASK [geerlingguy.docker : Add Docker repository.] *********************************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "b9cab0cb1ddbffb77de51ba8838ea60335a229f6", "dest": "/etc/yum.repos.d/docker-ce.repo", "gid": 0, "group": "root", "md5sum": "bbb0224eb355f307b39eed429c61be09", "mode": "0644", "msg": "OK (2424 bytes)", "owner": "root", "secontext": "system_u:object_r:system_conf_t:s0", "size": 2424, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542526888.84-166356558619937/tmpJb4a96", "state": "file", "status_code": 200, "uid": 0, "url": "https://download.docker.com/linux/centos/docker-ce.repo"}
    # 
    # TASK [geerlingguy.docker : Configure Docker Edge repo.] ****************************
    # changed: [atlassian1] => {"changed": true, "gid": 0, "group": "root", "mode": "0644", "msg": "option changed", "owner": "root", "path": "/etc/yum.repos.d/docker-ce.repo", "secontext": "system_u:object_r:system_conf_t:s0", "size": 2426, "state": "file", "uid": 0}
    # 
    # TASK [geerlingguy.docker : Configure Docker Test repo.] ****************************
    # changed: [atlassian1] => {"changed": true, "gid": 0, "group": "root", "mode": "0644", "msg": "option changed", "owner": "root", "path": "/etc/yum.repos.d/docker-ce.repo", "secontext": "system_u:object_r:system_conf_t:s0", "size": 2428, "state": "file", "uid": 0}
    # 
    # TASK [geerlingguy.docker : Ensure old versions of Docker are not installed.] *******
    # skipping: [atlassian1] => (item=docker)  => {"changed": false, "item": "docker", "skip_reason": "Conditional result was False"}
    # skipping: [atlassian1] => (item=docker-engine)  => {"changed": false, "item": "docker-engine", "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Ensure depdencies are installed.] ***********************
    # [DEPRECATION WARNING]: Invoking "apt" only once while using a loop via 
    # squash_actions is deprecated. Instead of using a loop to supply multiple items and 
    # specifying `name: {{ item }}`, please use `name: [u'apt-transport-https', u'ca-
    # certificates']` and remove the loop. This feature will be removed in version 2.11. 
    # Deprecation warnings can be disabled by setting deprecation_warnings=False in 
    # ansible.cfg.
    # skipping: [atlassian1] => (item=[])  => {"changed": false, "item": [], "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Add Docker apt key.] ************************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Ensure curl is present (on older systems without SNI).] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Add Docker apt key (alternative for older systems without SNI).] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Add Docker repository.] *********************************
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Install Docker.] ****************************************
    # changed: [atlassian1] => {"changed": true, "msg": "", "rc": 0, "results": ["Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.fra10.de.leaseweb.net\n * epel: mirror.23media.de\n * extras: mirror.23media.de\n * updates: ftp.rz.uni-frankfurt.de\nResolving Dependencies\n--> Running transaction check\n---> Package docker-ce.x86_64 3:18.09.0-3.el7 will be installed\n--> Processing Dependency: container-selinux >= 2.9 for package: 3:docker-ce-18.09.0-3.el7.x86_64\n--> Processing Dependency: containerd.io for package: 3:docker-ce-18.09.0-3.el7.x86_64\n--> Processing Dependency: docker-ce-cli for package: 3:docker-ce-18.09.0-3.el7.x86_64\n--> Processing Dependency: libseccomp.so.2()(64bit) for package: 3:docker-ce-18.09.0-3.el7.x86_64\n--> Running transaction check\n---> Package container-selinux.noarch 2:2.68-1.el7 will be installed\n--> Processing Dependency: selinux-policy-targeted >= 3.13.1-192 for package: 2:container-selinux-2.68-1.el7.noarch\n--> Processing Dependency: selinux-policy-base >= 3.13.1-192 for package: 2:container-selinux-2.68-1.el7.noarch\n--> Processing Dependency: selinux-policy >= 3.13.1-192 for package: 2:container-selinux-2.68-1.el7.noarch\n---> Package containerd.io.x86_64 0:1.2.0-3.el7 will be installed\n---> Package docker-ce-cli.x86_64 1:18.09.0-3.el7 will be installed\n--> Processing Dependency: libltdl.so.7()(64bit) for package: 1:docker-ce-cli-18.09.0-3.el7.x86_64\n---> Package libseccomp.x86_64 0:2.3.1-3.el7 will be installed\n--> Running transaction check\n---> Package libtool-ltdl.x86_64 0:2.4.2-22.el7_3 will be installed\n---> Package selinux-policy.noarch 0:3.13.1-102.el7_3.16 will be updated\n---> Package selinux-policy.noarch 0:3.13.1-192.el7_5.6 will be an update\n--> Processing Dependency: policycoreutils >= 2.5-18 for package: selinux-policy-3.13.1-192.el7_5.6.noarch\n---> Package selinux-policy-targeted.noarch 0:3.13.1-102.el7_3.16 will be updated\n---> Package selinux-policy-targeted.noarch 0:3.13.1-192.el7_5.6 will be an update\n--> Running transaction check\n---> Package policycoreutils.x86_64 0:2.5-11.el7_3 will be updated\n--> Processing Dependency: policycoreutils = 2.5-11.el7_3 for package: policycoreutils-python-2.5-11.el7_3.x86_64\n---> Package policycoreutils.x86_64 0:2.5-22.el7 will be an update\n--> Running transaction check\n---> Package policycoreutils-python.x86_64 0:2.5-11.el7_3 will be updated\n--> Processing Dependency: policycoreutils-python = 2.5-11.el7_3 for package: policycoreutils-devel-2.5-11.el7_3.x86_64\n---> Package policycoreutils-python.x86_64 0:2.5-22.el7 will be an update\n--> Processing Dependency: setools-libs >= 3.3.8-2 for package: policycoreutils-python-2.5-22.el7.x86_64\n--> Processing Dependency: libsemanage-python >= 2.5-9 for package: policycoreutils-python-2.5-22.el7.x86_64\n--> Running transaction check\n---> Package libsemanage-python.x86_64 0:2.5-5.1.el7_3 will be updated\n---> Package libsemanage-python.x86_64 0:2.5-11.el7 will be an update\n--> Processing Dependency: libsemanage = 2.5-11.el7 for package: libsemanage-python-2.5-11.el7.x86_64\n---> Package policycoreutils-devel.x86_64 0:2.5-11.el7_3 will be updated\n---> Package policycoreutils-devel.x86_64 0:2.5-22.el7 will be an update\n---> Package setools-libs.x86_64 0:3.3.8-1.1.el7 will be updated\n---> Package setools-libs.x86_64 0:3.3.8-2.el7 will be an update\n--> Running transaction check\n---> Package libsemanage.x86_64 0:2.5-5.1.el7_3 will be updated\n---> Package libsemanage.x86_64 0:2.5-11.el7 will be an update\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                  Arch    Version               Repository         Size\n================================================================================\nInstalling:\n docker-ce                x86_64  3:18.09.0-3.el7       docker-ce-stable   19 M\nInstalling for dependencies:\n container-selinux        noarch  2:2.68-1.el7          extras             36 k\n containerd.io            x86_64  1.2.0-3.el7           docker-ce-stable   22 M\n docker-ce-cli            x86_64  1:18.09.0-3.el7       docker-ce-stable   14 M\n libseccomp               x86_64  2.3.1-3.el7           base               56 k\n libtool-ltdl             x86_64  2.4.2-22.el7_3        base               49 k\nUpdating for dependencies:\n libsemanage              x86_64  2.5-11.el7            base              150 k\n libsemanage-python       x86_64  2.5-11.el7            base              112 k\n policycoreutils          x86_64  2.5-22.el7            base              867 k\n policycoreutils-devel    x86_64  2.5-22.el7            base              333 k\n policycoreutils-python   x86_64  2.5-22.el7            base              454 k\n selinux-policy           noarch  3.13.1-192.el7_5.6    updates           453 k\n selinux-policy-targeted  noarch  3.13.1-192.el7_5.6    updates           6.6 M\n setools-libs             x86_64  3.3.8-2.el7           base              619 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package  (+5 Dependent packages)\nUpgrade             ( 8 Dependent packages)\n\nTotal download size: 64 M\nDownloading packages:\nDelta RPMs disabled because /usr/bin/applydeltarpm not installed.\n--------------------------------------------------------------------------------\nTotal                                              5.6 MB/s |  64 MB  00:11     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Updating   : libsemanage-2.5-11.el7.x86_64                               1/22 \n  Updating   : policycoreutils-2.5-22.el7.x86_64                           2/22 \n  Updating   : selinux-policy-3.13.1-192.el7_5.6.noarch                    3/22 \n  Installing : containerd.io-1.2.0-3.el7.x86_64                            4/22 \n  Updating   : selinux-policy-targeted-3.13.1-192.el7_5.6.noarch           5/22 \n  Updating   : libsemanage-python-2.5-11.el7.x86_64                        6/22 \n  Installing : libtool-ltdl-2.4.2-22.el7_3.x86_64                          7/22 \n  Installing : 1:docker-ce-cli-18.09.0-3.el7.x86_64                        8/22 \n  Installing : libseccomp-2.3.1-3.el7.x86_64                               9/22 \n  Updating   : setools-libs-3.3.8-2.el7.x86_64                            10/22 \n  Updating   : policycoreutils-python-2.5-22.el7.x86_64                   11/22 \n  Installing : 2:container-selinux-2.68-1.el7.noarch                      12/22 \n  Installing : 3:docker-ce-18.09.0-3.el7.x86_64                           13/22 \n  Updating   : policycoreutils-devel-2.5-22.el7.x86_64                    14/22 \n  Cleanup    : selinux-policy-targeted-3.13.1-102.el7_3.16.noarch         15/22 \n  Cleanup    : selinux-policy-3.13.1-102.el7_3.16.noarch                  16/22 \n  Cleanup    : policycoreutils-devel-2.5-11.el7_3.x86_64                  17/22 \n  Cleanup    : policycoreutils-python-2.5-11.el7_3.x86_64                 18/22 \n  Cleanup    : libsemanage-python-2.5-5.1.el7_3.x86_64                    19/22 \n  Cleanup    : policycoreutils-2.5-11.el7_3.x86_64                        20/22 \n  Cleanup    : libsemanage-2.5-5.1.el7_3.x86_64                           21/22 \n  Cleanup    : setools-libs-3.3.8-1.1.el7.x86_64                          22/22 \n  Verifying  : libsemanage-python-2.5-11.el7.x86_64                        1/22 \n  Verifying  : 3:docker-ce-18.09.0-3.el7.x86_64                            2/22 \n  Verifying  : libsemanage-2.5-11.el7.x86_64                               3/22 \n  Verifying  : setools-libs-3.3.8-2.el7.x86_64                             4/22 \n  Verifying  : 2:container-selinux-2.68-1.el7.noarch                       5/22 \n  Verifying  : libseccomp-2.3.1-3.el7.x86_64                               6/22 \n  Verifying  : containerd.io-1.2.0-3.el7.x86_64                            7/22 \n  Verifying  : policycoreutils-2.5-22.el7.x86_64                           8/22 \n  Verifying  : policycoreutils-python-2.5-22.el7.x86_64                    9/22 \n  Verifying  : libtool-ltdl-2.4.2-22.el7_3.x86_64                         10/22 \n  Verifying  : selinux-policy-targeted-3.13.1-192.el7_5.6.noarch          11/22 \n  Verifying  : policycoreutils-devel-2.5-22.el7.x86_64                    12/22 \n  Verifying  : 1:docker-ce-cli-18.09.0-3.el7.x86_64                       13/22 \n  Verifying  : selinux-policy-3.13.1-192.el7_5.6.noarch                   14/22 \n  Verifying  : selinux-policy-3.13.1-102.el7_3.16.noarch                  15/22 \n  Verifying  : policycoreutils-python-2.5-11.el7_3.x86_64                 16/22 \n  Verifying  : policycoreutils-2.5-11.el7_3.x86_64                        17/22 \n  Verifying  : policycoreutils-devel-2.5-11.el7_3.x86_64                  18/22 \n  Verifying  : selinux-policy-targeted-3.13.1-102.el7_3.16.noarch         19/22 \n  Verifying  : libsemanage-2.5-5.1.el7_3.x86_64                           20/22 \n  Verifying  : libsemanage-python-2.5-5.1.el7_3.x86_64                    21/22 \n  Verifying  : setools-libs-3.3.8-1.1.el7.x86_64                          22/22 \n\nInstalled:\n  docker-ce.x86_64 3:18.09.0-3.el7                                              \n\nDependency Installed:\n  container-selinux.noarch 2:2.68-1.el7    containerd.io.x86_64 0:1.2.0-3.el7   \n  docker-ce-cli.x86_64 1:18.09.0-3.el7     libseccomp.x86_64 0:2.3.1-3.el7      \n  libtool-ltdl.x86_64 0:2.4.2-22.el7_3    \n\nDependency Updated:\n  libsemanage.x86_64 0:2.5-11.el7                                               \n  libsemanage-python.x86_64 0:2.5-11.el7                                        \n  policycoreutils.x86_64 0:2.5-22.el7                                           \n  policycoreutils-devel.x86_64 0:2.5-22.el7                                     \n  policycoreutils-python.x86_64 0:2.5-22.el7                                    \n  selinux-policy.noarch 0:3.13.1-192.el7_5.6                                    \n  selinux-policy-targeted.noarch 0:3.13.1-192.el7_5.6                           \n  setools-libs.x86_64 0:3.3.8-2.el7                                             \n\nComplete!\n"]}
    # 
    # TASK [geerlingguy.docker : Ensure Docker is started and enabled at boot.] **********
    # changed: [atlassian1] => {"changed": true, "enabled": true, "name": "docker", "state": "started", "status": {"ActiveEnterTimestampMonotonic": "0", "ActiveExitTimestampMonotonic": "0", "ActiveState": "inactive", "After": "network-online.target systemd-journald.socket system.slice basic.target firewalld.service", "AllowIsolate": "no", "AssertResult": "no", "AssertTimestampMonotonic": "0", "Before": "shutdown.target", "BindsTo": "containerd.service", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "yes", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "no", "ConditionTimestampMonotonic": "0", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "yes", "Description": "Docker Application Container Engine", "DevicePolicy": "auto", "Documentation": "https://docs.docker.com", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "0", "ExecMainStartTimestampMonotonic": "0", "ExecMainStatus": "0", "ExecReload": "{ path=/bin/kill ; argv[]=/bin/kill -s HUP $MAINPID ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStart": "{ path=/usr/bin/dockerd ; argv[]=/usr/bin/dockerd -H unix:// ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/usr/lib/systemd/system/docker.service", "GuessMainPID": "yes", "IOScheduling": "0", "Id": "docker.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "yes", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestampMonotonic": "0", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "process", "KillSignal": "15", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "18446744073709551615", "LimitNPROC": "18446744073709551615", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "31210", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "docker.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "main", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "no", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target", "Restart": "always", "RestartUSec": "2s", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "3", "StartLimitInterval": "60000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TimeoutStartUSec": "0", "TimeoutStopUSec": "0", "TimerSlackNSec": "50000", "Transient": "no", "Type": "notify", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "disabled", "Wants": "network-online.target system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}
    # 
    # TASK [geerlingguy.docker : Check current docker-compose version.] ******************
    # ok: [atlassian1] => {"changed": false, "cmd": "docker-compose --version", "failed_when_result": false, "msg": "[Errno 2] No such file or directory", "rc": 2}
    # 
    # TASK [geerlingguy.docker : Delete existing docker-compose version if it's different.] ***
    # skipping: [atlassian1] => {"changed": false, "skip_reason": "Conditional result was False"}
    # 
    # TASK [geerlingguy.docker : Install Docker Compose (if configured).] ****************
    # changed: [atlassian1] => {"changed": true, "checksum_dest": null, "checksum_src": "51b79ed1ed536dd6bd02cb952bde0fcb66265ce0", "dest": "/usr/local/bin/docker-compose", "gid": 0, "group": "root", "md5sum": "13196d9b1c3f3be0964b7536c39348b5", "mode": "0755", "msg": "OK (8273264 bytes)", "owner": "root", "secontext": "system_u:object_r:bin_t:s0", "size": 8273264, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1542527064.61-162329265518210/tmpvzqaa8", "state": "file", "status_code": 200, "uid": 0, "url": "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-Linux-x86_64"}
    # 
    # RUNNING HANDLER [modified.neel.rundeck : start rundeck] ****************************
    # changed: [atlassian1] => {"changed": true, "name": "rundeckd", "state": "started", "status": {"ActiveEnterTimestampMonotonic": "0", "ActiveExitTimestampMonotonic": "0", "ActiveState": "inactive", "After": "systemd-journald.socket system.slice network.service basic.target network-online.target", "AllowIsolate": "no", "AssertResult": "no", "AssertTimestampMonotonic": "0", "Before": "confluence.service jexec.service multi-user.target atlbitbucket.service jira.service graphical.target atlbitbucket_search.service shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "no", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "no", "ConditionTimestampMonotonic": "0", "Conflicts": "shutdown.target", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "SYSV: rundeckd, providing rundeckd", "DevicePolicy": "auto", "Documentation": "man:systemd-sysv-generator(8)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "0", "ExecMainStartTimestampMonotonic": "0", "ExecMainStatus": "0", "ExecStart": "{ path=/etc/rc.d/init.d/rundeckd ; argv[]=/etc/rc.d/init.d/rundeckd start ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "ExecStop": "{ path=/etc/rc.d/init.d/rundeckd ; argv[]=/etc/rc.d/init.d/rundeckd stop ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/run/systemd/generator.late/rundeckd.service", "GuessMainPID": "no", "IOScheduling": "0", "Id": "rundeckd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "no", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestampMonotonic": "0", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "process", "KillSignal": "15", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "31210", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "31210", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "0", "MemoryAccounting": "no", "MemoryCurrent": "18446744073709551615", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "rundeckd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "none", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PIDFile": "/var/run/rundeckd.pid", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "no", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "SourcePath": "/etc/rc.d/init.d/rundeckd", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "dead", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TimeoutStartUSec": "5min", "TimeoutStopUSec": "5min", "TimerSlackNSec": "50000", "Transient": "no", "Type": "forking", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "bad", "WantedBy": "graphical.target multi-user.target", "Wants": "system.slice", "WatchdogTimestampMonotonic": "0", "WatchdogUSec": "0"}}
    # 
    # RUNNING HANDLER [modified.neel.rundeck : restart rundeck] **************************
    # changed: [atlassian1] => {"changed": true, "name": "rundeckd", "state": "started", "status": {"ActiveEnterTimestamp": "Sun 2018-11-18 07:44:30 UTC", "ActiveEnterTimestampMonotonic": "162661569921", "ActiveExitTimestampMonotonic": "0", "ActiveState": "active", "After": "systemd-journald.socket system.slice network.service basic.target network-online.target", "AllowIsolate": "no", "AssertResult": "yes", "AssertTimestamp": "Sun 2018-11-18 07:44:30 UTC", "AssertTimestampMonotonic": "162661330390", "Before": "confluence.service jexec.service multi-user.target atlbitbucket.service jira.service graphical.target atlbitbucket_search.service shutdown.target", "BlockIOAccounting": "no", "BlockIOWeight": "18446744073709551615", "CPUAccounting": "no", "CPUQuotaPerSecUSec": "infinity", "CPUSchedulingPolicy": "0", "CPUSchedulingPriority": "0", "CPUSchedulingResetOnFork": "no", "CPUShares": "18446744073709551615", "CanIsolate": "no", "CanReload": "no", "CanStart": "yes", "CanStop": "yes", "CapabilityBoundingSet": "18446744073709551615", "ConditionResult": "yes", "ConditionTimestamp": "Sun 2018-11-18 07:44:30 UTC", "ConditionTimestampMonotonic": "162661330390", "Conflicts": "shutdown.target", "ControlGroup": "/system.slice/rundeckd.service", "ControlPID": "0", "DefaultDependencies": "yes", "Delegate": "no", "Description": "SYSV: rundeckd, providing rundeckd", "DevicePolicy": "auto", "Documentation": "man:systemd-sysv-generator(8)", "ExecMainCode": "0", "ExecMainExitTimestampMonotonic": "0", "ExecMainPID": "1880", "ExecMainStartTimestamp": "Sun 2018-11-18 07:44:30 UTC", "ExecMainStartTimestampMonotonic": "162661569875", "ExecMainStatus": "0", "ExecStart": "{ path=/etc/rc.d/init.d/rundeckd ; argv[]=/etc/rc.d/init.d/rundeckd start ; ignore_errors=no ; start_time=[Sun 2018-11-18 07:44:30 UTC] ; stop_time=[Sun 2018-11-18 07:44:30 UTC] ; pid=1874 ; code=exited ; status=0 }", "ExecStop": "{ path=/etc/rc.d/init.d/rundeckd ; argv[]=/etc/rc.d/init.d/rundeckd stop ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }", "FailureAction": "none", "FileDescriptorStoreMax": "0", "FragmentPath": "/run/systemd/generator.late/rundeckd.service", "GuessMainPID": "no", "IOScheduling": "0", "Id": "rundeckd.service", "IgnoreOnIsolate": "no", "IgnoreOnSnapshot": "no", "IgnoreSIGPIPE": "no", "InactiveEnterTimestampMonotonic": "0", "InactiveExitTimestamp": "Sun 2018-11-18 07:44:30 UTC", "InactiveExitTimestampMonotonic": "162661331602", "JobTimeoutAction": "none", "JobTimeoutUSec": "0", "KillMode": "process", "KillSignal": "15", "LimitAS": "18446744073709551615", "LimitCORE": "18446744073709551615", "LimitCPU": "18446744073709551615", "LimitDATA": "18446744073709551615", "LimitFSIZE": "18446744073709551615", "LimitLOCKS": "18446744073709551615", "LimitMEMLOCK": "65536", "LimitMSGQUEUE": "819200", "LimitNICE": "0", "LimitNOFILE": "4096", "LimitNPROC": "31210", "LimitRSS": "18446744073709551615", "LimitRTPRIO": "0", "LimitRTTIME": "18446744073709551615", "LimitSIGPENDING": "31210", "LimitSTACK": "18446744073709551615", "LoadState": "loaded", "MainPID": "1880", "MemoryAccounting": "no", "MemoryCurrent": "786432", "MemoryLimit": "18446744073709551615", "MountFlags": "0", "Names": "rundeckd.service", "NeedDaemonReload": "no", "Nice": "0", "NoNewPrivileges": "no", "NonBlocking": "no", "NotifyAccess": "none", "OOMScoreAdjust": "0", "OnFailureJobMode": "replace", "PIDFile": "/var/run/rundeckd.pid", "PermissionsStartOnly": "no", "PrivateDevices": "no", "PrivateNetwork": "no", "PrivateTmp": "no", "ProtectHome": "no", "ProtectSystem": "no", "RefuseManualStart": "no", "RefuseManualStop": "no", "RemainAfterExit": "no", "Requires": "basic.target", "Restart": "no", "RestartUSec": "100ms", "Result": "success", "RootDirectoryStartOnly": "no", "RuntimeDirectoryMode": "0755", "SameProcessGroup": "no", "SecureBits": "0", "SendSIGHUP": "no", "SendSIGKILL": "yes", "Slice": "system.slice", "SourcePath": "/etc/rc.d/init.d/rundeckd", "StandardError": "inherit", "StandardInput": "null", "StandardOutput": "journal", "StartLimitAction": "none", "StartLimitBurst": "5", "StartLimitInterval": "10000000", "StartupBlockIOWeight": "18446744073709551615", "StartupCPUShares": "18446744073709551615", "StatusErrno": "0", "StopWhenUnneeded": "no", "SubState": "running", "SyslogLevelPrefix": "yes", "SyslogPriority": "30", "SystemCallErrorNumber": "0", "TTYReset": "no", "TTYVHangup": "no", "TTYVTDisallocate": "no", "TimeoutStartUSec": "5min", "TimeoutStopUSec": "5min", "TimerSlackNSec": "50000", "Transient": "no", "Type": "forking", "UMask": "0022", "UnitFilePreset": "disabled", "UnitFileState": "bad", "WantedBy": "graphical.target multi-user.target", "Wants": "system.slice", "WatchdogTimestamp": "Sun 2018-11-18 07:44:30 UTC", "WatchdogTimestampMonotonic": "162661569894", "WatchdogUSec": "0"}}
    # 
    # PLAY RECAP *************************************************************************
    # atlassian1                 : ok=43   changed=36   unreachable=0    failed=0   

You can change **host** and **cd\_user** according to your environment. After the
playbook has been finished Rundeck is accessible via

<http://192.168.56.31:4440/rundeck>


<a id="org0f33ff5"></a>

## Configure and Start Minishift


<a id="orgb60477d"></a>

### Configure Minishift

First you have to install **Minishift**. You have to use a **Minishift** version >=1.14.0, 
so **openshift** v3.9.0 (see below) is supported.

    minishift version

    # minishift v1.26.1+1e20f27

To do so, follow the installation instructions of the **Minishift Getting Started guide**.

Before you start up Minishift with the minishift start command you will have to
create or modify a `config.json` file. This file is located in the
`.minishift/config` folder in the user home directory. On a Windows system, you
will find this file under `C:\Users\<username>\.minishift\config\config.json` or
under **cygwin** in `~/.minishift/config/config.json`. Minishift also honours the
environment variable **MINISHIFT\_HOME**, and when set it takes precedence, so
`config.json` will be searched in `MINISHIFT_HOME/config/config.json`.

    env | grep MINISHIFT_HOME

    # MINISHIFT_HOME=D:\misc\openshift\.minishift

If the file doesn’t exist, you will have to create it. The file has to have the
following content:

It is important to use v3.9.0 as minimum version to ensure, that the templates
provided by the OpenDevStack work properly. If you are on windows you have to
run the “minishift start” command as administrator.

    {
        "cpus": 2,
        "memory": "8192",
        "openshift-version": "v3.9.0",
        "disk-size": "40GB",
        "vm-driver": "virtualbox"
    }


<a id="orgc516ec4"></a>

### Create new Minishift Profile - opendevstack

    minishift profile set opendevstack

    # Profile 'opendevstack' set as active profile.

    minishift config set memory 8192

    # No Minishift instance exists. New 'memory' setting will be applied on next 'minishift start'

    minishift config set cpus 2

    # No Minishift instance exists. New 'cpus' setting will be applied on next 'minishift start'

    minishift config set disk-size 40GB

    # No Minishift instance exists. New 'disk-size' setting will be applied on next 'minishift start'

    minishift config set vm-driver virtualbox

    # No Minishift instance exists. New 'vm-driver' setting will be applied on next 'minishift start'

There is actually already v3.11.0 available&#x2026;

    minishift config set openshift-version v3.10.0

    minishift profile list

    # - minishift	Running
    # - opendevstack	Does Not Exist	(Active)

    minishift profile set minishift

    # Profile 'minishift' set as active profile.

    minishift profile list

    # - minishift	Running		(Active)
    # - opendevstack	Does Not Exist

    minishift stop

    # Stopping the OpenShift cluster...
    # Cluster stopped.

    minishift profile set opendevstack

    # Profile 'opendevstack' set as active profile.


<a id="org6b5b963"></a>

### Start Minishift

    minishift start

    # -- Starting profile 'opendevstack'
    # -- Check if deprecated options are used ... OK
    # -- Checking if https://github.com is reachable ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is valid ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is supported ... OK
    # -- Checking if requested hypervisor 'virtualbox' is supported on this platform ... OK
    # -- Checking if VirtualBox is installed ... OK
    # -- Checking the ISO URL ... OK
    # -- Downloading OpenShift binary 'oc' version 'v3.10.0'
    #  23.94 MiB / 23.94 MiB  100.00% 0s-- Downloading OpenShift v3.10.0 checksums ... OK
    # -- Checking if provided oc flags are supported ... OK
    # -- Starting the OpenShift cluster using 'virtualbox' hypervisor ...
    # -- Minishift VM will be configured with ...
    #    Memory:    8 GB
    #    vCPUs :    2
    #    Disk size: 40 GB
    # -- Starting Minishift VM ............................................... OK
    # -- Checking for IP address ... OK
    # -- Checking for nameservers ... OK
    # -- Checking if external host is reachable from the Minishift VM ... 
    #    Pinging 8.8.8.8 ... OK
    # -- Checking HTTP connectivity from the VM ... 
    #    Retrieving http://minishift.io/index.html ... OK
    # -- Checking if persistent storage volume is mounted ... OK
    # -- Checking available disk space ... 1% used OK
    # -- Writing current configuration for static assignment of IP address ... OK
    #    Importing 'openshift/origin-control-plane:v3.10.0' . CACHE MISS
    #    Importing 'openshift/origin-docker-registry:v3.10.0' . CACHE MISS
    #    Importing 'openshift/origin-haproxy-router:v3.10.0' . CACHE MISS
    # -- OpenShift cluster will be configured with ...
    #    Version: v3.10.0
    # -- Pulling the Openshift Container Image ....................... OK
    # -- Copying oc binary from the OpenShift container image to VM ... OK
    # -- Starting OpenShift cluster .............................................................
    # Getting a Docker client ...
    # Checking if image openshift/origin-control-plane:v3.10.0 is available ...
    # Pulling image openshift/origin-cli:v3.10.0
    # Image pull complete
    # Pulling image openshift/origin-node:v3.10.0
    # Pulled 2/6 layers, 34% complete
    # Pulled 3/6 layers, 55% complete
    # Pulled 4/6 layers, 85% complete
    # Pulled 5/6 layers, 99% complete
    # Pulled 6/6 layers, 100% complete
    # Extracting
    # Image pull complete
    # Checking type of volume mount ...
    # Determining server IP ...
    # Using public hostname IP 192.168.99.100 as the host IP
    # Checking if OpenShift is already running ...
    # Checking for supported Docker version (=>1.22) ...
    # Checking if insecured registry is configured properly in Docker ...
    # Checking if required ports are available ...
    # Checking if OpenShift client is configured properly ...
    # Checking if image openshift/origin-control-plane:v3.10.0 is available ...
    # Starting OpenShift using openshift/origin-control-plane:v3.10.0 ...
    # I1118 09:45:54.507937    2501 config.go:42] Running "create-master-config"
    # I1118 09:45:57.013856    2501 config.go:46] Running "create-node-config"
    # I1118 09:45:58.557739    2501 flags.go:30] Running "create-kubelet-flags"
    # I1118 09:45:59.241368    2501 run_kubelet.go:48] Running "start-kubelet"
    # I1118 09:45:59.415972    2501 run_self_hosted.go:172] Waiting for the kube-apiserver to be ready ...
    # I1118 09:47:00.420512    2501 interface.go:26] Installing "kube-proxy" ...
    # I1118 09:47:00.420539    2501 interface.go:26] Installing "kube-dns" ...
    # I1118 09:47:00.420546    2501 interface.go:26] Installing "openshift-apiserver" ...
    # I1118 09:47:00.420568    2501 apply_template.go:83] Installing "openshift-apiserver"
    # I1118 09:47:00.422154    2501 apply_template.go:83] Installing "kube-proxy"
    # I1118 09:47:00.423576    2501 apply_template.go:83] Installing "kube-dns"
    # I1118 09:47:03.495935    2501 interface.go:41] Finished installing "kube-proxy" "kube-dns" "openshift-apiserver"
    # I1118 09:48:13.532776    2501 run_self_hosted.go:224] openshift-apiserver available
    # I1118 09:48:13.533609    2501 interface.go:26] Installing "openshift-controller-manager" ...
    # I1118 09:48:13.533638    2501 apply_template.go:83] Installing "openshift-controller-manager"
    # I1118 09:48:16.362893    2501 interface.go:41] Finished installing "openshift-controller-manager"
    # Adding default OAuthClient redirect URIs ...
    # Adding router ...
    # Adding sample-templates ...
    # Adding centos-imagestreams ...
    # Adding registry ...
    # Adding web-console ...
    # Adding persistent-volumes ...
    # I1118 09:48:16.384108    2501 interface.go:26] Installing "openshift-router" ...
    # I1118 09:48:16.384117    2501 interface.go:26] Installing "sample-templates" ...
    # I1118 09:48:16.384123    2501 interface.go:26] Installing "centos-imagestreams" ...
    # I1118 09:48:16.384128    2501 interface.go:26] Installing "openshift-image-registry" ...
    # I1118 09:48:16.384136    2501 interface.go:26] Installing "openshift-web-console-operator" ...
    # I1118 09:48:16.384142    2501 interface.go:26] Installing "persistent-volumes" ...
    # I1118 09:48:16.384704    2501 interface.go:26] Installing "sample-templates/rails quickstart" ...
    # I1118 09:48:16.384714    2501 interface.go:26] Installing "sample-templates/jenkins pipeline ephemeral" ...
    # I1118 09:48:16.384720    2501 interface.go:26] Installing "sample-templates/mariadb" ...
    # I1118 09:48:16.384725    2501 interface.go:26] Installing "sample-templates/mysql" ...
    # I1118 09:48:16.384731    2501 interface.go:26] Installing "sample-templates/cakephp quickstart" ...
    # I1118 09:48:16.384737    2501 interface.go:26] Installing "sample-templates/dancer quickstart" ...
    # I1118 09:48:16.384742    2501 interface.go:26] Installing "sample-templates/django quickstart" ...
    # I1118 09:48:16.384748    2501 interface.go:26] Installing "sample-templates/mongodb" ...
    # I1118 09:48:16.384753    2501 interface.go:26] Installing "sample-templates/postgresql" ...
    # I1118 09:48:16.384759    2501 interface.go:26] Installing "sample-templates/nodejs quickstart" ...
    # I1118 09:48:16.384765    2501 interface.go:26] Installing "sample-templates/sample pipeline" ...
    # I1118 09:48:16.384808    2501 apply_list.go:68] Installing "sample-templates/sample pipeline"
    # I1118 09:48:16.385041    2501 apply_list.go:68] Installing "centos-imagestreams"
    # I1118 09:48:16.385777    2501 apply_template.go:83] Installing "openshift-web-console-operator"
    # I1118 09:48:16.385974    2501 apply_list.go:68] Installing "sample-templates/rails quickstart"
    # I1118 09:48:16.386076    2501 apply_list.go:68] Installing "sample-templates/jenkins pipeline ephemeral"
    # I1118 09:48:16.386160    2501 apply_list.go:68] Installing "sample-templates/mariadb"
    # I1118 09:48:16.386241    2501 apply_list.go:68] Installing "sample-templates/mysql"
    # I1118 09:48:16.386327    2501 apply_list.go:68] Installing "sample-templates/cakephp quickstart"
    # I1118 09:48:16.386406    2501 apply_list.go:68] Installing "sample-templates/dancer quickstart"
    # I1118 09:48:16.386557    2501 apply_list.go:68] Installing "sample-templates/django quickstart"
    # I1118 09:48:16.386641    2501 apply_list.go:68] Installing "sample-templates/mongodb"
    # I1118 09:48:16.386725    2501 apply_list.go:68] Installing "sample-templates/postgresql"
    # I1118 09:48:16.386806    2501 apply_list.go:68] Installing "sample-templates/nodejs quickstart"
    # I1118 09:48:29.943455    2501 interface.go:41] Finished installing "sample-templates/rails quickstart" "sample-templates/jenkins pipeline ephemeral" "sample-templates/mariadb" "sample-templates/mysql" "sample-templates/cakephp quickstart" "sample-templates/dancer quickstart" "sample-templates/django quickstart" "sample-templates/mongodb" "sample-templates/postgresql" "sample-templates/nodejs quickstart" "sample-templates/sample pipeline"
    # I1118 09:49:09.290772    2501 interface.go:41] Finished installing "openshift-router" "sample-templates" "centos-imagestreams" "openshift-image-registry" "openshift-web-console-operator" "persistent-volumes"
    # Login to server ...
    # Creating initial project "myproject" ...
    # Server Information ...
    # OpenShift server started.
    # 
    # The server is accessible via web console at:
    #     https://192.168.99.100:8443
    # 
    # You are logged in as:
    #     User:     developer
    #     Password: <any value>
    # 
    # To login as administrator:
    #     oc login -u system:admin
    # 
    # 
    # -- Exporting of OpenShift images is occuring in background process with pid 20076.

    minishift profile list

    # - minishift	Stopped
    # - opendevstack	Running		(Active)

    tree -a -L 3 /misc/openshift/.minishift/profiles

    # /misc/openshift/.minishift/profiles
    # └── opendevstack
    #     ├── addons
    #     │   ├── admin-user
    #     │   ├── anyuid
    #     │   ├── che
    #     │   ├── htpasswd-identity-provider
    #     │   ├── registry-route
    #     │   └── xpaas
    #     ├── ca.pem
    #     ├── cache
    #     ├── cert.pem
    #     ├── certs
    #     │   ├── ca.pem
    #     │   ├── ca-key.pem
    #     │   ├── cert.pem
    #     │   └── key.pem
    #     ├── config
    #     │   ├── config.json
    #     │   └── opendevstack.json
    #     ├── key.pem
    #     ├── logs
    #     │   └── image-export-2018-11-18-1049-51.log
    #     ├── machines
    #     │   ├── opendevstack
    #     │   ├── opendevstack_kubeconfig
    #     │   ├── opendevstack-state.json
    #     │   ├── server.pem
    #     │   └── server-key.pem
    #     └── tmp
    # 
    # 15 directories, 14 files

    minishift ip

    # 192.168.99.100

    minishift status

    # Minishift:  Running
    # Profile:    opendevstack
    # OpenShift:  Running (openshift v3.10.0+e5b9b2e-81)
    # DiskUsage:  8% of 39G (Mounted On: /mnt/sda1)
    # CacheUsage: 2.893 GB (used by oc binary, ISO or cached images)

    oc version

    # oc v3.11.0+0cbc58b
    # kubernetes v1.11.0+d4cacc0
    # features: Basic-Auth SSPI Kerberos SPNEGO
    # 
    # Server https://192.168.99.100:8443
    # openshift v3.10.0+e5b9b2e-81
    # kubernetes v1.10.0+b81c8f8

    minishift config view

    # - cpus                               : 2
    # - disk-size                          : 40GB
    # - memory                             : 8192
    # - openshift-version                  : v3.10.0
    # - vm-driver                          : virtualbox

    minishift config view --global

    minishift ssh -- docker ps

    # CONTAINER ID        IMAGE                                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
    # 02bda9843833        84a06cc87160                                                                                                         "/usr/bin/origin-w..."   11 minutes ago      Up 11 minutes                           k8s_webconsole_webconsole-68564ddfb8-s7r5q_openshift-web-console_3871fd98-eb17-11e8-b8c7-0800277c436d_0
    # fae09af0f662        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           11 minutes ago      Up 11 minutes                           k8s_POD_webconsole-68564ddfb8-s7r5q_openshift-web-console_3871fd98-eb17-11e8-b8c7-0800277c436d_0
    # f69e41151630        docker.io/openshift/origin-docker-registry@sha256:51c26dc87e3787b1a45373ba60a5db3683b7aa0c1772fba2c9ceb371cc3bb34f   "/bin/sh -c '/usr/..."   11 minutes ago      Up 11 minutes                           k8s_registry_docker-registry-1-bk2m6_default_234c9eb9-eb17-11e8-b8c7-0800277c436d_0
    # a1ac98d44cfb        docker.io/openshift/origin-haproxy-router@sha256:72a2daf2f791843d981efc8316ef41af454ac23857265ca79c7137d6b8f2ab6d    "/usr/bin/openshif..."   11 minutes ago      Up 11 minutes                           k8s_router_router-1-hlfc8_default_2207b062-eb17-11e8-b8c7-0800277c436d_0
    # 744a964fc17f        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           11 minutes ago      Up 11 minutes                           k8s_POD_docker-registry-1-bk2m6_default_234c9eb9-eb17-11e8-b8c7-0800277c436d_0
    # 53a092c60090        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           11 minutes ago      Up 11 minutes                           k8s_POD_router-1-hlfc8_default_2207b062-eb17-11e8-b8c7-0800277c436d_0
    # 681208ce00b0        docker.io/openshift/origin-hypershift@sha256:89cf494e79a80a53938330af724bcb4c7242f54b273d679b9fe0106b32c2bf79        "hypershift experi..."   11 minutes ago      Up 11 minutes                           k8s_operator_openshift-web-console-operator-8cf4ddf7-gn2d9_openshift-core-operators_1c2936fd-eb17-11e8-b8c7-0800277c436d_0
    # 634a33966bb2        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           12 minutes ago      Up 12 minutes                           k8s_POD_openshift-web-console-operator-8cf4ddf7-gn2d9_openshift-core-operators_1c2936fd-eb17-11e8-b8c7-0800277c436d_0
    # 2bc009b0bdb8        docker.io/openshift/origin-hypershift@sha256:89cf494e79a80a53938330af724bcb4c7242f54b273d679b9fe0106b32c2bf79        "hypershift opensh..."   12 minutes ago      Up 12 minutes                           k8s_c_openshift-controller-manager-sz85t_openshift-controller-manager_1314038d-eb17-11e8-b8c7-0800277c436d_0
    # 68954fa6ea77        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           12 minutes ago      Up 12 minutes                           k8s_POD_openshift-controller-manager-sz85t_openshift-controller-manager_1314038d-eb17-11e8-b8c7-0800277c436d_0
    # bf48cb35be93        docker.io/openshift/origin-control-plane@sha256:419a5e7fef555bfd71d7f7dca1bcff2cd877ec3d0a8986e002967649cd4dca08     "openshift start n..."   13 minutes ago      Up 13 minutes                           k8s_kube-proxy_kube-dns-zkt8j_kube-dns_e809a186-eb16-11e8-b8c7-0800277c436d_0
    # 26866ad6de41        docker.io/openshift/origin-hypershift@sha256:89cf494e79a80a53938330af724bcb4c7242f54b273d679b9fe0106b32c2bf79        "hypershift opensh..."   13 minutes ago      Up 13 minutes                           k8s_apiserver_openshift-apiserver-td4hg_openshift-apiserver_e81aad8f-eb16-11e8-b8c7-0800277c436d_0
    # aa1fb1960065        docker.io/openshift/origin-control-plane@sha256:419a5e7fef555bfd71d7f7dca1bcff2cd877ec3d0a8986e002967649cd4dca08     "openshift start n..."   13 minutes ago      Up 13 minutes                           k8s_kube-proxy_kube-proxy-rbt5p_kube-proxy_e8098643-eb16-11e8-b8c7-0800277c436d_0
    # 06502d215070        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           13 minutes ago      Up 13 minutes                           k8s_POD_kube-dns-zkt8j_kube-dns_e809a186-eb16-11e8-b8c7-0800277c436d_0
    # 81bfa67dbacb        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           13 minutes ago      Up 13 minutes                           k8s_POD_openshift-apiserver-td4hg_openshift-apiserver_e81aad8f-eb16-11e8-b8c7-0800277c436d_0
    # 7c943020fa4d        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           13 minutes ago      Up 13 minutes                           k8s_POD_kube-proxy-rbt5p_kube-proxy_e8098643-eb16-11e8-b8c7-0800277c436d_0
    # 9f82f2e749f4        docker.io/openshift/origin-hyperkube@sha256:d32bc6e3d60bdf2c50d45fa9ac66452d42de7d531ec3cedb3450f040cda4c5be         "hyperkube kube-sc..."   13 minutes ago      Up 13 minutes                           k8s_scheduler_kube-scheduler-localhost_kube-system_22d1864680d78e3a95f4c8f358cf4841_0
    # 72249832d1c0        docker.io/openshift/origin-hypershift@sha256:89cf494e79a80a53938330af724bcb4c7242f54b273d679b9fe0106b32c2bf79        "/bin/bash -c '#!/..."   13 minutes ago      Up 13 minutes                           k8s_api_master-api-localhost_kube-system_7264deda1ad6dadcac6b0fe10864226c_0
    # 8c608fb303c0        docker.io/openshift/origin-hyperkube@sha256:d32bc6e3d60bdf2c50d45fa9ac66452d42de7d531ec3cedb3450f040cda4c5be         "hyperkube kube-co..."   14 minutes ago      Up 14 minutes                           k8s_controllers_kube-controller-manager-localhost_kube-system_5a864952b4f82bf9e17484e8dc8105b5_0
    # 9c761bd12371        docker.io/openshift/origin-control-plane@sha256:419a5e7fef555bfd71d7f7dca1bcff2cd877ec3d0a8986e002967649cd4dca08     "/bin/bash -c '#!/..."   14 minutes ago      Up 14 minutes                           k8s_etcd_master-etcd-localhost_kube-system_52fdaf57aef8db8a664d41e178426189_0
    # c490e03fb82d        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           14 minutes ago      Up 14 minutes                           k8s_POD_master-api-localhost_kube-system_7264deda1ad6dadcac6b0fe10864226c_0
    # 94153f616436        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           14 minutes ago      Up 14 minutes                           k8s_POD_kube-controller-manager-localhost_kube-system_5a864952b4f82bf9e17484e8dc8105b5_0
    # 6b7fb87c7fe8        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           14 minutes ago      Up 14 minutes                           k8s_POD_master-etcd-localhost_kube-system_52fdaf57aef8db8a664d41e178426189_0
    # 08e17d35f23b        openshift/origin-pod:v3.10.0                                                                                         "/usr/bin/pod"           14 minutes ago      Up 14 minutes                           k8s_POD_kube-scheduler-localhost_kube-system_22d1864680d78e3a95f4c8f358cf4841_0
    # 939ddc1882d5        openshift/origin-node:v3.10.0                                                                                        "hyperkube kubelet..."   14 minutes ago      Up 14 minutes                           origin

    PATH=/cygdrive/c/Windows/System32:$PATH minishift console

    oc login -u system:admin

    # Logged into "https://192.168.99.100:8443" as "system:admin" using existing credentials.
    # 
    # You have access to the following projects and can switch between them with 'oc project <projectname>':
    # 
    #     default
    #     kube-dns
    #     kube-proxy
    #     kube-public
    #     kube-system
    #   * myproject
    #     openshift
    #     openshift-apiserver
    #     openshift-controller-manager
    #     openshift-core-operators
    #     openshift-infra
    #     openshift-node
    #     openshift-web-console
    # 
    # Using project "myproject".

    oc get nodes

    # NAME        STATUS    ROLES     AGE       VERSION
    # localhost   Ready     <none>    14m       v1.10.0+b81c8f8

    oc get projects

    # NAME                           DISPLAY NAME   STATUS
    # default                                       Active
    # kube-dns                                      Active
    # kube-proxy                                    Active
    # kube-public                                   Active
    # kube-system                                   Active
    # myproject                      My Project     Active
    # openshift                                     Active
    # openshift-apiserver                           Active
    # openshift-controller-manager                  Active
    # openshift-core-operators                      Active
    # openshift-infra                               Active
    # openshift-node                                Active
    # openshift-web-console                         Active

    oc status

    # In project My Project (myproject) on server https://192.168.99.100:8443
    # 
    # You have no services, deployment configs, or build configs.
    # Run 'oc new-app' to create an application.

    cat /misc/openshift/.minishift/profiles/opendevstack/machines/opendevstack_kubeconfig

    # apiVersion: v1
    # clusters:
    # - cluster:
    #     certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM2akNDQWRLZ0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFtTVNRd0lnWURWUVFEREJ0dmNHVnUKYzJocFpuUXRjMmxuYm1WeVFERTFOREkxTXpRek5UUXdIaGNOTVRneE1URTRNRGswTlRVMFdoY05Nak14TVRFMwpNRGswTlRVMVdqQW1NU1F3SWdZRFZRUUREQnR2Y0dWdWMyaHBablF0YzJsbmJtVnlRREUxTkRJMU16UXpOVFF3CmdnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUM0UEMwcmpJMWZVSzZ1QUw5SDJvMSsKMFZpYm9WTmZ6c3ZvSnZ3WEg5Vjd3eXJ3aDhtYTB5VHRJd2FSMnB0QSs4MmdwRHhiTlN6VGtJOEIxRnlkMmNWMQpQZXFUV3duV0x6a3NiSTloa1VPM09MbFNBaDNBTldCRXZwbDlWdFF1ZFRUZ2dsSjdmVW11SjQzTW1sb2JtVitTClhnVmVxeTV3VXNXblN4N2oxWktvNnJsMlFRNmJXalJuMFVoRFJRMS9wcENQcHJ2SjdLeEI4Rmx3TDhSUCtlL2gKUzVyMnJMajN3bkN4OFRTRUh0Z3p5azRSVk1EMzZaUlUrZjdRK2lSbE91OGZLeUpobUpXZnNTZk9VMHJ2cWw5MgpjbXRqMXFURUx5TlFEejFuTXYrUVd1cG81UTVOM2MyRFpPQ2VaK0JqOHVJbThkbTRPRjJ4a2tOa3RpMmdWUitUCkFnTUJBQUdqSXpBaE1BNEdBMVVkRHdFQi93UUVBd0lDcERBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUEwR0NTcUcKU0liM0RRRUJDd1VBQTRJQkFRQ0xlc25Sa1p4SWh5ZHNPSVNsejQxNENaeWtDTnZrTldwKzhFaHdGdWxHdEJrQQpmN2Y0QzdKNCswblRuVzMzMXp5RXlURGhpZHVxYXdObVh1QWpWNzhRNnJBRXpLNXJNTFYrY2k5dGxtbWIzbXhnCnNoUHAyWUJLcjBEZ1A4eGRJeGZYSnJWSGNURU9WQzZUZTBySVNlOEtXQ010dHRlRVFkanREeE4wUVhkTmh5OGYKZHBNSnJGUEZFempFZ2E1bGowVzlzakZ4VzBsdkpkZUVDTFVVWVd0enlqd21lZ2NES3NMU3ZnVDJTNmxtSVpicQpaZk1yUXFVNnJYblNkY1lrUm9tVWtzUjVHR0dvLy80VG9rd2F3TUpDU0FvbEtJdzZlMjcvWHpkeEhYcDhpNkRvCkhIZ3dybDZyUDdZdTMxS2F2aVpieWx5TEtKSEE3MWNtcTZhZUxkNWYKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    #     server: https://192.168.99.100:8443
    #   name: 192-168-99-100:8443
    # contexts:
    # - context:
    #     cluster: 192-168-99-100:8443
    #     namespace: myproject
    #     user: system:admin/192-168-99-100:8443
    #   name: myproject/192-168-99-100:8443/system:admin
    # current-context: myproject/192-168-99-100:8443/system:admin
    # kind: Config
    # preferences: {}
    # users:
    # - name: system:admin/192-168-99-100:8443
    #   user:
    #     client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKRENDQWd5Z0F3SUJBZ0lCQ0RBTkJna3Foa2lHOXcwQkFRc0ZBREFtTVNRd0lnWURWUVFEREJ0dmNHVnUKYzJocFpuUXRjMmxuYm1WeVFERTFOREkxTXpRek5UUXdIaGNOTVRneE1URTRNRGswTlRVMVdoY05NakF4TVRFMwpNRGswTlRVMldqQk9NVFV3RlFZRFZRUUtFdzV6ZVhOMFpXMDZiV0Z6ZEdWeWN6QWNCZ05WQkFvVEZYTjVjM1JsCmJUcGpiSFZ6ZEdWeUxXRmtiV2x1Y3pFVk1CTUdBMVVFQXhNTWMzbHpkR1Z0T21Ga2JXbHVNSUlCSWpBTkJna3EKaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF0QlZGRDZYbUxRVzQzempwKzNZOGlOMnVaSFlvT2FvUQpES2JEVGNnNzdvQ3dUYnRyS3k1SmplQnFCbXRVRHlISUpNVU15eG1NQ2xhU0dxR09HdW9TYXJpaGEveEFvWkszCjVOT2dlR2dpbkdrNUF0S1NIa1BUbG5FSCtNajJpVmhwNHo1RXVpenZJdmhkcFd1WDJQaTRKRkpoUFlJLzE4YlQKYVU0NVArcnErY1lxak0vbFpmaWlEbVJ0ZjExaWExdjRTMDBCcTVIOVR5VkdtcTkwallad2dYenVoc0FMYS9XSwpXcGNveWl2NUt1Vy9keW02QjFSU1BhKzJGd1pKN2VwamFpMXhESGVXTUtEdTlCZnUxbnJwSUdUNTBraS9RU25ICjNwS1UxWGVnS2c5SGtycWFuc3FaeVZXN3JWTmNDTVA2Ti9UUE82RW9qVjIwcGtLclBseUVZd0lEQVFBQm96VXcKTXpBT0JnTlZIUThCQWY4RUJBTUNCYUF3RXdZRFZSMGxCQXd3Q2dZSUt3WUJCUVVIQXdJd0RBWURWUjBUQVFILwpCQUl3QURBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQWZaQnBmL2ltNEVnQjY2N0djNXFwc1g0UkVNdGhOb3daCkNxSXIrbHFmLzVxV0h0LzBmeXlKZTdRQmVqWmVRd01GYVF1ZzVQSDZPVU9ZVVE1eUl3MWJjR1pPcHJ1NDY5d1AKWDJEdnFxMXJWeFZUUUhHODdzQXNUaVRxdmFNSm5IMG95NloxYUNoQ1hpRGZMME9nVmVZclRSMXcwblc1TVhKcAoxN1dRZVRjTngyK29NMWJlT3JEbEpST1NISkNEVmtGVlBSWXpZM0ZiME5iZlFLMW1CMHNoREUra3RVZ0pMOGNFCnY4Y2Rac1A3dzU4MlRpR0M1ZGR4TEViTVhwa0tWL2NtVVpyOU5Wa2JITzFZalRoLzUvc3pRemxNaEIvVEs4OSsKdXBtblVBTUtjMXJlRDdIUDl0eFhUWWxLa3UwZ0s0ckIxc2laUGxlV3cxYVNkb0luTHc0YmhRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    #     client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBdEJWRkQ2WG1MUVc0M3pqcCszWThpTjJ1WkhZb09hb1FES2JEVGNnNzdvQ3dUYnRyCkt5NUpqZUJxQm10VUR5SElKTVVNeXhtTUNsYVNHcUdPR3VvU2FyaWhhL3hBb1pLMzVOT2dlR2dpbkdrNUF0S1MKSGtQVGxuRUgrTWoyaVZocDR6NUV1aXp2SXZoZHBXdVgyUGk0SkZKaFBZSS8xOGJUYVU0NVArcnErY1lxak0vbApaZmlpRG1SdGYxMWlhMXY0UzAwQnE1SDlUeVZHbXE5MGpZWndnWHp1aHNBTGEvV0tXcGNveWl2NUt1Vy9keW02CkIxUlNQYSsyRndaSjdlcGphaTF4REhlV01LRHU5QmZ1MW5ycElHVDUwa2kvUVNuSDNwS1UxWGVnS2c5SGtycWEKbnNxWnlWVzdyVk5jQ01QNk4vVFBPNkVvalYyMHBrS3JQbHlFWXdJREFRQUJBb0lCQUdQemxrUk1LVWg5NzVGKwpEbWh5eE1DV2dnL2lnUXNZZUJYOWpWTWp1eGZ5dDJnOWlRc0xndW5MVUMzRjduOERtZ25Ha1FZOVpMdnNOdVd2Ckc2ZVdtYWhBVitBT3YzU3VjWUVCY1FURGo4cE9vTVVQU09paGJ0UUdZbzFVUlhvUDU1Mm9WdzhhbDVSS1UvZlgKa3cxclp4Rko1QXoydVNhemhXM2lhK1l0SmtTQktYazdPaWc0dURDMjQxT1dldS9YODFvR01kalBCaExKd01OWApiNUkwZnBxMjdLaFhkMEk3c2E5Rm5ZM01nWVJ2WUZwRzZiTkg1RzVmMUJoY25BZ2dobC9qejVzOUp2cXovZzh3CnBIcnZwQ2ZDVXlxT2dtTE5vVnU0ZEtQWHFzRldSdWdPNStDTnhpNHZ1NlVaZFVXc3h1djVSdTRJNjZvUUhXTEcKU01KT01FRUNnWUVBMFRBUEVZbjNLMTRWQUdoY2xXaVE0U3ppRG94c3grYWZRTk13MGZLVEd0OGpSOEZ1TU90SApOQjNiLzBZcDhKanFYZ3ZnQnIzT1p5MTc5bkl4QmFtNUZHZktLNXd1eGRkUUQvOENoMnlROTZiNlowZmdmTXBNClFHeVdsT2FpZGt2cjRScVNQMWp0R2QwNlpZZzIxSmhvMDlOMCtiSzYzTDRpWWtUYVNnZVBNY01DZ1lFQTNHSGQKWWwxYXRRTXVDQThTcUxqRGMvS1ZId0NZWEtqUXA1SVRqSElkNHVxamhrMjBWRWx4RHk4UHc4blNqN0I4Q2tJawpua3JGaklzek1IY3NoTCtodUVxNlgrYUFCRTliakllRG9kOW02MzFGQnJxQmdTN1k4SFg1NHNlLzVleTkwbTFIClRWenNhL1RSOS9kZlBxckd5Q3BMbTNhemJkU1JaQlRUSUJiU21PRUNnWUVBdGZIaENWWkFuMzNETW9tVERYalgKbXFMWk0rSTdzMXNKNU81THBqQWdkdHpoNk1WN1BCMUgzektoYU5UMElZby9QdkdCTnh2YjdLNEpCZitvVjg2WgpaZ0FvUGVvb1hIZTc4VTNTTzB2WWd5NisyUm9SVFRqL1BZRzFMMm15b01YRU1oUlVZN2pLOFJZVWRyOFZRYkFXCmJUZWNwSm9xSVZsV3VyWThUdXRvUnRVQ2dZQTFkcng1YjRKZzVYdVdVdW5JNnNIbjhCTERLYWJNMjl0NnU1Sm8KZ1FyRkVQMUl5TE1WdTVkbEFwckZlY0hPUUJkbmViSmVnRzg2Y0U2ajFGV0ZndVBkektzNE5yZ1owNUszSGUwTwpLUjlUdzlrcUQ3YjVPdjlBSHE3WG1IUHllS040V0RCekVUYjkzYS9PZzBHazkxTXdIaXFuZFgyRUNJeVpCZ0JPCkNadGZvUUtCZ0h5bDFCY1ZaRVVDWm1DRTgvc2E1UlNMSWRkVEplQXJyeHB1MVNxbkliWkJhQlpPZmcwMUExbmEKekZ1aDRmQzNHb3Npa1RLeklPUzU1R1Zyd2lhSEYwZUpXeVZTR0RIMnk0Um9seVU4bnpVY3AyQ0lEMS9pR2ZoegpLZGRxSXc1eWt2RHJFbHRIbDhoajJiUWt1d1lNOE51dkFuQmVRWml2YWxxWDg5dmhtaE9KCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

    cat /misc/kubernetes/.kube/config

    # apiVersion: v1
    # clusters:
    # - cluster:
    #     certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM2akNDQWRLZ0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFtTVNRd0lnWURWUVFEREJ0dmNHVnUKYzJocFpuUXRjMmxuYm1WeVFERTFOREkxTXpRek5UUXdIaGNOTVRneE1URTRNRGswTlRVMFdoY05Nak14TVRFMwpNRGswTlRVMVdqQW1NU1F3SWdZRFZRUUREQnR2Y0dWdWMyaHBablF0YzJsbmJtVnlRREUxTkRJMU16UXpOVFF3CmdnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUM0UEMwcmpJMWZVSzZ1QUw5SDJvMSsKMFZpYm9WTmZ6c3ZvSnZ3WEg5Vjd3eXJ3aDhtYTB5VHRJd2FSMnB0QSs4MmdwRHhiTlN6VGtJOEIxRnlkMmNWMQpQZXFUV3duV0x6a3NiSTloa1VPM09MbFNBaDNBTldCRXZwbDlWdFF1ZFRUZ2dsSjdmVW11SjQzTW1sb2JtVitTClhnVmVxeTV3VXNXblN4N2oxWktvNnJsMlFRNmJXalJuMFVoRFJRMS9wcENQcHJ2SjdLeEI4Rmx3TDhSUCtlL2gKUzVyMnJMajN3bkN4OFRTRUh0Z3p5azRSVk1EMzZaUlUrZjdRK2lSbE91OGZLeUpobUpXZnNTZk9VMHJ2cWw5MgpjbXRqMXFURUx5TlFEejFuTXYrUVd1cG81UTVOM2MyRFpPQ2VaK0JqOHVJbThkbTRPRjJ4a2tOa3RpMmdWUitUCkFnTUJBQUdqSXpBaE1BNEdBMVVkRHdFQi93UUVBd0lDcERBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUEwR0NTcUcKU0liM0RRRUJDd1VBQTRJQkFRQ0xlc25Sa1p4SWh5ZHNPSVNsejQxNENaeWtDTnZrTldwKzhFaHdGdWxHdEJrQQpmN2Y0QzdKNCswblRuVzMzMXp5RXlURGhpZHVxYXdObVh1QWpWNzhRNnJBRXpLNXJNTFYrY2k5dGxtbWIzbXhnCnNoUHAyWUJLcjBEZ1A4eGRJeGZYSnJWSGNURU9WQzZUZTBySVNlOEtXQ010dHRlRVFkanREeE4wUVhkTmh5OGYKZHBNSnJGUEZFempFZ2E1bGowVzlzakZ4VzBsdkpkZUVDTFVVWVd0enlqd21lZ2NES3NMU3ZnVDJTNmxtSVpicQpaZk1yUXFVNnJYblNkY1lrUm9tVWtzUjVHR0dvLy80VG9rd2F3TUpDU0FvbEtJdzZlMjcvWHpkeEhYcDhpNkRvCkhIZ3dybDZyUDdZdTMxS2F2aVpieWx5TEtKSEE3MWNtcTZhZUxkNWYKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    #     server: https://192.168.99.100:8443
    #   name: 192-168-99-100:8443
    # - cluster:
    #     certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM2akNDQWRLZ0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFtTVNRd0lnWURWUVFEREJ0dmNHVnUKYzJocFpuUXRjMmxuYm1WeVFERTFOREE0TlRVMk5UWXdIaGNOTVRneE1ESTVNak15TnpNMldoY05Nak14TURJNApNak15TnpNM1dqQW1NU1F3SWdZRFZRUUREQnR2Y0dWdWMyaHBablF0YzJsbmJtVnlRREUxTkRBNE5UVTJOVFl3CmdnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURFemFXSXNodm93b1FWNG1nYmZkOTUKM3IwSktxTjFzdnh5dElkYWFSU2pmc0J6NTNDMkkvYzRwYnNXWGsrc0hTdjZVbzE1YmdFaXpoTWJML1BYNEg4YwpteFFFYTBVbWlBWjF5RkxhUjZJTE8weERWNmQ3VlZWOU1zdnlWN2g3cVdEMCthZXQ0SUhjNDVtNUhuWDRSc0ttCkFsNHh2d2lGMzhyNHBVUHluSkNUYXBaS3VDU3JpVWFmU1NkNmNDNTJDZDdjdXZzMis1T2J1Rng5MEhUTGl4S3kKbDl4aVl6QW5EajhxaXV2THNyd0VmSVQ1a3A5Y3l6aUI0RjJtelJ6NVllNFFGYk5OM0NmcEhGK2M2UFB0UW4vVApkK0VNUERDeW9iYVd5dTQvdTdEM0Qrb2VPQlZtaGh1dyt5Z3JsaWVHOEJRYTVtTGFVSDNIR29uWk92U1NWUWh4CkFnTUJBQUdqSXpBaE1BNEdBMVVkRHdFQi93UUVBd0lDcERBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUEwR0NTcUcKU0liM0RRRUJDd1VBQTRJQkFRQnpYV0dLcVFSSElVY0k5ZmZnSzdHQmNYUFFqVlNrWXV3ZXdSMlFEd3dkS214bApIdDlXd0piZXBITkVKTmNGYi8xaElTcFRsS2RBTXplSjRydTFRNDkrdW1QbUdrWFd6Y1c0WUl6Ry9MOTk1QmU0CmhmWHFCY2hTdmNwcENSSFUvZ1pIRXRwU3MvTnJXbnhlOHIwem5sNmgweHVibnVkdUErd3c2Y05TVzZwTHJ1WDEKOEZRNHRxZy9FSG9qNi9QajJFRUo1clU3RXdPbmxzK0F6SnRodGo1SVA0ZGRKcjRsOG5ZMmJhQThMaHJTRmMvaApIZlFpKzUySG10VS9hZmFLWS9UQ2pJbDVOeW9sOHBXbEZTbkdFc3N6eTdnN0FNQ0pUVU80R3lwTmdXNHZBb1BoCmlacGhieElHcUpJYm5pMDNZTUtnQ3A2NUhaMUF4QVJCNDl6KzR4TlYKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    #     server: https://192.168.99.103:8443
    #   name: 192-168-99-103:8443
    # - cluster:
    #     certificate-authority: D:\misc\kubernetes\.minikube\ca.crt
    #     server: https://192.168.99.101:8443
    #   name: minikube
    # contexts:
    # - context:
    #     cluster: 192-168-99-103:8443
    #     user: develope/192-168-99-103:8443
    #   name: /192-168-99-103:8443/develope
    # - context:
    #     cluster: 192-168-99-103:8443
    #     namespace: keycloak
    #     user: developer/192-168-99-103:8443
    #   name: keycloak/192-168-99-103:8443/developer
    # - context:
    #     cluster: minikube
    #     user: minikube
    #   name: minikube
    # - context:
    #     cluster: 192-168-99-103:8443
    #     namespace: myproject
    #     user: developer/192-168-99-103:8443
    #   name: minishift
    # - context:
    #     cluster: 192-168-99-100:8443
    #     namespace: myproject
    #     user: developer/192-168-99-100:8443
    #   name: myproject/192-168-99-100:8443/developer
    # - context:
    #     cluster: 192-168-99-100:8443
    #     namespace: myproject
    #     user: system:admin/192-168-99-100:8443
    #   name: myproject/192-168-99-100:8443/system:admin
    # - context:
    #     cluster: 192-168-99-103:8443
    #     namespace: myproject
    #     user: developer/192-168-99-103:8443
    #   name: myproject/192-168-99-103:8443/developer
    # - context:
    #     cluster: 192-168-99-103:8443
    #     namespace: myproject
    #     user: system:admin/192-168-99-103:8443
    #   name: myproject/192-168-99-103:8443/system:admin
    # - context:
    #     cluster: 192-168-99-100:8443
    #     namespace: myproject
    #     user: developer/192-168-99-100:8443
    #   name: opendevstack
    # - context:
    #     cluster: 192-168-99-103:8443
    #     namespace: vz-keycloak
    #     user: developer/192-168-99-103:8443
    #   name: vz-keycloak/192-168-99-103:8443/developer
    # current-context: myproject/192-168-99-100:8443/system:admin
    # kind: Config
    # preferences: {}
    # users:
    # - name: develope/192-168-99-103:8443
    #   user:
    #     token: TyaNuA-21UM82sqr2Eb8Ti9aFWIzdgmdrmVBvOv19kI
    # - name: developer/192-168-99-100:8443
    #   user:
    #     token: tu-SGFeiRPj-G6_IdF2j4ufihR55Cstq-8uktxZ8yOQ
    # - name: developer/192-168-99-103:8443
    #   user:
    #     token: mNLy5WckiqPSuFYLMvgzi9sGe28lpfv9lnLwzBWfQsQ
    # - name: minikube
    #   user:
    #     client-certificate: D:\misc\kubernetes\.minikube\client.crt
    #     client-key: D:\misc\kubernetes\.minikube\client.key
    # - name: system:admin/192-168-99-100:8443
    #   user:
    #     client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKRENDQWd5Z0F3SUJBZ0lCQ0RBTkJna3Foa2lHOXcwQkFRc0ZBREFtTVNRd0lnWURWUVFEREJ0dmNHVnUKYzJocFpuUXRjMmxuYm1WeVFERTFOREkxTXpRek5UUXdIaGNOTVRneE1URTRNRGswTlRVMVdoY05NakF4TVRFMwpNRGswTlRVMldqQk9NVFV3RlFZRFZRUUtFdzV6ZVhOMFpXMDZiV0Z6ZEdWeWN6QWNCZ05WQkFvVEZYTjVjM1JsCmJUcGpiSFZ6ZEdWeUxXRmtiV2x1Y3pFVk1CTUdBMVVFQXhNTWMzbHpkR1Z0T21Ga2JXbHVNSUlCSWpBTkJna3EKaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF0QlZGRDZYbUxRVzQzempwKzNZOGlOMnVaSFlvT2FvUQpES2JEVGNnNzdvQ3dUYnRyS3k1SmplQnFCbXRVRHlISUpNVU15eG1NQ2xhU0dxR09HdW9TYXJpaGEveEFvWkszCjVOT2dlR2dpbkdrNUF0S1NIa1BUbG5FSCtNajJpVmhwNHo1RXVpenZJdmhkcFd1WDJQaTRKRkpoUFlJLzE4YlQKYVU0NVArcnErY1lxak0vbFpmaWlEbVJ0ZjExaWExdjRTMDBCcTVIOVR5VkdtcTkwallad2dYenVoc0FMYS9XSwpXcGNveWl2NUt1Vy9keW02QjFSU1BhKzJGd1pKN2VwamFpMXhESGVXTUtEdTlCZnUxbnJwSUdUNTBraS9RU25ICjNwS1UxWGVnS2c5SGtycWFuc3FaeVZXN3JWTmNDTVA2Ti9UUE82RW9qVjIwcGtLclBseUVZd0lEQVFBQm96VXcKTXpBT0JnTlZIUThCQWY4RUJBTUNCYUF3RXdZRFZSMGxCQXd3Q2dZSUt3WUJCUVVIQXdJd0RBWURWUjBUQVFILwpCQUl3QURBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQWZaQnBmL2ltNEVnQjY2N0djNXFwc1g0UkVNdGhOb3daCkNxSXIrbHFmLzVxV0h0LzBmeXlKZTdRQmVqWmVRd01GYVF1ZzVQSDZPVU9ZVVE1eUl3MWJjR1pPcHJ1NDY5d1AKWDJEdnFxMXJWeFZUUUhHODdzQXNUaVRxdmFNSm5IMG95NloxYUNoQ1hpRGZMME9nVmVZclRSMXcwblc1TVhKcAoxN1dRZVRjTngyK29NMWJlT3JEbEpST1NISkNEVmtGVlBSWXpZM0ZiME5iZlFLMW1CMHNoREUra3RVZ0pMOGNFCnY4Y2Rac1A3dzU4MlRpR0M1ZGR4TEViTVhwa0tWL2NtVVpyOU5Wa2JITzFZalRoLzUvc3pRemxNaEIvVEs4OSsKdXBtblVBTUtjMXJlRDdIUDl0eFhUWWxLa3UwZ0s0ckIxc2laUGxlV3cxYVNkb0luTHc0YmhRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    #     client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBdEJWRkQ2WG1MUVc0M3pqcCszWThpTjJ1WkhZb09hb1FES2JEVGNnNzdvQ3dUYnRyCkt5NUpqZUJxQm10VUR5SElKTVVNeXhtTUNsYVNHcUdPR3VvU2FyaWhhL3hBb1pLMzVOT2dlR2dpbkdrNUF0S1MKSGtQVGxuRUgrTWoyaVZocDR6NUV1aXp2SXZoZHBXdVgyUGk0SkZKaFBZSS8xOGJUYVU0NVArcnErY1lxak0vbApaZmlpRG1SdGYxMWlhMXY0UzAwQnE1SDlUeVZHbXE5MGpZWndnWHp1aHNBTGEvV0tXcGNveWl2NUt1Vy9keW02CkIxUlNQYSsyRndaSjdlcGphaTF4REhlV01LRHU5QmZ1MW5ycElHVDUwa2kvUVNuSDNwS1UxWGVnS2c5SGtycWEKbnNxWnlWVzdyVk5jQ01QNk4vVFBPNkVvalYyMHBrS3JQbHlFWXdJREFRQUJBb0lCQUdQemxrUk1LVWg5NzVGKwpEbWh5eE1DV2dnL2lnUXNZZUJYOWpWTWp1eGZ5dDJnOWlRc0xndW5MVUMzRjduOERtZ25Ha1FZOVpMdnNOdVd2Ckc2ZVdtYWhBVitBT3YzU3VjWUVCY1FURGo4cE9vTVVQU09paGJ0UUdZbzFVUlhvUDU1Mm9WdzhhbDVSS1UvZlgKa3cxclp4Rko1QXoydVNhemhXM2lhK1l0SmtTQktYazdPaWc0dURDMjQxT1dldS9YODFvR01kalBCaExKd01OWApiNUkwZnBxMjdLaFhkMEk3c2E5Rm5ZM01nWVJ2WUZwRzZiTkg1RzVmMUJoY25BZ2dobC9qejVzOUp2cXovZzh3CnBIcnZwQ2ZDVXlxT2dtTE5vVnU0ZEtQWHFzRldSdWdPNStDTnhpNHZ1NlVaZFVXc3h1djVSdTRJNjZvUUhXTEcKU01KT01FRUNnWUVBMFRBUEVZbjNLMTRWQUdoY2xXaVE0U3ppRG94c3grYWZRTk13MGZLVEd0OGpSOEZ1TU90SApOQjNiLzBZcDhKanFYZ3ZnQnIzT1p5MTc5bkl4QmFtNUZHZktLNXd1eGRkUUQvOENoMnlROTZiNlowZmdmTXBNClFHeVdsT2FpZGt2cjRScVNQMWp0R2QwNlpZZzIxSmhvMDlOMCtiSzYzTDRpWWtUYVNnZVBNY01DZ1lFQTNHSGQKWWwxYXRRTXVDQThTcUxqRGMvS1ZId0NZWEtqUXA1SVRqSElkNHVxamhrMjBWRWx4RHk4UHc4blNqN0I4Q2tJawpua3JGaklzek1IY3NoTCtodUVxNlgrYUFCRTliakllRG9kOW02MzFGQnJxQmdTN1k4SFg1NHNlLzVleTkwbTFIClRWenNhL1RSOS9kZlBxckd5Q3BMbTNhemJkU1JaQlRUSUJiU21PRUNnWUVBdGZIaENWWkFuMzNETW9tVERYalgKbXFMWk0rSTdzMXNKNU81THBqQWdkdHpoNk1WN1BCMUgzektoYU5UMElZby9QdkdCTnh2YjdLNEpCZitvVjg2WgpaZ0FvUGVvb1hIZTc4VTNTTzB2WWd5NisyUm9SVFRqL1BZRzFMMm15b01YRU1oUlVZN2pLOFJZVWRyOFZRYkFXCmJUZWNwSm9xSVZsV3VyWThUdXRvUnRVQ2dZQTFkcng1YjRKZzVYdVdVdW5JNnNIbjhCTERLYWJNMjl0NnU1Sm8KZ1FyRkVQMUl5TE1WdTVkbEFwckZlY0hPUUJkbmViSmVnRzg2Y0U2ajFGV0ZndVBkektzNE5yZ1owNUszSGUwTwpLUjlUdzlrcUQ3YjVPdjlBSHE3WG1IUHllS040V0RCekVUYjkzYS9PZzBHazkxTXdIaXFuZFgyRUNJeVpCZ0JPCkNadGZvUUtCZ0h5bDFCY1ZaRVVDWm1DRTgvc2E1UlNMSWRkVEplQXJyeHB1MVNxbkliWkJhQlpPZmcwMUExbmEKekZ1aDRmQzNHb3Npa1RLeklPUzU1R1Zyd2lhSEYwZUpXeVZTR0RIMnk0Um9seVU4bnpVY3AyQ0lEMS9pR2ZoegpLZGRxSXc1eWt2RHJFbHRIbDhoajJiUWt1d1lNOE51dkFuQmVRWml2YWxxWDg5dmhtaE9KCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
    # - name: system:admin/192-168-99-103:8443
    #   user:
    #     client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKRENDQWd5Z0F3SUJBZ0lCQ0RBTkJna3Foa2lHOXcwQkFRc0ZBREFtTVNRd0lnWURWUVFEREJ0dmNHVnUKYzJocFpuUXRjMmxuYm1WeVFERTFOREE0TlRVMk5UWXdIaGNOTVRneE1ESTVNak15TnpNNFdoY05NakF4TURJNApNak15TnpNNVdqQk9NVFV3RlFZRFZRUUtFdzV6ZVhOMFpXMDZiV0Z6ZEdWeWN6QWNCZ05WQkFvVEZYTjVjM1JsCmJUcGpiSFZ6ZEdWeUxXRmtiV2x1Y3pFVk1CTUdBMVVFQXhNTWMzbHpkR1Z0T21Ga2JXbHVNSUlCSWpBTkJna3EKaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEyWHQ4NjFIYkl2QzlFQ2pvMDVMOVFYYWVESmhCMzVEVwpKSWFOb29GTENCZ3Q3TlpnUEZudXNLSHZJZTFHbXUyeGxNazg2NS82QWFtc2pnV2NyNTZmTTNNNlVWeGp4c2JlCnMzR3VTQnliNTQvc2Q3STU0WXZaTUhYd0R4bGxrZ2lQVkVwVlVFVHZiL1FPZFdIdGZyNGhSanQ5ZzYwWm8zK0IKdGNRSnZlOEZ1SENwd2VYdlVMQUFqL0JGY2s5OE1Wb2E2b1FFblEvTldURGFReUowS3lHS2liZmFFT1Fyc0FSRQpiYm8zTFpBTS9SYmZCK3B2QnNEZE54SGxyMWp4QUlFVGY3OExrSkRsK0cxT0tYMXRUZDFXcjE5Ymt2RU9EdU1hCjBiT2xDdDFnTW9iMkZkUHhQbm9xVnZ6d0I5eit6Z2ZieUNTWmVhYUd6NEpaQm9aYk1XMENPUUlEQVFBQm96VXcKTXpBT0JnTlZIUThCQWY4RUJBTUNCYUF3RXdZRFZSMGxCQXd3Q2dZSUt3WUJCUVVIQXdJd0RBWURWUjBUQVFILwpCQUl3QURBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQU1SWHBoSmpFVjlnTDZWcU5Pdkl5aGRrQmI5UTRlOHQ0Ck41bndqdFJFVVFyUkhhS2pnUWwwUHhVUVpzNjlhWlVoQkdXeDZHdVFwc3JpQTV0Z0o5SUxQdG51U2VmVUlnczYKUW9aQVdLNkNBVFVjMThkTmdXTXNhZjc4U1ZmSFh1MmZaNFYwVVVsaHhGOUxZaFg0ZW1lZmYxdUVuQ0ttRzcxcwpkYS9LdkhSNHJGeVcxZi9JdkRtNnNQeTFjRHJ3MUg2c1JidmIxYldmVnJnTTBmOEVRTVM5V3haUWtEeU13TWphCjV3Tk8vd2Z0MVdEd3pvUmx5bERtTFQwQ3B6TkFEcUM2RVI0RjU4UFM1ZHZldDIxOEI4UnNJOHBCQzI5alNBMmwKdjZFMFpYaE1FSDdTT2VaRTVsZmtWa01IeVU4YUl2YStmRkh3b2F6ZXZKTGdCbE5ud1l2NGdRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    #     client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBMlh0ODYxSGJJdkM5RUNqbzA1TDlRWGFlREpoQjM1RFdKSWFOb29GTENCZ3Q3TlpnClBGbnVzS0h2SWUxR211MnhsTWs4NjUvNkFhbXNqZ1djcjU2Zk0zTTZVVnhqeHNiZXMzR3VTQnliNTQvc2Q3STUKNFl2Wk1IWHdEeGxsa2dpUFZFcFZVRVR2Yi9RT2RXSHRmcjRoUmp0OWc2MFpvMytCdGNRSnZlOEZ1SENwd2VYdgpVTEFBai9CRmNrOThNVm9hNm9RRW5RL05XVERhUXlKMEt5R0tpYmZhRU9RcnNBUkViYm8zTFpBTS9SYmZCK3B2CkJzRGROeEhscjFqeEFJRVRmNzhMa0pEbCtHMU9LWDF0VGQxV3IxOWJrdkVPRHVNYTBiT2xDdDFnTW9iMkZkUHgKUG5vcVZ2endCOXoremdmYnlDU1plYWFHejRKWkJvWmJNVzBDT1FJREFRQUJBb0lCQUFOOEFRSmNLMkNoN3NXRgpna1Z4ZzNFN0Qwa3dYMDNQcWo2bmtUbGJUUEp5UUxvY3JTb0tYdEtocFkwcm1nZjlhdXp4VkhLSis1MXZOSDZLCkJIcWoxZlVqRVhvZ090RUNlcXJ4VlZOK2Nka0I2MDMzb3duRURkVEM3dmV1OW51aWUzbGtQMzJydlJKVUhLOHcKeEhkVllIOFprT2M5TEwzNzJ2NG9oK2R0SHZCWGhpdk4zaWNEWEd2SzZyV1loMU03clNXZ3ZqRjU2ek5Od1ZJdApMaGNnN21zTThIbDcyZ0h4bGlDcVAwSzlNVjFmRGNyajY3VDU1OVFPNDc0YWoxZmllcGpvLzE2TFEyTXg3cmdMCjNHd0JDTjdEeEhVMjh6aHU5aGhSWGswTEpnTTZIZkZOMDNxaXJHRnUxNjg3NVpLMkVlZUU4ZW11TUNhWEdreWEKNXBRMFR5a0NnWUVBL2k4ODI5aG5FTXhBazJvZnViZUFMZzZQWlNXSWtQZzdGT3lMa2R3VHZqMWFaU0NuTFJIbgpkKzJtWGdMSDZ0bmNKSEtzcjBXS2I0Q2dLOCtkaW9CRWY2cXJaSEg0WmpqWmU0dWsxQXBWcWlHbzlqTElleHJKCnZTQVFrU1lnTFJiOVArL3ZuMFFrVkdyMnVpQTVsTEcxQ0E0TjNRTHpCUGY3RW9lMzd3ZzQyZ3NDZ1lFQTJ3a2sKZEVxUlBmMWpCRkNLTzNhdWJ6a2VIVGdjU0VWcm4xSVVJeFk5c2ZpbXR5YkZwdVZuWXh6LzM4RGJuT0ZNZkt0QgpCRXBUK2lmaWFpWmM3K2F1RXovMjBLM05MYmQwSmdFdDBWOTA3bTVaYzBieVY1MUNNbmkzYUNhenJXaU0xdldzCmltM2RKV0RCTHc4ODBWWnY3eUk3Y2pGdlNCenp6Q3lZQWhRRkEwc0NnWUVBdGpNa0c2NWVDcE51Z255aXF4d1cKL0d5aGF1NWhteERrUU5aaUlUYXd6RC9zU09zRUNuRjRDdVpGeDhPVWpBcUlHM1E3eGhOQjdUVTFHdEppYWdJUgpsN1c5ejIxR2tmZVVKVlB1M2JOZXZtb01WQllJMFAxZHVIeUFnNXJobTVDTURjV3ViT3FLWkJ5Y0tNU3FvYVJVClVLYktWeThqQmQrL2tBUEsyOE40QlFzQ2dZQVIwZ2laUFlmYmwwWDdEK0p2UEJTdEQrU1hVLzFaRSt6UnBZZmwKNHVWYUdYVFc2ZHlpMjM4eDNTWWtPamlqNXVDbU0vaXlOS25vYkY1TGJKdWJHUldJazJldFNyYXF4WVk1b1Zicwo5ZXM1aXRqVVBDMXpXMlFMWHk3czFsay8vb1dXNTU0R0ZUSXMzRlpiVWM0TTZnOXBVVXVzMnNESENUUDhwSlFwCmR4K0JTUUtCZ0huUGdRbGk4QkR4UG9sSlM3Q3BnUkczSXM1dElIMTlTM3crR3U5MENUK3ZER1FCWDV6ZDI1YkcKK2Jpa3V4V3o5N1dqMHRKdVMxeENSRC9EeitvRzRrZU9wbWt2dWpRTStFbGg2NHcvb09sUEZjU1VzZ0dORDdldgpqa0JUdThzQkRHMXBRcjJFRzZLa282MFhGc3VqSjgwNmYwcWVvSzJDalgrSTEzL1JXWjdkCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

After the start up you are able to open the webconsole with the minishift
console command. This will open the webconsole in your standard browser. Please
access the webconsole with the credentials developer developer. It is important
not to use the system user, because Jenkins does not allow a user named system.


<a id="org4f63911"></a>

### Configure the path for the OC CLI

    minishift oc-env

    # VZE:~/org/opitz> export PATH="D:\misc\openshift\.minishift\cache\oc\v3.10.0\windows:$PATH"
    # # Run this command to configure your shell:
    # # eval $(minishift oc-env)


<a id="org8c945af"></a>

### Login with the CLI

    oc login -u system:admin

    # Logged into "https://192.168.99.100:8443" as "system:admin" using existing credentials.
    # 
    # You have access to the following projects and can switch between them with 'oc project <projectname>':
    # 
    #     default
    #     kube-dns
    #     kube-proxy
    #     kube-public
    #     kube-system
    #   * myproject
    #     openshift
    #     openshift-apiserver
    #     openshift-controller-manager
    #     openshift-core-operators
    #     openshift-infra
    #     openshift-node
    #     openshift-web-console
    # 
    # Using project "myproject".


<a id="org8ea23be"></a>

### Setup the base template project

After you have logged in, you are able to create a project, that will contain
the base templates and the Nexus Repository Manager. Please enter the following
command to add the base project:

    oc new-project cd --description="Base project holding the templates and the Repositoy Manager" --display-name="OpenDevStack Templates"

    # Now using project "cd" on server "https://192.168.99.100:8443".
    # 
    # You can add applications to this project with the 'new-app' command. For example, try:
    # 
    #     oc new-app centos/ruby-25-centos7~https://github.com/sclorg/ruby-ex.git
    # 
    # to build a new example application in Ruby.

This command will create the base project.


<a id="org52753b6"></a>

### Adjust user rights for the developer user

To be able to see all created projects, you will have to adjust the user rights
for the developer use. Do so by using the provided command

    oc adm policy --as system:admin add-cluster-role-to-user cluster-admin developer

    # cluster role "cluster-admin" added: "developer"


<a id="org8ce79a6"></a>

### Create service account for deployment

Rundeck needs a technical account in Minishift to be able to create projects and
provision resources. Therefore, we create a service account, which credentials
are provided to Rundeck in a later step.

    oc create sa deployment -n cd

    # serviceaccount/deployment created

    oc adm policy --as system:admin add-cluster-role-to-user cluster-admin system:serviceaccount:cd:deployment

    # cluster role "cluster-admin" added: "system:serviceaccount:cd:deployment"

After you have created the service account we need the token for this account.

    oc sa get-token deployment -n cd

    # eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJjZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZXBsb3ltZW50LXRva2VuLXA0NnNrIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImRlcGxveW1lbnQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1ZWY2MDllMy1lYjFjLTExZTgtYjhjNy0wODAwMjc3YzQzNmQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6Y2Q6ZGVwbG95bWVudCJ9.VCXUZnvoy_D4FyfwCPNbf60RBaXYQryOZ9IYQOH7-InxaSGnmoqXohDBlO2ict6YxCC8mloTXYZhKd-A0zaKdl3gJchrfKTpNMccfu-ypKPy9CHfNNI2ElOjcRicpg69Nol7nAb9r3mNuQthGX6T0Fknmz2_JJIdJqQcwdXgduVxwQuL3mrwOEvQ8ngLUaivmfU9ncbRlTmXmE21fz4yKLWphgi26wTyLBpXDIRH6ooc9iOv0Pe5nrigGFNwkoDg4AcsgD1f02SpubuuDN-s2DZ8PdcF0B5hMVYTkLa-r0pKE0_mkO_hyhizQJsUqz4Kchh8-JXnDeeEj_H5LYZgAQ

Save the token text. It will be used in the Rundeck configuration later.


<a id="org0818fdd"></a>

### Install Minishift certificate on Atlassian server

You have to add the Minishift certificate to the **atlassian1** JVM, so Bitbucket is
able to execute REST Calls against Minishift, triggered by Webhooks. Go to the
directory, where you have started Vagrant. Here open a SSH connection to the
**atlassian1** server.

    cd /misc/vagrant/opendevstack/ods-core/infrastructure-setup

    vagrant ssh atlassian1

    # ==> vagrant: A new version of Vagrant is available: 2.2.1 (installed version: 2.2.0)!
    # ==> vagrant: To upgrade visit: https://www.vagrantup.com/downloads.html
    # 
    # Handling vm with hostname [atlassian1] and IP [192.168.56.31]
    # Last login: Sun Nov 18 07:44:30 2018 from 192.168.56.110

On the server change to the root account

    sudo -i

Here execute the following command to get the certificate from the Minishift server:

    openssl s_client -connect 192.168.99.100:8443 -showcerts < /dev/null 2>/dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/minishift.crt

    cat /tmp/minishift.crt

    # -----BEGIN CERTIFICATE-----
    # MIIEHjCCAwagAwIBAgIBAzANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBtvcGVu
    # c2hpZnQtc2lnbmVyQDE1NDI1MzQzNTQwHhcNMTgxMTE4MDk0NTU1WhcNMjAxMTE3
    # MDk0NTU2WjAUMRIwEAYDVQQDEwkxMC4wLjIuMTUwggEiMA0GCSqGSIb3DQEBAQUA
    # A4IBDwAwggEKAoIBAQCgiUV/+/8F5SjnZHmQ9rtL8vmBaCmCj1AACrOCcIl0H9ZU
    # Uz7nNQ6xL0uVWf0c5/SGBGVRUctbwZ17W39hKSDo8yQROdJyF8mPQavrRrhTFbtu
    # jH6m9miP+bp8FYK51RIOnoIT7jHUq8325ogeP/o+91OOJdKOKxxUz/yGv3Lzhj8n
    # jfIkxz/VQDapfIIzQshApZpOhRYsNqJ/3VGbeJgSjW9Xe6B3mHyX1R9Gwj/P1/2H
    # A6nAmbuaHsRzRt6Ofur1m7PIINnhhbCO2jD302wvQLJ+lm4re+Lg3B6ly4TMZ9fv
    # coEDLCmO1XVz0lOineHH5x5WExK5c0kNwJUSXegHAgMBAAGjggFnMIIBYzAOBgNV
    # HQ8BAf8EBAMCBaAwEwYDVR0lBAwwCgYIKwYBBQUHAwEwDAYDVR0TAQH/BAIwADCC
    # ASwGA1UdEQSCASMwggEfggprdWJlcm5ldGVzghJrdWJlcm5ldGVzLmRlZmF1bHSC
    # Fmt1YmVybmV0ZXMuZGVmYXVsdC5zdmOCJGt1YmVybmV0ZXMuZGVmYXVsdC5zdmMu
    # Y2x1c3Rlci5sb2NhbIIJbG9jYWxob3N0gglvcGVuc2hpZnSCEW9wZW5zaGlmdC5k
    # ZWZhdWx0ghVvcGVuc2hpZnQuZGVmYXVsdC5zdmOCI29wZW5zaGlmdC5kZWZhdWx0
    # LnN2Yy5jbHVzdGVyLmxvY2FsggkxMC4wLjIuMTWCCTEyNy4wLjAuMYIKMTcyLjE3
    # LjAuMYIKMTcyLjMwLjAuMYIOMTkyLjE2OC45OS4xMDCHBAoAAg+HBH8AAAGHBKwR
    # AAGHBKweAAGHBMCoY2QwDQYJKoZIhvcNAQELBQADggEBAIGD5rpTgxbHSwQQ6ghQ
    # tNTinWTW7V/RREDZ+9MHJEaRGto2WZOtPBKcfnDUyYxtSFAHFD3J1ThR/eC1uiC7
    # xTcIYGHcZaBaLD+R7DEtjzys4WBKCovRBGRAp0GiO+6CY0B5ymwwt5kW05gtE/p1
    # ArmTNY6zQkVvJuTyCjG2seRNr9rs0Vy2qhDUx931i2jPUjaBw2UTEkWeyVATO1SY
    # K6VZdnyz6mUbR7P4i8hmbQC3V1gSTkkBj5cLotPseQJ0D0mqDO5sv27qQ/0hUJ+N
    # Hgd01KJN1AG6wXlxYesHxVntsaQSbrXYKiCIAv45vMTiZFE6yFn9vrQhqXTxQXqM
    # Riw=
    # -----END CERTIFICATE-----
    # -----BEGIN CERTIFICATE-----
    # MIIC6jCCAdKgAwIBAgIBATANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBtvcGVu
    # c2hpZnQtc2lnbmVyQDE1NDI1MzQzNTQwHhcNMTgxMTE4MDk0NTU0WhcNMjMxMTE3
    # MDk0NTU1WjAmMSQwIgYDVQQDDBtvcGVuc2hpZnQtc2lnbmVyQDE1NDI1MzQzNTQw
    # ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC4PC0rjI1fUK6uAL9H2o1+
    # 0ViboVNfzsvoJvwXH9V7wyrwh8ma0yTtIwaR2ptA+82gpDxbNSzTkI8B1Fyd2cV1
    # PeqTWwnWLzksbI9hkUO3OLlSAh3ANWBEvpl9VtQudTTgglJ7fUmuJ43MmlobmV+S
    # XgVeqy5wUsWnSx7j1ZKo6rl2QQ6bWjRn0UhDRQ1/ppCPprvJ7KxB8FlwL8RP+e/h
    # S5r2rLj3wnCx8TSEHtgzyk4RVMD36ZRU+f7Q+iRlOu8fKyJhmJWfsSfOU0rvql92
    # cmtj1qTELyNQDz1nMv+QWupo5Q5N3c2DZOCeZ+Bj8uIm8dm4OF2xkkNkti2gVR+T
    # AgMBAAGjIzAhMA4GA1UdDwEB/wQEAwICpDAPBgNVHRMBAf8EBTADAQH/MA0GCSqG
    # SIb3DQEBCwUAA4IBAQCLesnRkZxIhydsOISlz414CZykCNvkNWp+8EhwFulGtBkA
    # f7f4C7J4+0nTnW331zyEyTDhiduqawNmXuAjV78Q6rAEzK5rMLV+ci9tlmmb3mxg
    # shPp2YBKr0DgP8xdIxfXJrVHcTEOVC6Te0rISe8KWCMttteEQdjtDxN0QXdNhy8f
    # dpMJrFPFEzjEga5lj0W9sjFxW0lvJdeECLUUYWtzyjwmegcDKsLSvgT2S6lmIZbq
    # ZfMrQqU6rXnSdcYkRomUksR5GGGo//4TokwawMJCSAolKIw6e27/XzdxHXp8i6Do
    # HHgwrl6rP7Yu31KaviZbylyLKJHA71cmq6aeLd5f
    # -----END CERTIFICATE-----

You should now have two PEM encoded certificate in /tmp/minishift.crt. Remove
the first one (this is the server certificate) and keep the CA Cert.

    chown vagrant /tmp/minishift.crt && chmod 666 /tmp/minishift.crt

Edit the file&#x2026;

Check that you got the CA certificate:

    openssl x509 -in /tmp/minishift.crt -text

    # Certificate:
    #     Data:
    #         Version: 3 (0x2)
    #         Serial Number: 1 (0x1)
    #     Signature Algorithm: sha256WithRSAEncryption
    #         Issuer: CN=openshift-signer@1542534354
    #         Validity
    #             Not Before: Nov 18 09:45:54 2018 GMT
    #             Not After : Nov 17 09:45:55 2023 GMT
    #         Subject: CN=openshift-signer@1542534354
    #         Subject Public Key Info:
    #             Public Key Algorithm: rsaEncryption
    #                 Public-Key: (2048 bit)
    #                 Modulus:
    #                     00:b8:3c:2d:2b:8c:8d:5f:50:ae:ae:00:bf:47:da:
    #                     8d:7e:d1:58:9b:a1:53:5f:ce:cb:e8:26:fc:17:1f:
    #                     d5:7b:c3:2a:f0:87:c9:9a:d3:24:ed:23:06:91:da:
    #                     9b:40:fb:cd:a0:a4:3c:5b:35:2c:d3:90:8f:01:d4:
    #                     5c:9d:d9:c5:75:3d:ea:93:5b:09:d6:2f:39:2c:6c:
    #                     8f:61:91:43:b7:38:b9:52:02:1d:c0:35:60:44:be:
    #                     99:7d:56:d4:2e:75:34:e0:82:52:7b:7d:49:ae:27:
    #                     8d:cc:9a:5a:1b:99:5f:92:5e:05:5e:ab:2e:70:52:
    #                     c5:a7:4b:1e:e3:d5:92:a8:ea:b9:76:41:0e:9b:5a:
    #                     34:67:d1:48:43:45:0d:7f:a6:90:8f:a6:bb:c9:ec:
    #                     ac:41:f0:59:70:2f:c4:4f:f9:ef:e1:4b:9a:f6:ac:
    #                     b8:f7:c2:70:b1:f1:34:84:1e:d8:33:ca:4e:11:54:
    #                     c0:f7:e9:94:54:f9:fe:d0:fa:24:65:3a:ef:1f:2b:
    #                     22:61:98:95:9f:b1:27:ce:53:4a:ef:aa:5f:76:72:
    #                     6b:63:d6:a4:c4:2f:23:50:0f:3d:67:32:ff:90:5a:
    #                     ea:68:e5:0e:4d:dd:cd:83:64:e0:9e:67:e0:63:f2:
    #                     e2:26:f1:d9:b8:38:5d:b1:92:43:64:b6:2d:a0:55:
    #                     1f:93
    #                 Exponent: 65537 (0x10001)
    #         X509v3 extensions:
    #             X509v3 Key Usage: critical
    #                 Digital Signature, Key Encipherment, Certificate Sign
    #             X509v3 Basic Constraints: critical
    #                 CA:TRUE
    #     Signature Algorithm: sha256WithRSAEncryption
    #          8b:7a:c9:d1:91:9c:48:87:27:6c:38:84:a5:cf:8d:78:09:9c:
    #          a4:08:db:e4:35:6a:7e:f0:48:70:16:e9:46:b4:19:00:7f:b7:
    #          f8:0b:b2:78:fb:49:d3:9d:6d:f7:d7:3c:84:c9:30:e1:89:db:
    #          aa:6b:03:66:5e:e0:23:57:bf:10:ea:b0:04:cc:ae:6b:30:b5:
    #          7e:72:2f:6d:96:69:9b:de:6c:60:b2:13:e9:d9:80:4a:af:40:
    #          e0:3f:cc:5d:23:17:d7:26:b5:47:71:31:0e:54:2e:93:7b:4a:
    #          c8:49:ef:0a:58:23:2d:b6:d7:84:41:d8:ed:0f:13:74:41:77:
    #          4d:87:2f:1f:76:93:09:ac:53:c5:13:38:c4:81:ae:65:8f:45:
    #          bd:b2:31:71:5b:49:6f:25:d7:84:08:b5:14:61:6b:73:ca:3c:
    #          26:7a:07:03:2a:c2:d2:be:04:f6:4b:a9:66:21:96:ea:65:f3:
    #          2b:42:a5:3a:ad:79:d2:75:c6:24:46:89:94:92:c4:79:18:61:
    #          a8:ff:fe:13:a2:4c:1a:c0:c2:42:48:0a:25:28:8c:3a:7b:6e:
    #          ff:5f:37:71:1d:7a:7c:8b:a0:e8:1c:78:30:ae:5e:ab:3f:b6:
    #          2e:df:52:9a:be:26:5b:ca:5c:8b:28:91:c0:ef:57:26:ab:a6:
    #          9e:2d:de:5f
    # -----BEGIN CERTIFICATE-----
    # MIIC6jCCAdKgAwIBAgIBATANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBtvcGVu
    # c2hpZnQtc2lnbmVyQDE1NDI1MzQzNTQwHhcNMTgxMTE4MDk0NTU0WhcNMjMxMTE3
    # MDk0NTU1WjAmMSQwIgYDVQQDDBtvcGVuc2hpZnQtc2lnbmVyQDE1NDI1MzQzNTQw
    # ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC4PC0rjI1fUK6uAL9H2o1+
    # 0ViboVNfzsvoJvwXH9V7wyrwh8ma0yTtIwaR2ptA+82gpDxbNSzTkI8B1Fyd2cV1
    # PeqTWwnWLzksbI9hkUO3OLlSAh3ANWBEvpl9VtQudTTgglJ7fUmuJ43MmlobmV+S
    # XgVeqy5wUsWnSx7j1ZKo6rl2QQ6bWjRn0UhDRQ1/ppCPprvJ7KxB8FlwL8RP+e/h
    # S5r2rLj3wnCx8TSEHtgzyk4RVMD36ZRU+f7Q+iRlOu8fKyJhmJWfsSfOU0rvql92
    # cmtj1qTELyNQDz1nMv+QWupo5Q5N3c2DZOCeZ+Bj8uIm8dm4OF2xkkNkti2gVR+T
    # AgMBAAGjIzAhMA4GA1UdDwEB/wQEAwICpDAPBgNVHRMBAf8EBTADAQH/MA0GCSqG
    # SIb3DQEBCwUAA4IBAQCLesnRkZxIhydsOISlz414CZykCNvkNWp+8EhwFulGtBkA
    # f7f4C7J4+0nTnW331zyEyTDhiduqawNmXuAjV78Q6rAEzK5rMLV+ci9tlmmb3mxg
    # shPp2YBKr0DgP8xdIxfXJrVHcTEOVC6Te0rISe8KWCMttteEQdjtDxN0QXdNhy8f
    # dpMJrFPFEzjEga5lj0W9sjFxW0lvJdeECLUUYWtzyjwmegcDKsLSvgT2S6lmIZbq
    # ZfMrQqU6rXnSdcYkRomUksR5GGGo//4TokwawMJCSAolKIw6e27/XzdxHXp8i6Do
    # HHgwrl6rP7Yu31KaviZbylyLKJHA71cmq6aeLd5f
    # -----END CERTIFICATE-----

Now import the certificate in the default JVM keystore.

The default password is **changeit**. Confirm with yes when ask to trust the certificates.

    sudo /usr/java/latest/jre/bin/keytool -import -alias minishift -keystore /usr/java/latest/jre/lib/security/cacerts -file /tmp/minishift.crt
    changeit
    y

    # Enter keystore password:  changeit
    # 
    # Owner: CN=openshift-signer@1542534354
    # Issuer: CN=openshift-signer@1542534354
    # Serial number: 1
    # Valid from: Sun Nov 18 09:45:54 UTC 2018 until: Fri Nov 17 09:45:55 UTC 2023
    # Certificate fingerprints:
    # 	 MD5:  B7:9C:23:17:83:EB:FF:81:5E:E5:2E:2A:C4:9A:96:6D
    # 	 SHA1: FA:18:C2:96:4C:1D:FE:A3:95:E3:E5:94:B4:15:20:FD:6E:B5:BD:93
    # 	 SHA256: 4F:1D:96:99:B3:5F:36:22:C3:07:FC:2A:AB:6F:B2:F1:EF:4C:5B:FC:E3:AA:6F:5D:E7:74:25:0F:42:6F:9B:F7
    # Signature algorithm name: SHA256withRSA
    # Subject Public Key Algorithm: 2048-bit RSA key
    # Version: 3
    # 
    # Extensions: 
    # 
    # #1: ObjectId: 2.5.29.19 Criticality=true
    # BasicConstraints:[
    #   CA:true
    #   PathLen:2147483647
    # ]
    # 
    # #2: ObjectId: 2.5.29.15 Criticality=true
    # KeyUsage [
    #   DigitalSignature
    #   Key_Encipherment
    #   Key_CertSign
    # ]
    # 
    # Trust this certificate? [no]:  y
    # y
    # Certificate was added to keystore

Restart the bitbucket service

    sudo service atlbitbucket restart

    # sudo service atlbitbucket restart
    # Stopping Atlassian Bitbucket as dedicated user atlbitbucket
    # 
    # 
    # BITBUCKET_HOME set to /srv/atlassian/bitbucket
    # 
    # ----------------------------------------------------------------------------------
    # Bitbucket is being run with a umask that contains potentially unsafe settings.
    # The following issues were found with the mask "u=rwx,g=rwx,o=rx" (0002):
    #  - access is allowed to 'others'. It is recommended that 'others' be denied
    #    all access for security reasons.
    #  - write access is allowed to 'group'. It is recommend that 'group' be
    #    denied write access. Read access to a restricted group is recommended
    #    to allow access to the logs.
    # 
    # The recommended umask for Bitbucket is "u=,g=w,o=rwx" (0027) and can be
    # configured in setenv.sh
    # ----------------------------------------------------------------------------------
    # Using BITBUCKET_HOME:      /srv/atlassian/bitbucket
    # Using CATALINA_BASE:   /opt/atlassian/bitbucket/4.14.3
    # Using CATALINA_HOME:   /opt/atlassian/bitbucket/4.14.3
    # Using CATALINA_TMPDIR: /opt/atlassian/bitbucket/4.14.3/temp
    # Using JRE_HOME:        /usr/java/jdk1.8.0_192-amd64/jre
    # Using CLASSPATH:       /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar
    # Using CATALINA_PID:    /opt/atlassian/bitbucket/4.14.3/work/catalina.pid
    # Tomcat stopped.
    # Stopped Atlassian Bitbucket at http://localhost:7990/
    # To run Bitbucket in the foreground, start the server with start-bitbucket.sh -fg
    # The current open files limit is set to less than 4096 
    # Attempting to increase limit...
    # Limit increased to 4096 open files
    # Starting Atlassian Bitbucket as dedicated user atlbitbucket 
    # 
    # BITBUCKET_HOME set to /srv/atlassian/bitbucket
    # 
    # ----------------------------------------------------------------------------------
    # Bitbucket is being run with a umask that contains potentially unsafe settings.
    # The following issues were found with the mask "u=rwx,g=rwx,o=rx" (0002):
    #  - access is allowed to 'others'. It is recommended that 'others' be denied
    #    all access for security reasons.
    #  - write access is allowed to 'group'. It is recommend that 'group' be
    #    denied write access. Read access to a restricted group is recommended
    #    to allow access to the logs.
    # 
    # The recommended umask for Bitbucket is "u=,g=w,o=rwx" (0027) and can be
    # configured in setenv.sh
    # ----------------------------------------------------------------------------------
    # Using BITBUCKET_HOME:      /srv/atlassian/bitbucket
    # Using CATALINA_BASE:   /opt/atlassian/bitbucket/4.14.3
    # Using CATALINA_HOME:   /opt/atlassian/bitbucket/4.14.3
    # Using CATALINA_TMPDIR: /opt/atlassian/bitbucket/4.14.3/temp
    # Using JRE_HOME:        /usr/java/jdk1.8.0_192-amd64/jre
    # Using CLASSPATH:       /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar
    # Using CATALINA_PID:    /opt/atlassian/bitbucket/4.14.3/work/catalina.pid
    # Tomcat started.
    # 
    # Success! You can now use Bitbucket at the following address:
    # 
    # http://localhost:7990/
    # 
    # If you cannot access Bitbucket at the above location within 3 minutes, or encounter any other issues starting or stopping Atlassian Bitbucket, please see the troubleshooting guide at:
    # 
    # https://confluence.atlassian.com/display/BitbucketServerKB/Troubleshooting+Installation
    # 

We need this certificate for the Rundeck part later as well


<a id="orgf5dc849"></a>

### Clone the ods-project-quickstarters from your Bitbucket server

On the **atlassian1** server clone the ods-project-quickstarters from your
Bitbucket server.

    sudo su - rundeck

    # sudo su - rundeck
    # Last login: Sun Nov 18 07:40:27 UTC 2018

Use your **crowd login** when asked for credentials. We do this as the rundeck user,
so we can accept the ssh host key.

    git clone http://192.168.56.31:7990/scm/opendevstack/ods-project-quickstarters.git
    vzell
    opendevstack

    # Cloning into 'ods-project-quickstarters'...
    # Username for 'http://192.168.56.31:7990': vzell
    # vzell
    # Password for 'http://vzell@192.168.56.31:7990': opendevstack
    # remote: Counting objects: 934, done.        
    # remote: Compressing objects: 100% (502/502), done.        
    # remote: Total 934 (delta 366), reused 934 (delta 366)        
    # Receiving objects: 100% (934/934), 5.91 MiB | 0 bytes/s, done.
    # Resolving deltas: 100% (366/366), done.
    # Checking connectivity... done.

    git config --global user.email "cd_user@opendevstack.local"

    git config --global user.name "cd_user"

    cat /tmp/minishift.crt >> ods-project-quickstarters/ocp-templates/root.ca/ca-bundle.crt

    cd ods-project-quickstarters

    git commit -am "added local root ca"

    # [master e595a79] added local root ca
    #  1 file changed, 18 insertions(+)

    git push origin master
    vzell
    opendevstack

    # Username for 'http://192.168.56.31:7990': vzell
    # vzell
    # Password for 'http://vzell@192.168.56.31:7990': opendevstack
    # Counting objects: 5, done.
    # Delta compression using up to 2 threads.
    # Compressing objects: 100% (5/5), done.
    # Writing objects: 100% (5/5), 1.16 KiB | 0 bytes/s, done.
    # Total 5 (delta 2), reused 0 (delta 0)
    # To http://192.168.56.31:7990/scm/opendevstack/ods-project-quickstarters.git
    #    7c8e279..e595a79  master -> master


<a id="orgd8061d6"></a>

## TODO Prepare environment settings

Switch to your local machine and clone the repositories:
**ods-configuration-sample** and **ods-configuration** from your bitbucket server
(Assuming your host/ip for bitbucket is: 192.168.56.31:7990). Copy the entire
directory structure from ods-configuration-sample into ods-configurationand
remove the .sample postfixes.

    cd /misc/vagrant/opendevstack

    git clone http://192.168.56.31:7990/scm/opendevstack/ods-configuration-sample.git
    vzell
    opendevstack

    git clone http://192.168.56.31:7990/scm/opendevstack/ods-configuration.git
    vzell
    opendevstack

    # Cloning into 'ods-configuration'...
    # warning: You appear to have cloned an empty repository.

    cp -vr ./ods-configuration-sample/. ./ods-configuration

    # './ods-configuration-sample/./.git/description' -> './ods-configuration/./.git/description'
    # './ods-configuration-sample/./.git/hooks/applypatch-msg.sample' -> './ods-configuration/./.git/hooks/applypatch-msg.sample'
    # './ods-configuration-sample/./.git/hooks/commit-msg.sample' -> './ods-configuration/./.git/hooks/commit-msg.sample'
    # './ods-configuration-sample/./.git/hooks/fsmonitor-watchman.sample' -> './ods-configuration/./.git/hooks/fsmonitor-watchman.sample'
    # './ods-configuration-sample/./.git/hooks/post-update.sample' -> './ods-configuration/./.git/hooks/post-update.sample'
    # './ods-configuration-sample/./.git/hooks/pre-applypatch.sample' -> './ods-configuration/./.git/hooks/pre-applypatch.sample'
    # './ods-configuration-sample/./.git/hooks/pre-commit.sample' -> './ods-configuration/./.git/hooks/pre-commit.sample'
    # './ods-configuration-sample/./.git/hooks/pre-push.sample' -> './ods-configuration/./.git/hooks/pre-push.sample'
    # './ods-configuration-sample/./.git/hooks/pre-rebase.sample' -> './ods-configuration/./.git/hooks/pre-rebase.sample'
    # './ods-configuration-sample/./.git/hooks/pre-receive.sample' -> './ods-configuration/./.git/hooks/pre-receive.sample'
    # './ods-configuration-sample/./.git/hooks/prepare-commit-msg.sample' -> './ods-configuration/./.git/hooks/prepare-commit-msg.sample'
    # './ods-configuration-sample/./.git/hooks/update.sample' -> './ods-configuration/./.git/hooks/update.sample'
    # './ods-configuration-sample/./.git/info/exclude' -> './ods-configuration/./.git/info/exclude'
    # './ods-configuration-sample/./.git/refs/heads/master' -> './ods-configuration/./.git/refs/heads/master'
    # './ods-configuration-sample/./.git/refs/remotes' -> './ods-configuration/./.git/refs/remotes'
    # './ods-configuration-sample/./.git/refs/remotes/origin' -> './ods-configuration/./.git/refs/remotes/origin'
    # './ods-configuration-sample/./.git/refs/remotes/origin/HEAD' -> './ods-configuration/./.git/refs/remotes/origin/HEAD'
    # './ods-configuration-sample/./.git/packed-refs' -> './ods-configuration/./.git/packed-refs'
    # './ods-configuration-sample/./.git/logs' -> './ods-configuration/./.git/logs'
    # './ods-configuration-sample/./.git/logs/refs' -> './ods-configuration/./.git/logs/refs'
    # './ods-configuration-sample/./.git/logs/refs/remotes' -> './ods-configuration/./.git/logs/refs/remotes'
    # './ods-configuration-sample/./.git/logs/refs/remotes/origin' -> './ods-configuration/./.git/logs/refs/remotes/origin'
    # './ods-configuration-sample/./.git/logs/refs/remotes/origin/HEAD' -> './ods-configuration/./.git/logs/refs/remotes/origin/HEAD'
    # './ods-configuration-sample/./.git/logs/refs/heads' -> './ods-configuration/./.git/logs/refs/heads'
    # './ods-configuration-sample/./.git/logs/refs/heads/master' -> './ods-configuration/./.git/logs/refs/heads/master'
    # './ods-configuration-sample/./.git/logs/HEAD' -> './ods-configuration/./.git/logs/HEAD'
    # './ods-configuration-sample/./.git/HEAD' -> './ods-configuration/./.git/HEAD'
    # './ods-configuration-sample/./.git/config' -> './ods-configuration/./.git/config'
    # './ods-configuration-sample/./.git/objects/pack/pack-29025d8a7d407e4e5a78366cddd6d068683fb9bc.idx' -> './ods-configuration/./.git/objects/pack/pack-29025d8a7d407e4e5a78366cddd6d068683fb9bc.idx'
    # './ods-configuration-sample/./.git/objects/pack/pack-29025d8a7d407e4e5a78366cddd6d068683fb9bc.pack' -> './ods-configuration/./.git/objects/pack/pack-29025d8a7d407e4e5a78366cddd6d068683fb9bc.pack'
    # './ods-configuration-sample/./.git/index' -> './ods-configuration/./.git/index'
    # './ods-configuration-sample/./.gitignore' -> './ods-configuration/./.gitignore'
    # './ods-configuration-sample/./CHANGELOG.md' -> './ods-configuration/./CHANGELOG.md'
    # './ods-configuration-sample/./LICENSE' -> './ods-configuration/./LICENSE'
    # './ods-configuration-sample/./README.md' -> './ods-configuration/./README.md'
    # './ods-configuration-sample/./ods-configuration.env.sample' -> './ods-configuration/./ods-configuration.env.sample'
    # './ods-configuration-sample/./ods-core' -> './ods-configuration/./ods-core'
    # './ods-configuration-sample/./ods-core/jenkins' -> './ods-configuration/./ods-core/jenkins'
    # './ods-configuration-sample/./ods-core/jenkins/ocp-config' -> './ods-configuration/./ods-core/jenkins/ocp-config'
    # './ods-configuration-sample/./ods-core/jenkins/ocp-config/bc.env.sample' -> './ods-configuration/./ods-core/jenkins/ocp-config/bc.env.sample'
    # './ods-configuration-sample/./ods-core/nexus' -> './ods-configuration/./ods-core/nexus'
    # './ods-configuration-sample/./ods-core/nexus/ocp-config' -> './ods-configuration/./ods-core/nexus/ocp-config'
    # './ods-configuration-sample/./ods-core/nexus/ocp-config/pvc.env.sample' -> './ods-configuration/./ods-core/nexus/ocp-config/pvc.env.sample'
    # './ods-configuration-sample/./ods-core/nexus/ocp-config/route.env.sample' -> './ods-configuration/./ods-core/nexus/ocp-config/route.env.sample'
    # './ods-configuration-sample/./ods-core/shared-images' -> './ods-configuration/./ods-core/shared-images'
    # './ods-configuration-sample/./ods-core/shared-images/nginx-authproxy-crowd' -> './ods-configuration/./ods-core/shared-images/nginx-authproxy-crowd'
    # './ods-configuration-sample/./ods-core/shared-images/nginx-authproxy-crowd/ocp-config' -> './ods-configuration/./ods-core/shared-images/nginx-authproxy-crowd/ocp-config'
    # './ods-configuration-sample/./ods-core/shared-images/nginx-authproxy-crowd/ocp-config/bc.env.sample' -> './ods-configuration/./ods-core/shared-images/nginx-authproxy-crowd/ocp-config/bc.env.sample'
    # './ods-configuration-sample/./ods-core/shared-images/nginx-authproxy-crowd/ocp-config/secret.env.sample' -> './ods-configuration/./ods-core/shared-images/nginx-authproxy-crowd/ocp-config/secret.env.sample'
    # './ods-configuration-sample/./ods-core/sonarqube' -> './ods-configuration/./ods-core/sonarqube'
    # './ods-configuration-sample/./ods-core/sonarqube/ocp-config' -> './ods-configuration/./ods-core/sonarqube/ocp-config'
    # './ods-configuration-sample/./ods-core/sonarqube/ocp-config/sonarqube.env.sample' -> './ods-configuration/./ods-core/sonarqube/ocp-config/sonarqube.env.sample'
    # './ods-configuration-sample/./ods-project-quickstarters' -> './ods-configuration/./ods-project-quickstarters'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/maven' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/maven'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/maven/ocp-config' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/maven/ocp-config'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/maven/ocp-config/bc.env.sample' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/maven/ocp-config/bc.env.sample'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/nodejs8-angular' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/nodejs8-angular'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/nodejs8-angular/ocp-config' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/nodejs8-angular/ocp-config'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/nodejs8-angular/ocp-config/bc.env.sample' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/nodejs8-angular/ocp-config/bc.env.sample'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/python' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/python'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/python/ocp-config' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/python/ocp-config'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/python/ocp-config/bc.env.sample' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/python/ocp-config/bc.env.sample'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/scala' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/scala'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/scala/ocp-config' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/scala/ocp-config'
    # './ods-configuration-sample/./ods-project-quickstarters/jenkins-slaves/scala/ocp-config/bc.env.sample' -> './ods-configuration/./ods-project-quickstarters/jenkins-slaves/scala/ocp-config/bc.env.sample'
    # './ods-configuration-sample/./ods-project-quickstarters/ocp-templates' -> './ods-configuration/./ods-project-quickstarters/ocp-templates'
    # './ods-configuration-sample/./ods-project-quickstarters/ocp-templates/scripts' -> './ods-configuration/./ods-project-quickstarters/ocp-templates/scripts'
    # './ods-configuration-sample/./ods-project-quickstarters/ocp-templates/scripts/ocp_project_config_source' -> './ods-configuration/./ods-project-quickstarters/ocp-templates/scripts/ocp_project_config_source'
    # './ods-configuration-sample/./ods-project-quickstarters/ocp-templates/scripts/ocp_project_config_target' -> './ods-configuration/./ods-project-quickstarters/ocp-templates/scripts/ocp_project_config_target'
    # './ods-configuration-sample/./ods-project-quickstarters/ocp-templates/templates' -> './ods-configuration/./ods-project-quickstarters/ocp-templates/templates'
    # './ods-configuration-sample/./ods-project-quickstarters/ocp-templates/templates/templates.env.sample' -> './ods-configuration/./ods-project-quickstarters/ocp-templates/templates/templates.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app' -> './ods-configuration/./ods-provisioning-app'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config' -> './ods-configuration/./ods-provisioning-app/ocp-config'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-cd' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-cd'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-cd/bc.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-cd/bc.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-cd/dc.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-cd/dc.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-cd/pvc.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-cd/pvc.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-cd/route.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-cd/route.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-cd/secret.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-cd/secret.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-dev' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-dev'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-dev/cm.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-dev/cm.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-dev/pvc.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-dev/pvc.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-dev/route.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-dev/route.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-dev/secret.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-dev/secret.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-test' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-test'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-test/cm.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-test/cm.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-test/pvc.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-test/pvc.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-test/route.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-test/route.env.sample'
    # './ods-configuration-sample/./ods-provisioning-app/ocp-config/prov-test/secret.env.sample' -> './ods-configuration/./ods-provisioning-app/ocp-config/prov-test/secret.env.sample'
    # './ods-configuration-sample/./.gitattributes' -> './ods-configuration/./.gitattributes'

    find ods-configuration -name '*.sample' -type f | while read NAME ; do mv "${NAME}" "${NAME%.sample}" ; done

Now you will have to check the **.env** configuration files in
**ods-configuration**. Change all values with the suffix **\_base64** to a Base64
encoded value.

Also change ****REPO\_BASE**** in all .env files to

    REPO_BASE=http://192.168.56.31:7990/scm


<a id="orga5290e5"></a>

## Setup and Configure Nexus3

Amend `ods-configuration/ods-core/nexus/ocp-config/route.env` and change the
domain to match your openshift/minishift domain (for example
**nexus-cd.192.168.99.100.nip.io**)

    cat /misc/vagrant/opendevstack/ods-configuration/ods-core/nexus/ocp-config/route.env

    # # Nexus setup
    # 
    # # Nexus host without protocol - which is attached based on the configuration in the route.yml
    # NEXUS_HOST=nexus-cd.192.168.99.100.nip.io

Go to `ods-core/nexus/ocp-config` - and type `oc-tailor update`

    cd /misc/vagrant/opendevstack/ods-core/nexus/ocp-config

    oc-tailor update
    y

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-core\nexus\ocp-config with OCP namespace cd.
    # Limiting resources to dc,is,pvc,route,svc with selector app=nexus3.
    # Found 0 resources in OCP cluster (current state) and 5 resources in processed templates (desired state).
    # 
    # + dc/nexus3 to be created
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,59 @@
    # +apiVersion: apps.openshift.io/v1
    # +kind: DeploymentConfig
    # +metadata:
    # +  annotations:
    # +    original-values.tailor.io/spec.template.spec.containers.0.image: sonatype/nexus3:latest
    # +  creationTimestamp: null
    # +  labels:
    # +    app: nexus3
    # +  name: nexus3
    # +spec:
    # +  replicas: 1
    # +  selector:
    # +    app: nexus3
    # +    deploymentconfig: nexus3
    # +  strategy:
    # +    activeDeadlineSeconds: 21600
    # +    recreateParams:
    # +      timeoutSeconds: 600
    # +    resources: {}
    # +    type: Recreate
    # +  template:
    # +    metadata:
    # +      annotations: {}
    # +      creationTimestamp: null
    # +      labels:
    # +        app: nexus3
    # +        deploymentconfig: nexus3
    # +    spec:
    # +      containers:
    # +      - image: sonatype/nexus3:latest
    # +        imagePullPolicy: Always
    # +        name: nexus3
    # +        ports:
    # +        - containerPort: 8081
    # +          protocol: TCP
    # +        resources: {}
    # +        terminationMessagePath: /dev/termination-log
    # +        terminationMessagePolicy: File
    # +        volumeMounts:
    # +        - mountPath: /nexus-data
    # +          name: volume-fmcqy
    # +        - mountPath: /nexus-backup
    # +          name: volume-8dv8t
    # +      dnsPolicy: ClusterFirst
    # +      restartPolicy: Always
    # +      schedulerName: default-scheduler
    # +      securityContext: {}
    # +      terminationGracePeriodSeconds: 30
    # +      volumes:
    # +      - name: volume-fmcqy
    # +        persistentVolumeClaim:
    # +          claimName: nexus-data-extended
    # +      - name: volume-8dv8t
    # +        persistentVolumeClaim:
    # +          claimName: nexus-db-backup
    # +  test: false
    # +  triggers:
    # +  - type: ConfigChange
    #  
    # + pvc/nexus-data-extended to be created
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,17 @@
    # +apiVersion: v1
    # +kind: PersistentVolumeClaim
    # +metadata:
    # +  annotations:
    # +    volume.beta.kubernetes.io/storage-class: ""
    # +    volume.beta.kubernetes.io/storage-provisioner: ""
    # +  creationTimestamp: null
    # +  labels:
    # +    app: nexus3
    # +  name: nexus-data-extended
    # +spec:
    # +  accessModes:
    # +  - ReadWriteOnce
    # +  resources:
    # +    requests:
    # +      storage: 60Gi
    #  
    # + pvc/nexus-db-backup to be created
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,17 @@
    # +apiVersion: v1
    # +kind: PersistentVolumeClaim
    # +metadata:
    # +  annotations:
    # +    volume.beta.kubernetes.io/storage-class: ""
    # +    volume.beta.kubernetes.io/storage-provisioner: ""
    # +  creationTimestamp: null
    # +  labels:
    # +    app: nexus3
    # +  name: nexus-db-backup
    # +spec:
    # +  accessModes:
    # +  - ReadWriteOnce
    # +  resources:
    # +    requests:
    # +      storage: 10Gi
    #  
    # + route/nexus3 to be created
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,21 @@
    # +apiVersion: route.openshift.io/v1
    # +kind: Route
    # +metadata:
    # +  annotations: {}
    # +  creationTimestamp: null
    # +  labels:
    # +    app: nexus3
    # +  name: nexus3
    # +spec:
    # +  host: nexus-cd.192.168.99.100.nip.io
    # +  port:
    # +    targetPort: 8081-tcp
    # +  tls:
    # +    insecureEdgeTerminationPolicy: Redirect
    # +    termination: edge
    # +  to:
    # +    kind: Service
    # +    name: nexus3
    # +    weight: 100
    # +  wildcardPolicy: None
    #  
    # + svc/nexus3 to be created
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,19 @@
    # +apiVersion: v1
    # +kind: Service
    # +metadata:
    # +  annotations: {}
    # +  creationTimestamp: null
    # +  labels:
    # +    app: nexus3
    # +  name: nexus3
    # +spec:
    # +  ports:
    # +  - name: 8081-tcp
    # +    port: 8081
    # +    protocol: TCP
    # +    targetPort: 8081
    # +  selector:
    # +    deploymentconfig: nexus3
    # +  sessionAffinity: None
    # +  type: ClusterIP
    #  
    # 
    # Apply changes? [y/n]: y
    # Creating DeploymentConfig nexus3
    # Applied processed DeploymentConfig template.
    # Creating PersistentVolumeClaim nexus-data-extended
    # Applied processed PersistentVolumeClaim template.
    # Creating PersistentVolumeClaim nexus-db-backup
    # Applied processed PersistentVolumeClaim template.
    # Creating Route nexus3
    # Applied processed Route template.
    # Creating Service nexus3
    # Applied processed Service template.

    oc-tailor status -l app=nexus3 -n cd


<a id="org1f7027e"></a>

### Configure Repository Manager

Access Nexus3

<http://nexus-cd.192.168.99.100.nip.io/>

Click on **Sign in** and login with the default credentials for Nexus3:

    username: admin
    password: admin123


<a id="orgfa7425c"></a>

### TODO Configure repositories

Open the **Server administration and configuration** menu by clicking the **gear
icon** in the top bar. Now create three **Blob Stores**.

Administation->Repository->Blob Stores

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Type</th>
<th scope="col" class="org-left">Name</th>
<th scope="col" class="org-left">Path</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">File</td>
<td class="org-left">candidates</td>
<td class="org-left">/nexus-data/blobs/candidates</td>
</tr>


<tr>
<td class="org-left">File</td>
<td class="org-left">releases</td>
<td class="org-left">/nexus-data/blobs/releases</td>
</tr>


<tr>
<td class="org-left">File</td>
<td class="org-left">atlassian\_public</td>
<td class="org-left">/nexus-data/blobs/atlassian\_public</td>
</tr>
</tbody>
</table>

After this step you will have to create the following repositories in the
**Repositories** Subsection.

Administation->Repository->Repositories

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Format</th>
<th scope="col" class="org-left">Type</th>
<th scope="col" class="org-left">Name</th>
<th scope="col" class="org-left">Online</th>
<th scope="col" class="org-left">Version policy</th>
<th scope="col" class="org-left">Layout policy</th>
<th scope="col" class="org-left">Storage</th>
<th scope="col" class="org-left">Strict Content Type Validation</th>
<th scope="col" class="org-left">Deployment policy</th>
<th scope="col" class="org-left">Remote Storage</th>
<th scope="col" class="org-left">belongs to group</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">maven2</td>
<td class="org-left">hosted</td>
<td class="org-left">candidates</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">Strict</td>
<td class="org-left">candidates</td>
<td class="org-left">checked</td>
<td class="org-left">Disable-redeploy</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">none</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">hosted</td>
<td class="org-left">releases</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">Strict</td>
<td class="org-left">releases</td>
<td class="org-left">checked</td>
<td class="org-left">Disable-redeploy</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">none</td>
</tr>


<tr>
<td class="org-left">npm</td>
<td class="org-left">proxy</td>
<td class="org-left">npmjs</td>
<td class="org-left">checked</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">default</td>
<td class="org-left">checked</td>
<td class="org-left">&#xa0;</td>
<td class="org-left"><https://registry.npmjs.org></td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">proxy</td>
<td class="org-left">atlassian\_public</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">Strict</td>
<td class="org-left">atlassian\_public</td>
<td class="org-left">checked</td>
<td class="org-left">Disable-redeploy !</td>
<td class="org-left"><https://maven.atlassian.com/content/repositories/atlassian-public/></td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">proxy</td>
<td class="org-left">jcenter</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">Strict</td>
<td class="org-left">default</td>
<td class="org-left">checked</td>
<td class="org-left">Disable-redeploy !</td>
<td class="org-left"><https://jcenter.bintray.com></td>
<td class="org-left">maven-public</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">proxy</td>
<td class="org-left">sbt-plugins</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">permissive</td>
<td class="org-left">default</td>
<td class="org-left">unchecked</td>
<td class="org-left">Disable-redeploy !</td>
<td class="org-left"><http://dl.bintray.com/sbt/sbt-plugin-releases/></td>
<td class="org-left">ivy-releases</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">proxy</td>
<td class="org-left">sbt-releases</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">permissive</td>
<td class="org-left">default</td>
<td class="org-left">unchecked</td>
<td class="org-left">Disable-redeploy !</td>
<td class="org-left"><https://repo.scala-sbt.org/scalasbt/sbt-plugin-releases></td>
<td class="org-left">ivy-releases</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">proxy</td>
<td class="org-left">typesafe-ivy-releases</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">permissive</td>
<td class="org-left">default</td>
<td class="org-left">unchecked</td>
<td class="org-left">Disable-redeploy !</td>
<td class="org-left"><https://dl.bintray.com/typesafe/ivy-releases></td>
<td class="org-left">ivy-releases</td>
</tr>


<tr>
<td class="org-left">maven2</td>
<td class="org-left">group</td>
<td class="org-left">ivy-releases</td>
<td class="org-left">checked</td>
<td class="org-left">Release</td>
<td class="org-left">permissive</td>
<td class="org-left">default</td>
<td class="org-left">unchecked</td>
<td class="org-left">Disable-redeploy !</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">?typesafe-ivy-releases?</td>
</tr>
</tbody>
</table>


<a id="org78566fa"></a>

### Configure user and roles

First disable the anonymous access in the **Security > Anonymous** section.

[ ] Allow anonymous users to access the server

Under **Security > Roles** create a nexus-role **OpenDevStack-Developer**.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Role ID</th>
<th scope="col" class="org-left">Role name</th>
<th scope="col" class="org-left">Role description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">opendevstack-developer</td>
<td class="org-left">OpenDevStack-Developer</td>
<td class="org-left">Role for access from OpenDevStack</td>
</tr>
</tbody>
</table>

This role has to have the following privileges:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Privilege</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">nx-repository-admin-maven2-candidates-browse</td>
</tr>


<tr>
<td class="org-left">nx-repository-admin-maven2-candidates-edit</td>
</tr>


<tr>
<td class="org-left">nx-repository-admin-maven2-candidates-read</td>
</tr>


<tr>
<td class="org-left">nx-repository-view-maven2-**-**</td>
</tr>


<tr>
<td class="org-left">nx-repository-view-maven2-candidates-\*</td>
</tr>


<tr>
<td class="org-left">nx-repository-view-npm-**-**</td>
</tr>
</tbody>
</table>

Now create a user under **Security > Users**.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Name</th>
<th scope="col" class="org-left">Password</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">developer</td>
<td class="org-left">developer</td>
</tr>
</tbody>
</table>

You can choose any First name, Last name and Email. Make this account **active**
and assign role **OpenDevStack-Developer** to this account.

This account is later used for authentication against nexus to pull artifacts during build phase


<a id="org7709d1b"></a>

## Configure CD user

The continuous delivery process requires a dedicated system user in **crowd** for
accessing **bitbucket**. 

Access the crowd console

<http://192.168.56.31:8095/crowd/console/>

Choose **Add user** in the **Users** menu. Enter valid credentials. The only restriction
here is, that the user has the username **cd\_user** and that the user belongs to the
**internal crowd directory**. 

    Email address: cd_user@opendevstack.com
    [x] Active
    Username: cd_user
    Password: opendevstack
    Confirm password: opendevstack
    First name: CDUserFirst
    Last name: CDUserLast
    Directory: OpenDevStack

After creating the user you have to add the following groups:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Group</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">opendevstack-users</td>
</tr>


<tr>
<td class="org-left">bitbucket-users</td>
</tr>
</tbody>
</table>

Click on the **Groups** tab and then **Add groups**.

After you have created the user in crowd, you must add the public cd\_user SSH
key to the Bitbucket account.

Open **Bitbucket**

<http://192.168.56.31:7990/dashboard>

Login with your crowd administration user and click on the **Administration** gear
icon. Here open the **Users** section. If you can’t see the **CD user**, you have to
**synchronize** the Crowd directory in the **User directories** section.

Go back to the **Users** section and click on the **CD user**. In the user details
you have the possiblity to add a SSH key. Click on the **SSH keys** tab and enter
the public key from the generated key pair, after clicking the **Add key** button.

    # ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIFfxfrg+A/QOpnNcISlcK1mX37UWHi3g5Xq7ORhVbUd2Fe5L9q8QqJlILN5z20uL285KS1LqZ8HYmDCnpis0CMMvuXjK4SSFzfJx0Yizz8+4wcry2HSuAlWafV2oDDr7n0215otgqi2HFxNikyXfhss6fTgERqAZHKLHT8fNX4hNajspkweqlUyOcgLvYd07HiR/n08lUp7TdAze1DYk/wVsSq0yiGLp3kIg1B0EwITuyHaoPlxRVEGuceAgBTZ3r3j0rxlJGFEIo8CpzQwH+vV80CNXrFMfzagLrXpzIUDj6gdieDp2aQvDg2tL9U6booQFg4y8iC0M2O6BcJ2uj CD User


<a id="orgd788c87"></a>

## TODO Import base templates


<a id="org221fece"></a>

### Preparation

After you have configured Nexus3, import the base templates for OpenShift. Clone
the ods-project-quickstarters. 

    cd /misc/vagrant/opendevstack

    git clone https://github.com/opendevstack/ods-project-quickstarters

Navigate to the folder, where the cloned repository is located and navigate to
the **ocp-templates/scripts** subfolder.

    cd /misc/vagrant/opendevstack/ods-project-quickstarters/ocp-templates/scripts

From with this folder, check if you are still logged in to the OpenShift CLI and
login, if necessary.

    oc login -u system:admin

    # Logged into "https://192.168.99.100:8443" as "system:admin" using existing credentials.
    # 
    # You have access to the following projects and can switch between them with 'oc project <projectname>':
    # 
    #   * cd
    #     default
    #     kube-dns
    #     kube-proxy
    #     kube-public
    #     kube-system
    #     myproject
    #     openshift
    #     openshift-apiserver
    #     openshift-controller-manager
    #     openshift-core-operators
    #     openshift-infra
    #     openshift-node
    #     openshift-web-console
    # 
    # Using project "cd".

Amend `ods-configuration/ods-project-quickstarters/ocp-templates/templates/templates.env`
and run

    grep "_base64" /misc/vagrant/opendevstack/ods-configuration/ods-project-quickstarters/ocp-templates/templates/templates.env

    # CD_USER_ID=cd_user_base64
    # CD_USER_PWD=changeme_base64
    # NEXUS_PASSWORD=changeme_base64
    # SONAR_SERVER_AUTH_TOKEN=changme_base64
    # CROWD_RSHINY_REALM_USER=rshiny_base64
    # CROWD_RSHINY_REALM_PW=changeme_base64

    echo -n 'cd_user' | base64

    # Y2RfdXNlcg==

    echo -n 'opendevstack' | base64

    # b3BlbmRldnN0YWNr

    echo -n 'developer' | base64

    # ZGV2ZWxvcGVy

    echo -n 'opendevstack' | base64

    # b3BlbmRldnN0YWNr

    echo -n 'rshiny' | base64

    # cnNoaW55

    echo -n 'opendevstack' | base64

    # b3BlbmRldnN0YWNr

    echo -n 'sonarqube' | base64

    # c29uYXJxdWJl


<a id="orgfc4e5c2"></a>

### Upload

    ./upload-templates.sh

    # template.template.openshift.io/cd-jenkins-persistent created
    # template.template.openshift.io/component-environment created
    # template.template.openshift.io/component-route created
    # template.template.openshift.io/component-pipeline created
    # template.template.openshift.io/bc-docker created
    # template.template.openshift.io/secrets created
    # template.template.openshift.io/rshiny-app created


<a id="org4256695"></a>

## TODO Create secrets inside the CD project

    cd /misc/vagrant/opendevstack/ods-project-quickstarters/ocp-templates

    oc process -n cd templates/secrets -p PROJECT=cd | oc create -n cd -f-

    # secret/cd-user-token created


<a id="org6390f16"></a>

## TODO Setup and configure Sonarqube

Amend `ods-configuration/ods-core/sonarqube/ocp-config/sonarqube.env`

    cd /misc/vagrant/opendevstack/ods-core/sonarqube/ocp-config

and type **oc-tailor update** confirm with y and installation should start.

    oc-tailor update
    y

New output

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-core\sonarqube\ocp-config with OCP namespace cd.
    # Limiting resources to bc,dc,is,pvc,route,svc,secret,configmap with selector app=sonarqube.
    # Found 13 resources in OCP cluster (current state) and 13 resources in processed templates (desired state).
    # 
    # * bc/sonarqube is in sync
    # * is/sonarqube is in sync
    # * route/sonarqube is in sync
    # * secret/sonarqube-app is in sync
    # * cm/sonarqube is in sync
    # * secret/sonarqube-postgresql is in sync
    # * svc/sonarqube-postgresql is in sync
    # * svc/sonarqube is in sync
    # ~ pvc/sonarqube-postgresql to update
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -4,8 +4,6 @@
    #    annotations:
    #      managed-annotations.tailor.opendevstack.org: volume.beta.kubernetes.io/storage-provisioner
    #      volume.beta.kubernetes.io/storage-provisioner: ""
    # -  finalizers:
    # -  - kubernetes.io/pvc-protection
    #    labels:
    #      app: sonarqube
    #      template: postgresql-persistent-template
    # ~ pvc/sonarqube-data to update
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -4,8 +4,6 @@
    #    annotations:
    #      managed-annotations.tailor.opendevstack.org: volume.beta.kubernetes.io/storage-provisioner
    #      volume.beta.kubernetes.io/storage-provisioner: ""
    # -  finalizers:
    # -  - kubernetes.io/pvc-protection
    #    labels:
    #      app: sonarqube
    #    name: sonarqube-data
    # ~ pvc/sonarqube-extensions to update
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -4,8 +4,6 @@
    #    annotations:
    #      managed-annotations.tailor.opendevstack.org: volume.beta.kubernetes.io/storage-provisioner
    #      volume.beta.kubernetes.io/storage-provisioner: ""
    # -  finalizers:
    # -  - kubernetes.io/pvc-protection
    #    labels:
    #      app: sonarqube
    #    name: sonarqube-extensions
    # ~ dc/sonarqube-postgresql to update
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -11,7 +11,6 @@
    #    name: sonarqube-postgresql
    #  spec:
    #    replicas: 1
    # -  revisionHistoryLimit: 10
    #    selector:
    #      name: sonarqube-postgresql
    #    strategy:
    # @@ -100,7 +99,6 @@
    #          kind: ImageStreamTag
    #          name: postgresql:9.5
    #          namespace: openshift
    # -      lastTriggeredImage: 172.30.1.1:5000/openshift/postgresql@sha256:ce9c42f4c807b843c372d55e056ca179b147352bf73df369af46e7b252ad779b
    #      type: ImageChange
    #    - type: ConfigChange
    #  
    # ~ dc/sonarqube to update
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -8,7 +8,6 @@
    #    name: sonarqube
    #  spec:
    #    replicas: 1
    # -  revisionHistoryLimit: 10
    #    selector:
    #      app: sonarqube
    #      deploymentconfig: sonarqube
    # @@ -94,6 +93,5 @@
    #          kind: ImageStreamTag
    #          name: sonarqube:latest
    #          namespace: cd
    # -      lastTriggeredImage: sonarqube@sha256:e36dcf59f4da62694a6e8265e6c56ca18596f59880f4cb6dd2c9efc6e0022405
    #      type: ImageChange
    #  
    # 
    # Summary: 8 in sync, 0 to create, 5 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Patch PersistentVolumeClaim sonarqube-postgresql
    # Patch PersistentVolumeClaim sonarqube-data
    # Patch PersistentVolumeClaim sonarqube-extensions
    # Patch DeploymentConfig sonarqube-postgresql
    # Patch DeploymentConfig sonarqube

Old output

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-core\sonarqube\ocp-config with OCP namespace cd.
    # Limiting resources to bc,dc,is,pvc,route,svc,secret,configmap with selector app=sonarqube.
    # Found 0 resources in OCP cluster (current state) and 13 resources in processed templates (desired state).
    # 
    # + cm/sonarqube to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,15 @@
    # +apiVersion: v1
    # +data:
    # +  crowd-application: sonarqube
    # +  crowd-url: http://192.168.56.31:8095/crowd
    # +  database-jdbc-url: jdbc:postgresql://sonarqube-postgresql:5432/sonarqube
    # +  database-name: sonarqube
    # +  database-user: sonarqube
    # +  sonarqube-admin-user: admin
    # +kind: ConfigMap
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube
    #  
    # + secret/sonarqube-app to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,13 @@
    # +apiVersion: v1
    # +data:
    # +  admin-password: b3BlbmRldnN0YWNr
    # +  auth-token: b3BlbmRldnN0YWNr
    # +  crowd-password: c29uYXJxdWJl
    # +kind: Secret
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube-app
    # +type: Opaque
    #  
    # + secret/sonarqube-postgresql to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,16 @@
    # +apiVersion: v1
    # +data:
    # +  database-password: c29uYXJxdWJl
    # +kind: Secret
    # +metadata:
    # +  annotations:
    # +    managed-annotations.tailor.opendevstack.org: template.openshift.io/expose-database_name,template.openshift.io/expose-password,template.openshift.io/expose-username
    # +    template.openshift.io/expose-database_name: '{.data[''database-name'']}'
    # +    template.openshift.io/expose-password: '{.data[''database-password'']}'
    # +    template.openshift.io/expose-username: '{.data[''database-user'']}'
    # +  labels:
    # +    app: sonarqube
    # +    template: postgresql-persistent-template
    # +  name: sonarqube-postgresql
    # +type: Opaque
    #  
    # + pvc/sonarqube-postgresql to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,18 @@
    # +apiVersion: v1
    # +kind: PersistentVolumeClaim
    # +metadata:
    # +  annotations:
    # +    managed-annotations.tailor.opendevstack.org: volume.beta.kubernetes.io/storage-provisioner
    # +    volume.beta.kubernetes.io/storage-provisioner: ""
    # +  labels:
    # +    app: sonarqube
    # +    template: postgresql-persistent-template
    # +  name: sonarqube-postgresql
    # +spec:
    # +  accessModes:
    # +  - ReadWriteOnce
    # +  resources:
    # +    requests:
    # +      storage: 2Gi
    # +  storageClassName: ""
    #  
    # + pvc/sonarqube-data to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,17 @@
    # +apiVersion: v1
    # +kind: PersistentVolumeClaim
    # +metadata:
    # +  annotations:
    # +    managed-annotations.tailor.opendevstack.org: volume.beta.kubernetes.io/storage-provisioner
    # +    volume.beta.kubernetes.io/storage-provisioner: ""
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube-data
    # +spec:
    # +  accessModes:
    # +  - ReadWriteOnce
    # +  resources:
    # +    requests:
    # +      storage: 2Gi
    # +  storageClassName: ""
    #  
    # + pvc/sonarqube-extensions to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,17 @@
    # +apiVersion: v1
    # +kind: PersistentVolumeClaim
    # +metadata:
    # +  annotations:
    # +    managed-annotations.tailor.opendevstack.org: volume.beta.kubernetes.io/storage-provisioner
    # +    volume.beta.kubernetes.io/storage-provisioner: ""
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube-extensions
    # +spec:
    # +  accessModes:
    # +  - ReadWriteOnce
    # +  resources:
    # +    requests:
    # +      storage: 1Gi
    # +  storageClassName: ""
    #  
    # + is/sonarqube to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube
    # +spec:
    # +  dockerImageRepository: sonarqube
    # +  lookupPolicy:
    # +    local: false
    #  
    # + bc/sonarqube to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,31 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube
    # +spec:
    # +  failedBuildsHistoryLimit: 5
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: sonarqube:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: sonarqube
    # +    git:
    # +      ref: production
    # +      uri: http://192.168.56.31:7990/scm/opendevstack/ods-core.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy: {}
    # +    type: Docker
    # +  successfulBuildsHistoryLimit: 5
    # +  triggers: []
    #  
    # + dc/sonarqube-postgresql to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,104 @@
    # +apiVersion: apps.openshift.io/v1
    # +kind: DeploymentConfig
    # +metadata:
    # +  annotations:
    # +    managed-annotations.tailor.opendevstack.org: template.alpha.openshift.io/wait-for-ready
    # +    original-values.tailor.io/spec.template.spec.containers.0.image: registry.access.redhat.com/rhscl/postgresql-95-rhel7@sha256:de66da4812f0de42cee0bef65899d75f8b1a7440858271f133c8f73c80be663d
    # +    template.alpha.openshift.io/wait-for-ready: "true"
    # +  labels:
    # +    app: sonarqube
    # +    template: postgresql-persistent-template
    # +  name: sonarqube-postgresql
    # +spec:
    # +  replicas: 1
    # +  selector:
    # +    name: sonarqube-postgresql
    # +  strategy:
    # +    activeDeadlineSeconds: 21600
    # +    recreateParams:
    # +      timeoutSeconds: 600
    # +    resources: {}
    # +    type: Recreate
    # +  template:
    # +    metadata:
    # +      annotations: {}
    # +      labels:
    # +        name: sonarqube-postgresql
    # +    spec:
    # +      containers:
    # +      - env:
    # +        - name: POSTGRESQL_USER
    # +          valueFrom:
    # +            configMapKeyRef:
    # +              key: database-user
    # +              name: sonarqube
    # +        - name: POSTGRESQL_PASSWORD
    # +          valueFrom:
    # +            secretKeyRef:
    # +              key: database-password
    # +              name: sonarqube-postgresql
    # +        - name: POSTGRESQL_DATABASE
    # +          valueFrom:
    # +            configMapKeyRef:
    # +              key: database-name
    # +              name: sonarqube
    # +        image: registry.access.redhat.com/rhscl/postgresql-95-rhel7@sha256:de66da4812f0de42cee0bef65899d75f8b1a7440858271f133c8f73c80be663d
    # +        imagePullPolicy: IfNotPresent
    # +        livenessProbe:
    # +          failureThreshold: 3
    # +          initialDelaySeconds: 30
    # +          periodSeconds: 10
    # +          successThreshold: 1
    # +          tcpSocket:
    # +            port: 5432
    # +          timeoutSeconds: 1
    # +        name: postgresql
    # +        ports:
    # +        - containerPort: 5432
    # +          protocol: TCP
    # +        readinessProbe:
    # +          exec:
    # +            command:
    # +            - /bin/sh
    # +            - -i
    # +            - -c
    # +            - psql -h 127.0.0.1 -U $POSTGRESQL_USER -q -d $POSTGRESQL_DATABASE -c
    # +              'SELECT 1'
    # +          failureThreshold: 3
    # +          initialDelaySeconds: 5
    # +          periodSeconds: 10
    # +          successThreshold: 1
    # +          timeoutSeconds: 1
    # +        resources:
    # +          limits:
    # +            memory: 512Mi
    # +        securityContext:
    # +          capabilities: {}
    # +          privileged: false
    # +        terminationMessagePath: /dev/termination-log
    # +        terminationMessagePolicy: File
    # +        volumeMounts:
    # +        - mountPath: /var/lib/pgsql/data
    # +          name: sonarqube-postgresql-data
    # +      dnsPolicy: ClusterFirst
    # +      restartPolicy: Always
    # +      schedulerName: default-scheduler
    # +      securityContext: {}
    # +      terminationGracePeriodSeconds: 30
    # +      volumes:
    # +      - name: sonarqube-postgresql-data
    # +        persistentVolumeClaim:
    # +          claimName: sonarqube-postgresql
    # +  test: false
    # +  triggers:
    # +  - imageChangeParams:
    # +      automatic: true
    # +      containerNames:
    # +      - postgresql
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: postgresql:9.5
    # +        namespace: openshift
    # +    type: ImageChange
    # +  - type: ConfigChange
    #  
    # + dc/sonarqube to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,97 @@
    # +apiVersion: apps.openshift.io/v1
    # +kind: DeploymentConfig
    # +metadata:
    # +  annotations:
    # +    original-values.tailor.io/spec.template.spec.containers.0.image: cd/sonarqube:latest
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube
    # +spec:
    # +  replicas: 1
    # +  selector:
    # +    app: sonarqube
    # +    deploymentconfig: sonarqube
    # +  strategy:
    # +    activeDeadlineSeconds: 21600
    # +    recreateParams:
    # +      timeoutSeconds: 600
    # +    resources: {}
    # +    type: Recreate
    # +  template:
    # +    metadata:
    # +      annotations: {}
    # +      labels:
    # +        app: sonarqube
    # +        deploymentconfig: sonarqube
    # +    spec:
    # +      containers:
    # +      - env:
    # +        - name: SONARQUBE_JDBC_URL
    # +          valueFrom:
    # +            configMapKeyRef:
    # +              key: database-jdbc-url
    # +              name: sonarqube
    # +        - name: SONARQUBE_JDBC_USERNAME
    # +          valueFrom:
    # +            configMapKeyRef:
    # +              key: database-user
    # +              name: sonarqube
    # +        - name: SONARQUBE_JDBC_PASSWORD
    # +          valueFrom:
    # +            secretKeyRef:
    # +              key: database-password
    # +              name: sonarqube-postgresql
    # +        - name: SONARQUBE_CROWD_URL
    # +          valueFrom:
    # +            configMapKeyRef:
    # +              key: crowd-url
    # +              name: sonarqube
    # +        - name: SONARQUBE_CROWD_APP
    # +          valueFrom:
    # +            configMapKeyRef:
    # +              key: crowd-application
    # +              name: sonarqube
    # +        - name: SONARQUBE_CROWD_PWD
    # +          valueFrom:
    # +            secretKeyRef:
    # +              key: crowd-password
    # +              name: sonarqube-app
    # +        image: cd/sonarqube:latest
    # +        imagePullPolicy: Always
    # +        name: sonarqube
    # +        ports:
    # +        - containerPort: 9000
    # +          protocol: TCP
    # +        resources: {}
    # +        terminationMessagePath: /dev/termination-log
    # +        terminationMessagePolicy: File
    # +        volumeMounts:
    # +        - mountPath: /opt/sonarqube/data
    # +          name: sonarqube-data
    # +        - mountPath: /opt/sonarqube/extensions
    # +          name: sonarqube-extensions
    # +      dnsPolicy: ClusterFirst
    # +      restartPolicy: Always
    # +      schedulerName: default-scheduler
    # +      securityContext: {}
    # +      terminationGracePeriodSeconds: 30
    # +      volumes:
    # +      - name: sonarqube-data
    # +        persistentVolumeClaim:
    # +          claimName: sonarqube-data
    # +      - name: sonarqube-extensions
    # +        persistentVolumeClaim:
    # +          claimName: sonarqube-extensions
    # +  test: false
    # +  triggers:
    # +  - type: ConfigChange
    # +  - imageChangeParams:
    # +      automatic: true
    # +      containerNames:
    # +      - sonarqube
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: sonarqube:latest
    # +        namespace: cd
    # +    type: ImageChange
    #  
    # + svc/sonarqube-postgresql to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,21 @@
    # +apiVersion: v1
    # +kind: Service
    # +metadata:
    # +  annotations:
    # +    managed-annotations.tailor.opendevstack.org: template.openshift.io/expose-uri
    # +    template.openshift.io/expose-uri: postgres://{.spec.clusterIP}:{.spec.ports[?(.name=="postgresql")].port}
    # +  labels:
    # +    app: sonarqube
    # +    template: postgresql-persistent-template
    # +  name: sonarqube-postgresql
    # +spec:
    # +  ports:
    # +  - name: postgresql
    # +    port: 5432
    # +    protocol: TCP
    # +    targetPort: 5432
    # +  selector:
    # +    name: sonarqube-postgresql
    # +  sessionAffinity: None
    # +  type: ClusterIP
    #  
    # + svc/sonarqube to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,18 @@
    # +apiVersion: v1
    # +kind: Service
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube
    # +spec:
    # +  ports:
    # +  - name: 9000-tcp
    # +    port: 9000
    # +    protocol: TCP
    # +    targetPort: 9000
    # +  selector:
    # +    deploymentconfig: sonarqube
    # +  sessionAffinity: None
    # +  type: ClusterIP
    #  
    # + route/sonarqube to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,20 @@
    # +apiVersion: route.openshift.io/v1
    # +kind: Route
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: sonarqube
    # +  name: sonarqube
    # +spec:
    # +  host: sonarqube-cd.192.168.99.100.nip.io
    # +  port:
    # +    targetPort: 9000-tcp
    # +  tls:
    # +    insecureEdgeTerminationPolicy: Redirect
    # +    termination: edge
    # +  to:
    # +    kind: Service
    # +    name: sonarqube
    # +    weight: 100
    # +  wildcardPolicy: None
    #  
    # 
    # Summary: 0 in sync, 13 to create, 0 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Creating ConfigMap sonarqube
    # Applied processed ConfigMap template.
    # Creating Secret sonarqube-app
    # Applied processed Secret template.
    # Creating Secret sonarqube-postgresql
    # Applied processed Secret template.
    # Creating PersistentVolumeClaim sonarqube-postgresql
    # Applied processed PersistentVolumeClaim template.
    # Creating PersistentVolumeClaim sonarqube-data
    # Applied processed PersistentVolumeClaim template.
    # Creating PersistentVolumeClaim sonarqube-extensions
    # Applied processed PersistentVolumeClaim template.
    # Creating ImageStream sonarqube
    # Applied processed ImageStream template.
    # Creating BuildConfig sonarqube
    # Applied processed BuildConfig template.
    # Creating DeploymentConfig sonarqube-postgresql
    # Applied processed DeploymentConfig template.
    # Creating DeploymentConfig sonarqube
    # Applied processed DeploymentConfig template.
    # Creating Service sonarqube-postgresql
    # Applied processed Service template.
    # Creating Service sonarqube
    # Applied processed Service template.
    # Creating Route sonarqube
    # Applied processed Route template.

After the installation has taken place, you will have to build sonarqube:

    oc start-build -n cd sonarqube

    build.build.openshift.io/sonarqube-1 started

Go to 

<http://sonarqube-cd.192.168.99.100.nip.io/> 

and log in with your **crowd** (vzell/opendevstack) user. Click on your **profile** on
the top right, **my account** -> **security** - and create a new token (and save it in
your notes). This token will be used throughout the codebase to trigger the code
quality scan.

    sonarqubetoken

Generate

    82c6ce22df79662b25ab604083e0fc9cadbee8c5

New token "sonarqubetoken" has been created. Make sure you copy it now, you
won't be able to see it again!

Now edit the Resources->Secrets->sonarqube-app->auth-token and replace the
sonarqube-auth-token with the just generated token in base64 coding.

    echo -n "82c6ce22df79662b25ab604083e0fc9cadbee8c5" | base64

    # ODJjNmNlMjJkZjc5NjYyYjI1YWI2MDQwODNlMGZjOWNhZGJlZThjNQ==


<a id="org846e683"></a>

## TODO Explain all variables

Check out the ****cd**** project


<a id="orgc3eec99"></a>

## Prepare CD project for Jenkins

We will now build base images for jenkins and jenkins slave:

Customize the configuration in the `ods-configuration` project at `ods-core > jenkins > ocp-config > bc.env`
and run **tailor update** inside **ods-core/jenkins/ocp-config**:

    cd /misc/vagrant/opendevstack/ods-core/jenkins/ocp-config

Edit "D:\misc\vagrant\opendevstack\ods-core\jenkins\ocp-config\bc.yml" and change **production** -> **master**

Execute **tailor update**

    oc-tailor update
    y

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-core\jenkins\ocp-config with OCP namespace cd.
    # Limiting resources to bc,is with selector app=jenkins.
    # Found 0 resources in OCP cluster (current state) and 4 resources in processed templates (desired state).
    # 
    # + is/jenkins-master to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins
    # +  name: jenkins-master
    # +spec:
    # +  dockerImageRepository: jenkins-master
    # +  lookupPolicy:
    # +    local: false
    #  
    # + is/jenkins-slave-base to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins
    # +  name: jenkins-slave-base
    # +spec:
    # +  dockerImageRepository: jenkins-slave-base
    # +  lookupPolicy:
    # +    local: false
    #  
    # + bc/jenkins-master to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,35 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins
    # +  name: jenkins-master
    # +spec:
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: jenkins-master:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: jenkins/master
    # +    git:
    # +      ref: master
    # +      uri: http://cd_user@192.168.56.31:7990/scm/opendevstack/ods-core.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy:
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: jenkins:2
    # +        namespace: openshift
    # +    type: Docker
    # +  triggers:
    # +  - imageChange: {}
    # +    type: ImageChange
    #  
    # + bc/jenkins-slave-base to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,33 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins
    # +  name: jenkins-slave-base
    # +spec:
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: jenkins-slave-base:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: jenkins/slave-base
    # +    git:
    # +      ref: master
    # +      uri: http://cd_user@192.168.56.31:7990/scm/opendevstack/ods-core.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy:
    # +      dockerfilePath: Dockerfile.centos7
    # +      env:
    # +      - name: APP_DNS
    # +        value: 192.168.99.100.nip.io
    # +    type: Docker
    # +  triggers: []
    #  
    # 
    # Summary: 0 in sync, 4 to create, 0 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Creating ImageStream jenkins-master
    # Applied processed ImageStream template.
    # Creating ImageStream jenkins-slave-base
    # Applied processed ImageStream template.
    # Creating BuildConfig jenkins-master
    # Applied processed BuildConfig template.
    # Creating BuildConfig jenkins-slave-base
    # Applied processed BuildConfig template.

Start jenkins slave base build: 

    oc start-build -n cd jenkins-slave-base

    build.build.openshift.io/jenkins-slave-base-1 started

Check that builds for jenkins-master and jenkins-slave-base are running and successful.

You can **optionally** start the jenkins-master build using

    oc start-build -n cd jenkins-master


<a id="org3dcf614"></a>

## TODO Prepare Jenkins slave docker images

To support different kinds of projects, we need different kinds of Jenkins slave
images. These slave images are located in the project
**jenkins-slave-dockerimages** on github

<https://github.com/opendevstack/>????


<a id="org0d8fc54"></a>

### Maven

So as a first step clone this repository (actually done). Make the required
customizations in the **ods-configuration** under **jenkins-slaves-dockerimages > maven > ocp-config > bc.env**

and run **tailor update** inside **ods-project-quickstarters\jenkins-slaves\maven\ocp-config**:

    cd /misc/vagrant/opendevstack/ods-project-quickstarters/jenkins-slaves/maven/ocp-config

    oc-tailor update
    y

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-project-quickstarters\jenkins-slaves\maven\ocp-config with OCP namespace cd.
    # Limiting resources to bc,is with selector app=jenkins-slave-maven.
    # Found 0 resources in OCP cluster (current state) and 2 resources in processed templates (desired state).
    # 
    # + is/jenkins-slave-maven to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-maven
    # +  name: jenkins-slave-maven
    # +spec:
    # +  dockerImageRepository: jenkins-slave-maven
    # +  lookupPolicy:
    # +    local: false
    #  
    # + bc/jenkins-slave-maven to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,33 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-maven
    # +  name: jenkins-slave-maven
    # +spec:
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: jenkins-slave-maven:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: jenkins-slaves/maven
    # +    git:
    # +      ref: master
    # +      uri: http://cd_user@192.168.56.31:7990/scm/opendevstack/ods-project-quickstarters.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy:
    # +      dockerfilePath: Dockerfile.rhel7
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: jenkins-slave-base:latest
    # +    type: Docker
    # +  triggers: []
    #  
    # 
    # Summary: 0 in sync, 2 to create, 0 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Creating ImageStream jenkins-slave-maven
    # Applied processed ImageStream template.
    # Creating BuildConfig jenkins-slave-maven
    # Applied processed BuildConfig template.

and start the build

    oc start-build -n cd jenkins-slave-maven

    # build.build.openshift.io/jenkins-slave-maven-1 started

Repeat for every project type you require.


<a id="org4e375bc"></a>

### Python

    cd /misc/vagrant/opendevstack/ods-project-quickstarters/jenkins-slaves/python/ocp-config

    oc-tailor update
    y

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-project-quickstarters\jenkins-slaves\python\ocp-config with OCP namespace cd.
    # Limiting resources to bc,is with selector app=jenkins-slave-python.
    # Found 0 resources in OCP cluster (current state) and 2 resources in processed templates (desired state).
    # 
    # + is/jenkins-slave-python to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-python
    # +  name: jenkins-slave-python
    # +spec:
    # +  dockerImageRepository: jenkins-slave-python
    # +  lookupPolicy:
    # +    local: false
    #  
    # + bc/jenkins-slave-python to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,33 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-python
    # +  name: jenkins-slave-python
    # +spec:
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: jenkins-slave-python:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: jenkins-slaves/python
    # +    git:
    # +      ref: master
    # +      uri: http://cd_user@192.168.56.31:7990/scm/opendevstack/ods-project-quickstarters.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy:
    # +      dockerfilePath: Dockerfile.rhel7
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: jenkins-slave-base:latest
    # +    type: Docker
    # +  triggers: []
    #  
    # 
    # Summary: 0 in sync, 2 to create, 0 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Creating ImageStream jenkins-slave-python
    # Applied processed ImageStream template.
    # Creating BuildConfig jenkins-slave-python
    # Applied processed BuildConfig template.

    oc start-build -n cd jenkins-slave-python

    # build.build.openshift.io/jenkins-slave-python-1 started

    /bin/sh: python3: command not found
    Removing intermediate container 425278ea4e6b
    error: build error: The command '/bin/sh -c rm -rf Python-${Python_VERSION}     && yum remove -y $INSTALL_PKGS     && ln -s /Python-${PYTHON_VERSION}/python /usr/local/sbin/python3     && python3 -V' returned a non-zero code: 127


<a id="org84c505a"></a>

### scala

    cd /misc/vagrant/opendevstack/ods-project-quickstarters/jenkins-slaves/scala/ocp-config

    oc-tailor update
    y

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-project-quickstarters\jenkins-slaves\scala\ocp-config with OCP namespace cd.
    # Limiting resources to bc,is with selector app=jenkins-slave-scala.
    # Found 0 resources in OCP cluster (current state) and 2 resources in processed templates (desired state).
    # 
    # + is/jenkins-slave-scala to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-scala
    # +  name: jenkins-slave-scala
    # +spec:
    # +  dockerImageRepository: jenkins-slave-scala
    # +  lookupPolicy:
    # +    local: false
    #  
    # + bc/jenkins-slave-scala to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,40 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-scala
    # +  name: jenkins-slave-scala
    # +spec:
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: jenkins-slave-scala:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: jenkins-slaves/scala
    # +    git:
    # +      ref: master
    # +      uri: http://cd_user@192.168.56.31:7990/scm/opendevstack/ods-project-quickstarters.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy:
    # +      dockerfilePath: Dockerfile.rhel7
    # +      env:
    # +      - name: NEXUS_HOST
    # +        value: https://nexus-cd.192.168.99.100.nip.io
    # +      - name: NEXUS_USERNAME
    # +        value: developer
    # +      - name: NEXUS_PASSWORD
    # +        value: developer
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: jenkins-slave-base:latest
    # +    type: Docker
    # +  triggers: []
    #  
    # 
    # Summary: 0 in sync, 2 to create, 0 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Creating ImageStream jenkins-slave-scala
    # Applied processed ImageStream template.
    # Creating BuildConfig jenkins-slave-scala
    # Applied processed BuildConfig template.

    oc start-build -n cd jenkins-slave-scala

    # build.build.openshift.io/jenkins-slave-scala-1 started

    Getting org.scala-sbt sbt 1.1.6  (this may take some time)...
    
    :: problems summary ::
    :::: WARNINGS
    		module not found: org.scala-sbt#sbt;1.1.6
    	==== local: tried
    	  /home/jenkins/.ivy2/local/org.scala-sbt/sbt/1.1.6/ivys/ivy.xml
    	  -- artifact org.scala-sbt#sbt;1.1.6!sbt.jar:
    	  /home/jenkins/.ivy2/local/org.scala-sbt/sbt/1.1.6/jars/sbt.jar
    	==== my-ivy-proxy-releases: tried
    	  https://nexus-cd.192.168.99.100.nip.io/repository/ivy-releases/org.scala-sbt/sbt/1.1.6/ivys/ivy.xml 
    	==== my-maven-proxy-releases: tried
    	  https://nexus-cd.192.168.99.100.nip.io/repository/maven-public/org/scala-sbt/sbt/1.1.6/sbt-1.1.6.pom 
    	  -- artifact org.scala-sbt#sbt;1.1.6!sbt.jar:
    	  https://nexus-cd.192.168.99.100.nip.io/repository/maven-public/org/scala-sbt/sbt/1.1.6/sbt-1.1.6.jar 
    		::::::::::::::::::::::::::::::::::::::::::::::
    		::          UNRESOLVED DEPENDENCIES         ::
    		::::::::::::::::::::::::::::::::::::::::::::::
    		:: org.scala-sbt#sbt;1.1.6: not found
    		::::::::::::::::::::::::::::::::::::::::::::::
    :::: ERRORS
    	Server access Error: java.security.cert.CertificateException: No subject alternative DNS name matching nexus-cd.192.168.99.100.nip.io found. url=https://nexus-cd.192.168.99.100.nip.io/repository/ivy-releases/org.scala-sbt/sbt/1.1.6/ivys/ivy.xml 
    	Server access Error: java.security.cert.CertificateException: No subject alternative DNS name matching nexus-cd.192.168.99.100.nip.io found. url=https://nexus-cd.192.168.99.100.nip.io/repository/maven-public/org/scala-sbt/sbt/1.1.6/sbt-1.1.6.pom 
    	Server access Error: java.security.cert.CertificateException: No subject alternative DNS name matching nexus-cd.192.168.99.100.nip.io found. url=https://nexus-cd.192.168.99.100.nip.io/repository/maven-public/org/scala-sbt/sbt/1.1.6/sbt-1.1.6.jar 
    :: USE VERBOSE OR DEBUG MESSAGE LEVEL FOR MORE DETAILS
    unresolved dependency: org.scala-sbt#sbt;1.1.6: not found
    Error during sbt execution: Error retrieving required libraries
      (see /home/jenkins/.sbt/boot/update.log for complete log)
    Error: Could not retrieve sbt 1.1.6
    Removing intermediate container 9a6c382800fb
    error: build error: The command '/bin/sh -c cat $HOME/.sbt/repositories | sed -e "s|NEXUS_HOST|$NEXUS_HOST|g" > $HOME/.sbt/repositories.tmp &&     mv $HOME/.sbt/repositories.tmp $HOME/.sbt/repositories  &&     NEXUS_SHORT=$(echo $NEXUS_HOST | sed -e "s|https://||g" | sed -e "s|http://||g") &&     sed -i.bak -e "s|NEXUS_HOST|$NEXUS_SHORT|g" $HOME/.sbt/credentials &&     sed -i.bak -e "s|NEXUS_USERNAME|$NEXUS_USERNAME|g" $HOME/.sbt/credentials &&     sed -i.bak -e "s|NEXUS_PASSWORD|$NEXUS_PASSWORD|g" $HOME/.sbt/credentials &&     rm $HOME/.sbt/credentials.bak &&     cd /tmp/scala &&     . /tmp/set_java_proxy.sh &&     export SBT_OPTS=$JAVA_OPTS" -Duser.home=/home/jenkins" &&     if [[ $HTTP_PROXY != "" ]]; then echo "HTTPS proxy set - SBT bug - remove nexus repos"; rm $HOME/.sbt/repositories; rm /usr/share/sbt/conf/sbtopts; rm /usr/share/sbt-launcher-packaging/conf/sbtopts; fi &&     sbt -v run && echo "c" &&     rm -rf target' returned a non-zero code: 1


<a id="org447071f"></a>

### nodejs8-angular

    cd /misc/vagrant/opendevstack/ods-project-quickstarters/jenkins-slaves/nodejs8-angular/ocp-config

    oc-tailor update
    y

    # Comparing templates in D:\misc\vagrant\opendevstack\ods-project-quickstarters\jenkins-slaves\nodejs8-angular\ocp-config with OCP namespace cd.
    # Limiting resources to bc,is with selector app=jenkins-slave-nodejs8-angular.
    # Found 0 resources in OCP cluster (current state) and 2 resources in processed templates (desired state).
    # 
    # + is/jenkins-slave-nodejs8-angular to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,12 @@
    # +apiVersion: image.openshift.io/v1
    # +kind: ImageStream
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-nodejs8-angular
    # +  name: jenkins-slave-nodejs8-angular
    # +spec:
    # +  dockerImageRepository: jenkins-slave-nodejs8-angular
    # +  lookupPolicy:
    # +    local: false
    #  
    # + bc/jenkins-slave-nodejs8-angular to create
    # --- Current State (OpenShift cluster)
    # +++ Desired State (Processed template)
    # @@ -1 +1,38 @@
    # +apiVersion: build.openshift.io/v1
    # +kind: BuildConfig
    # +metadata:
    # +  annotations: {}
    # +  labels:
    # +    app: jenkins-slave-nodejs8-angular
    # +  name: jenkins-slave-nodejs8-angular
    # +spec:
    # +  nodeSelector: null
    # +  output:
    # +    to:
    # +      kind: ImageStreamTag
    # +      name: jenkins-slave-nodejs8-angular:latest
    # +  postCommit: {}
    # +  resources: {}
    # +  runPolicy: Serial
    # +  source:
    # +    contextDir: jenkins-slaves/nodejs8-angular
    # +    git:
    # +      ref: master
    # +      uri: http://cd_user@192.168.56.31:7990/scm/opendevstack/ods-project-quickstarters.git
    # +    sourceSecret:
    # +      name: cd-user-token
    # +    type: Git
    # +  strategy:
    # +    dockerStrategy:
    # +      dockerfilePath: Dockerfile.rhel7
    # +      env:
    # +      - name: NEXUS_HOST
    # +        value: https://nexus-cd.192.168.99.100.nip.io
    # +      - name: NEXUS_AUTH
    # +        value: developer:changeme
    # +      from:
    # +        kind: ImageStreamTag
    # +        name: jenkins-slave-base:latest
    # +    type: Docker
    # +  triggers: []
    #  
    # 
    # Summary: 0 in sync, 2 to create, 0 to update, 0 to delete
    # 
    # Apply changes? [y/n]: y
    # Creating ImageStream jenkins-slave-nodejs8-angular
    # Applied processed ImageStream template.
    # Creating BuildConfig jenkins-slave-nodejs8-angular
    # Applied processed BuildConfig template.

    oc start-build -n cd jenkins-slave-nodejs8-angular

    # build.build.openshift.io/jenkins-slave-nodejs8-angular-1 started

    Removing intermediate container 4a332f893feb
    Step 12/17 : COPY npmrc $HOME/.npm-global/etc/npmrc
     ---> 50a8315eb47e
    Removing intermediate container 54bee4daf528
    Step 13/17 : RUN sed -i "s|NEXUS_HOST|$NEXUS_HOST|g" $HOME/.npm-global/etc/npmrc &&     sed -i "s|NEXUS_AUTH|$(echo -n $NEXUS_AUTH | base64)|g" $HOME/.npm-global/etc/npmrc &&     npm config set ca=null &&     npm config set strict-ssl=false &&     npm install -g @angular/cli@1.6.5 --unsafe-perm=true --allow-root &&     npm install -g cypress@2.1.0 --unsafe-perm=true --allow-root > /dev/null &&     npm --version &&     ng version &&     cypress verify
     ---> Running in 1f7bad2900c8
    npm ERR! code E401
    npm ERR! 401 Unauthorized: @angular/cli@1.6.5
    
    npm ERR! A complete log of this run can be found in:
    npm ERR!     /home/jenkins/.npm/_logs/2018-11-20T11_41_03_363Z-debug.log
    Removing intermediate container 1f7bad2900c8
    error: build error: The command '/bin/sh -c sed -i "s|NEXUS_HOST|$NEXUS_HOST|g" $HOME/.npm-global/etc/npmrc &&     sed -i "s|NEXUS_AUTH|$(echo -n $NEXUS_AUTH | base64)|g" $HOME/.npm-global/etc/npmrc &&     npm config set ca=null &&     npm config set strict-ssl=false &&     npm install -g @angular/cli@1.6.5 --unsafe-perm=true --allow-root &&     npm install -g cypress@2.1.0 --unsafe-perm=true --allow-root > /dev/null &&     npm --version &&     ng version &&     cypress verify' returned a non-zero code: 1


<a id="org83bdeca"></a>

## Prepare Docker Registry

The Docker registry preparation is needed for several quickstarters,
e.g. be\_spring\_boot. To do so, make sure you have the **Dcker client** binary
installed on your machine.

    type docker

    # docker is /cygdrive/c/ProgramData/chocolatey/bin/docker

    docker version

    # Client:
    #  Version:           18.06.1-ce
    #  API version:       1.26 (downgraded from 1.38)
    #  Go version:        go1.10.3
    #  Git commit:        67f9a391
    #  Built:             08/22/2018 09:10:07
    #  OS/Arch:           windows/amd64
    #  Experimental:      false
    # 
    # Server:
    #  Engine:
    #   Version:          1.13.1
    #   API version:      1.26 (minimum version 1.12)
    #   Go version:       go1.9.4
    #   Git commit:       8633870/1.13.1
    #   Built:            Fri Sep 28 19:45:08 2018
    #   OS/Arch:          linux/amd64
    #   Experimental:     false

    type oc

    # oc is hashed (/cygdrive/c/ProgramData/chocolatey/bin/oc)

    oc version

    # oc v3.11.0+0cbc58b
    # kubernetes v1.11.0+d4cacc0
    # features: Basic-Auth SSPI Kerberos SPNEGO
    # 
    # Server https://192.168.99.100:8443
    # openshift v3.10.0+e5b9b2e-81
    # kubernetes v1.10.0+b81c8f8

    minishift addons apply registry-route

    # -- Applying addon 'registry-route':.....
    # Add-on 'registry-route' created docker-registry route. Please run following commands to login to the OpenShift docker registry:
    # $ eval $(minishift docker-env)
    # $ eval $(minishift oc-env)
    # 
    # $ docker login -u developer -p `oc whoami -t` docker-registry-default.192.168.99.100.nip.io

Run **minishift docker-env** to display the commend you need to execute in order
to configure your **Docker client**.

    minishift docker-env

    # export DOCKER_TLS_VERIFY="1"
    # export DOCKER_HOST="tcp://192.168.99.100:2376"
    # export DOCKER_CERT_PATH="D:\misc\openshift\.minishift\profiles\opendevstack\certs"
    # # Run this command to configure your shell:
    # # eval $(minishift docker-env)

Execute the displayed command, e.g. on **Windows** `CMD @FOR /f "tokens=*" %i IN ('minishift docker-env') DO @call %i`
and on Cygwin `eval $(minishift docker-env)`

    eval $(minishift docker-env)

    env | grep DOCKER

    # DOCKER_CERT_PATH=D:\misc\openshift\.minishift\profiles\opendevstack\certs
    # DOCKER_TLS_VERIFY=1
    # DOCKER_HOST=tcp://192.168.99.100:2376

    minishift oc-env

    # export PATH="D:\misc\openshift\.minishift\cache\oc\v3.10.0\windows:$PATH"
    # # Run this command to configure your shell:
    # # eval $(minishift oc-env)

You do not need to call **eval $(minishift oc-env)** on **cygwin** if **oc** is
already installed on your system

    oc whoami -t

    # error: no token is currently in use for this session

    oc login -u developer -n default
    developer

    # Authentication required for https://192.168.99.100:8443 (openshift)
    # Username: developer
    # Password: Login successful.
    # 
    # You have access to the following projects and can switch between them with 'oc project <projectname>':
    # 
    #     cd
    #   * default
    #     kube-dns
    #     kube-proxy
    #     kube-public
    #     kube-system
    #     myproject
    #     openshift
    #     openshift-apiserver
    #     openshift-controller-manager
    #     openshift-core-operators
    #     openshift-infra
    #     openshift-node
    #     openshift-web-console
    # 
    # Using project "default".

**oc whoami -t** should show the token for your user

    oc whoami -t

    # vON7X1Iv_ot0vJaons8UuAhbi7L8mmkVzmwpZgiUeJY

    export DOCKER_CONFIG="D:\misc\docker\.docker"

    docker login -u developer -p `oc whoami -t` docker-registry-default.192.168.99.100.nip.io:443

    # WARNING! Using --password via the CLI is insecure. Use --password-stdin.
    # WARNING! Your password will be stored unencrypted in D:\misc\docker\.docker\config.json.
    # Configure a credential helper to remove this warning. See
    # https://docs.docker.com/engine/reference/commandline/login/#credentials-store
    # 
    # Login Succeeded

    docker pull busybox

    # Using default tag: latest
    # Trying to pull repository docker.io/library/busybox ... 
    # latest: Pulling from docker.io/library/busybox
    # 90e01955edcd: Pulling fs layer
    # 90e01955edcd: Verifying Checksum
    # 90e01955edcd: Download complete
    # 90e01955edcd: Pull complete
    # Digest: sha256:2a03a6059f21e150ae84b0973863609494aad70f0a80eaeb64bddd8d92465812
    # Status: Downloaded newer image for docker.io/busybox:latest

    docker tag busybox docker-registry-default.192.168.99.100.nip.io:443/openshift/busybox

    docker push docker-registry-default.192.168.99.100.nip.io:443/openshift/busybox

    # The push refers to a repository [docker-registry-default.192.168.99.100.nip.io:443/openshift/busybox]
    # Get https://docker-registry-default.192.168.99.100.nip.io:443/v1/_ping: x509: certificate signed by unknown authority


<a id="org0a3d366"></a>

## Prepare Rundeck and required Dockerfiles

After configuring the **Atlassian tools** and **Minishift**, **Rundeck** has to be
configured as well. Access Rundeck, login (vzell/opendevstack) and open the
configuration.

<http://192.168.56.31:4440/rundeck>


<a id="orgf858893"></a>

### Create Quickstarters project

Create a project named **Quickstarters**. The project doesn’t need any additional
information, so leave all other options blank.


<a id="orge5dce0b"></a>

### Openshift API token

You have to store the API token for the service account in Rundeck, so Rundeck is able to communicate with Openshift.

In the **Key Storage** section click on **Add or Upload a Key**, choose the Key Type Password.
Copy the token text you saved earlier to the textfield.
Leave Storage path blank.
The key has to have the name **openshift-api-token**
Save the key.


<a id="org80c8bd9"></a>

### CD user private key

For initial code commit the CD user’s private key has to be stored in Rundeck, to enable an SSH communication between Rundeck and Bitbucket.

In the **Key Storage** section click on **Add or Upload a Key**, choose the Key Type Private key.
Enter / Upload the private key generated for the CD user.
Leave Storage path blank.
The key has to have the name **id\_rsa\_bitbucket**
Save the key.
Configure


<a id="org5cc0557"></a>

### Configure SCM plugins

Within the ods-project-quickstarters create a new branch called
**rundeck-changes** - and let it inherit from production

Open the configuration and go to the SCM section. This section is available as
soon as you are in the project configuration for the **Quickstarters** project.


<a id="org6090960"></a>

#### Setup Import plugin

Change the File Path Template to \({job.group}\){job.name}.\({config.format}
Change the format for the Job Source Files to yaml
Enter the SSH Git URL for the ods-project-quickstarters repository. You have to enter valid authorization credentials, stored in Rundeck’s key storage. This will be the ` id_rsa_bitbucket` key specified in the previous step.
Branch: Choose “rundeck-changes”
In the next step ensure that the regular expression points to yaml files. Change the regexp to rundeck-jobs/.*\.yaml
Change the file path template to rundeck-jobs\){job.group}\({job.name}-\){job.id}.${config.format}
Import the job definitions under job actions.


<a id="orgd164e8c"></a>

#### Setup Export plugin

If you use the Github repository, and use as is this step isn’t necessary! If
you use your own repository, configure the export plugin in same way as the
import plugin, except the file path template - set to
rundeck-jobs/\({job.group}\){job.name}.${config.format}


<a id="orgdd44709"></a>

### Update the job properties

Go to the project page and then configure. Edit the configuration file (using the button) and add the following lines - based on your environment

    # bitbucket https host including url schema
    project.globals.bitbucket_host=https\://192.168.56.31
    # bitbucket ssh host including url schema
    project.globals.bitbucket_sshhost=ssh://git@192.168.56.31:7999
    # openshift host including url scheme
    project.globals.openshift_apihost=https://192.168.99.100:8443
    # openshift host without url scheme - used to grab CA etc
    project.globals.openshift_apihost_lookup=192.168.99.100:8443
    # openshift nexus host including url scheme
    project.globals.nexus_host=http://nexus-cd.192.168.99.100.nip.io/
    # public route of docker registry including url scheme
    project.globals.openshift_dockerregistry=https://docker-registry-default.192.168.99.100.nip.io:443
    # os user and group rundeck is running with
    project.globals.rundeck_os_user=root:root


<a id="org8a468c4"></a>

## Add shared images

OpenDevStack provides shared images used accross the stack - like the authproxy based on NGINX and lua for crowd

In order to install, create a new project called **shared-services**

Make the required customizations in the **ods-configuration** under **ods-core > shared-images > nginx-authproxy-crowd > ocp-config > bc.env and secret.env**

and run **tailor update** inside **ods-core\shared-images\nginx-authproxy-crowd**:

    cd /.../ods-core\shared-images\nginx-authproxy-crowd

    oc-tailor update

and start the build

    oc start-build -n shared-services nginx-authproxy


<a id="orgdd31347"></a>

## Configure provisioning application

Clone the provisioning application repository.

Because we disabled anonymous access for nexus, we need to provide some data.

What you need to provide are gradle guild variables. You do this by creating a **gradle.properties** file in the ods-provisioning-app project:

    nexus_url=http://nexus-cd.192.168.99.100.nip.io
    nexus_user=developer
    nexus_pw=developer

If you run the application from your IDE, there is no further configuration needed.

After startup via the IDE the application is available at 

<http://localhost:8088/>

You can login in with the Crowd admin user you set up earlier.


<a id="org777104a"></a>

## Setup within Openshift

Create 3 openshift projects projects

-   **prov-cd** (for the jenkins builder)
-   **prov-test** (production branch will be built and deployed here)
-   **prov-dev** (feature branches will be built and deployed here)

Start with prov-cd and issue

    oc-tailor update

Add **prov-cd/jenkins** and **prov-cd/default** service accounts with edit rights
into -dev & -test projects, so jenkins can update the build config and trigger
the corresponding **oc start build / oc update bc** from within the jenkins build.

For the runtime projects (prov-test and prov-dev) run

    oc-tailor update

Once jenkins deployed - you can trigger the build in prov-cd/test - it should automatically deploy - and you can start using the provision app.

Depending on the performance of jira / confluence & Bitbucket - you may get a 504 timeout in the provision app. To fix this - and increase this timeout - run

    oc annotate route prov-app --overwrite haproxy.router.openshift.io/timeout=5m

in **prov-dev** and **prov-test** projects


<a id="orgb66d458"></a>

## Try out the OpenDevStack

After you have set up your local environment it’s time to test the OpenDevStack
and see it working. Open the Provisioning application in your web browser and
login with your crowd credentials.

Provision your first project and have a look at OpenShift.


<a id="org9b5f23c"></a>

# Console URLs

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Product</th>
<th scope="col" class="org-left">Console-URL</th>
<th scope="col" class="org-left">Users</th>
<th scope="col" class="org-left">Password</th>
<th scope="col" class="org-left">URL</th>
<th scope="col" class="org-right">Version</th>
<th scope="col" class="org-right">Built-in Tomcat</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Crowd</td>
<td class="org-left"><http://192.168.56.31:8095></td>
<td class="org-left">vzell</td>
<td class="org-left">opendevstack</td>
<td class="org-left"><https://www.atlassian.com/software/crowd></td>
<td class="org-right">2.11.2</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">Confluence</td>
<td class="org-left"><http://192.168.56.31:8090></td>
<td class="org-left">vzell</td>
<td class="org-left">opendevstack</td>
<td class="org-left"><https://www.atlassian.com/software/confluence></td>
<td class="org-right">6.1.3</td>
<td class="org-right">8.0.41 (hsqldb)</td>
</tr>


<tr>
<td class="org-left">Jira</td>
<td class="org-left"><http://192.168.56.31:8080></td>
<td class="org-left">vzell</td>
<td class="org-left">opendevstack</td>
<td class="org-left"><https://www.atlassian.com/software/jira></td>
<td class="org-right">7.3.6</td>
<td class="org-right">8.5.6</td>
</tr>


<tr>
<td class="org-left">BitBucket</td>
<td class="org-left"><http://192.168.56.31:7990></td>
<td class="org-left">vzell</td>
<td class="org-left">opendevstack</td>
<td class="org-left"><https://www.atlassian.com/software/bitbucket></td>
<td class="org-right">4.14.3</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">Rundeck</td>
<td class="org-left"><http://192.168.56.31:4440></td>
<td class="org-left">vzell</td>
<td class="org-left">opendevstack</td>
<td class="org-left"><https://www.rundeck.com/></td>
<td class="org-right">2.8.2-1</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">Minishift</td>
<td class="org-left"><https://192.168.99.100:8443></td>
<td class="org-left">system</td>
<td class="org-left">admin</td>
<td class="org-left"><https://www.okd.io/minishift/></td>
<td class="org-right">v1.26.1+1e20f27</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">developer</td>
<td class="org-left">developer</td>
<td class="org-left">&#xa0;</td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">OpenShift Master</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-right">v3.10.0+e5b9b2e-81</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">Kubernetes Master</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-right">v1.10.0+b81c8f8</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">OpenShift Web Console</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
<td class="org-right">v3.10.0+1c6c470-dirty</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">Nexus</td>
<td class="org-left"><https://nexus-cd.192.168.99.100.nip.io/></td>
<td class="org-left">admin</td>
<td class="org-left">admin123</td>
<td class="org-left"><https://www.sonatype.com/nexus-repository-sonatype></td>
<td class="org-right">3.14.0-04</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">SonarQube</td>
<td class="org-left"><https://sonarqube-cd.192.168.99.100.nip.io></td>
<td class="org-left">vzell</td>
<td class="org-left">opendevstack</td>
<td class="org-left"><https://www.sonarqube.org/></td>
<td class="org-right">&#xa0;</td>
<td class="org-right">&#xa0;</td>
</tr>
</tbody>
</table>


<a id="org6e6b642"></a>

# OpenDevStack - Products and Description


<a id="orgf64edb4"></a>

## Crowd


<a id="org550df25"></a>

### Centralized identity management

Manage users from multiple directories - Active Directory, LDAP, OpenLDAP or
Microsoft Azure AD - and control application authentication permissions in one
single location.


<a id="org7191086"></a>

#### Single sign-on (SSO)

Make life easy for your users by giving them one username and password to log in
to all the applications they need access to. Seamlessly integrate all your
Atlassian products - like Jira, Confluence, and Bitbucket- to give your users
one simple single sign-on (SSO) experience.


<a id="org6c276b8"></a>

#### Centralize multiple directories

Map any combination of directories to a single application – perfect for
managing users not in your main directory - and manage authentication
permissions in the same place. Get started with connectors for AD, LDAP,
Microsoft Azure AD, Novell eDirectory, and more. You can even create your own
custom connector.


<a id="org9d456df"></a>

## Confluence


<a id="orgac035d4"></a>

### Content collaboration software that changes how modern teams work


<a id="orgd3365d0"></a>

#### Project collaboration

Work together on a whole new level.

Create, share, and collaborate on projects all in one place to keep your
projects moving forward, faster.


<a id="org514a9cc"></a>

#### Knowledge base

It's all here when you need it.

Easily publish, organize, and access company information in one central location
so you can help your customers help themselves.


<a id="org4e3c1b3"></a>

#### Team documentation

Do teams the right way.

Capture, store, and grow your team's knowledge so you can stay up to date and on
the same page - literally.


<a id="org33dcc5c"></a>

#### Document management

Share PDFs, Office docs, images, and more in Confluence. Automatic versioning,
instant previews, full-text search, and pinned comments make it easy to manage
your files.


<a id="orgefdad37"></a>

#### Page and file versioning

Track every version and change that you and your teammates make to a page. Files
are automatically versioned as well!


<a id="orgd857d45"></a>

#### Templates

We include best practice templates to help you get started with popular pages,
so you don't have to fuss with formatting.


<a id="org4b68610"></a>

#### Permissions

Keep your site and your content secure with granular permissions that give you
complete control.


<a id="orgf55d1d8"></a>

#### Jira

Connect to Jira to provide insight into your development work with automatic
linking, quick issue creation and reports in Confluence.


<a id="org7330be9"></a>

## Jira


<a id="org056d0a5"></a>

### Project management tool for agile teams


<a id="orgb4ecfc7"></a>

#### Scrum boards

Agile teams can stay focused on delivering iterative and incremental value, as
fast as possible, with customizable scrum boards.


<a id="org25d9466"></a>

#### Kanban boards

Flexible kanban boards give your team full visibility into what’s next so you
can continuously deliver maximum output in minimal cycle time.


<a id="org44dac16"></a>

#### Agile reporting

Teams have access to more than a dozen out-of-the-box reports with real-time,
actionable insights into how their team is performing sprint over sprint.


<a id="org2d213c2"></a>

#### Roadmaps

Sketch out the big picture, communicate plans with stakeholders, and ensure your
roadmap connects to your team's work - all in a few clicks.


<a id="orgd161513"></a>

#### Customizable workflows

Create customizable workflows that map to any style of work.


<a id="org2538304"></a>

#### Developer tool integrations

Integrate with developer tools for end-to-end traceability.


<a id="org787c439"></a>

#### Custom filters

Create customer filters using Jira Query Language (JQL).


<a id="orga66f003"></a>

#### Rich APIs

Automate processes with Jira’s robust set of APIs.


<a id="org8613ab4"></a>

## Jira and Confluence

Confluence and Jira enable project transparency and automatic linking between
Jira issues and software documentation in Confluence. Quick issue creation and
reports let your team work smarter and faster.


<a id="org46140c7"></a>

## BitBucket


<a id="org1ef5e7c"></a>

### More than just Git code management

Bitbucket gives teams one place to plan projects, collaborate on code, test, and
deploy.


<a id="orgc58828f"></a>

#### Free unlimited private repositories

Free for small teams under 5 and priced to scale with Standard ($2/user/mo) or
Premium ($5/user/mo) plans.


<a id="org9eae5f5"></a>

#### Best-in-class Jira & Trello integration

Keep your projects organized by creating Bitbucket branches right from Jira
issues or Trello cards.


<a id="org66166dd"></a>

#### Built-in Continuous Delivery

Build, test and deploy with integrated CI/CD. Benefit from configuration as code
and fast feedback loops.


<a id="org7635266"></a>

#### Code Collaboration

Build quality software with code review

Approve code review more efficiently with pull requests. Create a merge
checklist with designated approvers and hold discussions right in the source
code with inline comments.


<a id="orgd736eb2"></a>

#### Continuous Delivery

Deploy often with built-in continuous delivery

Bitbucket Pipelines with Deployments lets you build, test and deploy with
integrated CI/CD. Benefit from configuration as code and fast feedback loops.


<a id="orgad72c45"></a>

#### Security

Secure your workflow

Know your code is secure in the Cloud with IP whitelisting and required 2-step
verification. Restrict access to certain users, and control their actions with
branch permissions and merge checks for quality code.


<a id="org1af7ce5"></a>

## Rundeck


<a id="orgd2d2d6d"></a>

### Manage automation from legacy to cloud services

Leverage any scripting languages or tools you want to use.


<a id="org713093d"></a>

#### Scale Ops.

Increase productivity. Implement self-service.


<a id="orgaed67ac"></a>

#### Eliminate the wait.

Reduce ticket queues. Improve response times.


<a id="org3d8cd96"></a>

#### Stay in control.

Oversee everything. Delegate anything.


<a id="org6ac8df8"></a>

#### Be audit-ready.

Validate compliance. Log all Ops activity.


<a id="orgb9ee7fa"></a>

#### Create a job

by defining a single step or a workflow that can execute any set of commands,
scripts, or tools on any number of local or remote nodes. Jobs can be triggered
by the scheduler or on-demand via the web interface or API.


<a id="orgd76e1cb"></a>

#### Safely hand off the job to others

to execute or follow the output &#x2013; depending on the permissions you give
them. Collaborate with others and build your organization's library of
repeatable and auditable actions. You can also let users to run ad-hoc commands
(if your security policies allow it).


<a id="org45e8120"></a>

#### Enjoy being the Hero.

You've safely given Dev and QA teams access to self-service operations tasks
(restarts, health checks, deployment, data management, etc). Now you can spend
less of your time fielding repetitive requests and more of your time doing new
and interesting things that will further the business.


<a id="org2103913"></a>

## Nexus Repository


<a id="org1a727ff"></a>

### Flow control for binaries, build artifacts, and release candidates.


<a id="org5305682"></a>

#### The perfect system of record for all your software parts

-   Manage components, build artifacts, and release candidates in one central location.
-   Understand component security, license, and quality issues.
-   Modernize software development with intelligent staging and release functionality.
-   Scale DevOps delivery with high availability and active/active clustering.
-   Sleep comfortably with world-class support and training.


<a id="org0892099"></a>

#### Universal support for all your favorite formats and tools.

-   Store and distribute Maven/Java, npm, NuGet, RubyGems, Docker, P2, OBR, APT and YUM and more.
-   Manage components from dev through delivery: binaries, containers, assemblies, and finished goods.
-   Awesome support for the Java Virtual Machine (JVM) ecosystem, including Gradle, Ant, Maven, and Ivy.
-   Integrated with popular tools like Eclipse, IntelliJ, Hudson, Jenkins, Puppet, Chef, Docker, and more.


<a id="org139f6fd"></a>

## SonarQube


<a id="orgfb56de7"></a>

### Continuous Code Quality


<a id="org9e67863"></a>

#### Continuous Inspection

SonarQube provides the capability to not only show health of an application but
also to highlight issues newly introduced. With a Quality Gate in place, you can
fix the leak and therefore improve code quality systematically.


<a id="org1067e1a"></a>

#### Detect Tricky Issues

Our code analyzers are equipped with powerful path sensitive dataflow engines to
detect tricky issues such as null-pointers dereferences, logic errors, resource
leaks&#x2026;


<a id="org0a4f05a"></a>

#### Centralize Quality

One place to provide a shared vision of code quality for developers, tech leads,
managers and executives in charge of a few to a few thousands projects and also
to act as a toll gate for application promotion or release.


<a id="org43294d8"></a>

#### DevOps Integration

SonarQube integrates with the entire DevOps toolchain including build systems,
CI engines, promotion pipelines&#x2026; using webhooks and its comprehensive RestAPI.


<a id="org4608960"></a>

# Install convenience environment


<a id="org87d266a"></a>

## atlassian1

    cd /misc/vagrant/opendevstack/ods-core/infrastructure-setup

    vagrant ssh atlassian1

    uname -a

    # Linux atlassian1 3.10.0-514.26.2.el7.x86_64 #1 SMP Tue Jul 4 15:04:05 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

    cat /etc/os-release

    # NAME="CentOS Linux"
    # VERSION="7 (Core)"
    # ID="centos"
    # ID_LIKE="rhel fedora"
    # VERSION_ID="7"
    # PRETTY_NAME="CentOS Linux 7 (Core)"
    # ANSI_COLOR="0;31"
    # CPE_NAME="cpe:/o:centos:centos:7"
    # HOME_URL="https://www.centos.org/"
    # BUG_REPORT_URL="https://bugs.centos.org/"
    # 
    # CENTOS_MANTISBT_PROJECT="CentOS-7"
    # CENTOS_MANTISBT_PROJECT_VERSION="7"
    # REDHAT_SUPPORT_PRODUCT="centos"
    # REDHAT_SUPPORT_PRODUCT_VERSION="7"

    type mc xterm xauth

    # -bash: type: mc: not found
    # -bash: type: xterm: not found
    # -bash: type: xauth: not found

    sudo yum -y install mc xterm xauth

    # Loaded plugins: fastestmirror
    # base                                                                               | 3.6 kB  00:00:00     
    # docker-ce-stable                                                                   | 3.5 kB  00:00:00     
    # epel/x86_64/metalink                                                               |  20 kB  00:00:00     
    # epel                                                                               | 3.2 kB  00:00:00     
    # extras                                                                             | 3.4 kB  00:00:00     
    # pgdg94                                                                             | 4.1 kB  00:00:00     
    # rundeck-release-bintray                                                            | 1.3 kB  00:00:00     
    # updates                                                                            | 3.4 kB  00:00:00     
    # (1/3): pgdg94/7/x86_64/primary_db                                                  | 220 kB  00:00:00     
    # (2/3): epel/x86_64/updateinfo                                                      | 932 kB  00:00:02     
    # (3/3): epel/x86_64/primary                                                         | 3.6 MB  00:00:02     
    # Loading mirror speeds from cached hostfile
    #  * base: anorien.csc.warwick.ac.uk
    #  * epel: ftp.nluug.nl
    #  * extras: mirrors.ukfast.co.uk
    #  * updates: mirrors.clouvider.net
    # epel                                                                                          12706/12706
    # Resolving Dependencies
    # --> Running transaction check
    # ---> Package mc.x86_64 1:4.8.7-11.el7 will be installed
    # ---> Package xorg-x11-xauth.x86_64 1:1.0.9-1.el7 will be installed
    # --> Processing Dependency: libXmuu.so.1()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # --> Processing Dependency: libXext.so.6()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # --> Processing Dependency: libXau.so.6()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # --> Processing Dependency: libX11.so.6()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # ---> Package xterm.x86_64 0:295-3.el7 will be installed
    # --> Processing Dependency: libfontconfig.so.1()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXt.so.6()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXpm.so.4()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXft.so.2()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXaw.so.7()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libICE.so.6()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Running transaction check
    # ---> Package fontconfig.x86_64 0:2.10.95-11.el7 will be installed
    # --> Processing Dependency: fontpackages-filesystem for package: fontconfig-2.10.95-11.el7.x86_64
    # --> Processing Dependency: font(:lang=en) for package: fontconfig-2.10.95-11.el7.x86_64
    # ---> Package libICE.x86_64 0:1.0.9-9.el7 will be installed
    # ---> Package libX11.x86_64 0:1.6.5-1.el7 will be installed
    # --> Processing Dependency: libX11-common >= 1.6.5-1.el7 for package: libX11-1.6.5-1.el7.x86_64
    # --> Processing Dependency: libxcb.so.1()(64bit) for package: libX11-1.6.5-1.el7.x86_64
    # ---> Package libXau.x86_64 0:1.0.8-2.1.el7 will be installed
    # ---> Package libXaw.x86_64 0:1.0.13-4.el7 will be installed
    # ---> Package libXext.x86_64 0:1.3.3-3.el7 will be installed
    # ---> Package libXft.x86_64 0:2.3.2-2.el7 will be installed
    # --> Processing Dependency: libXrender.so.1()(64bit) for package: libXft-2.3.2-2.el7.x86_64
    # ---> Package libXmu.x86_64 0:1.1.2-2.el7 will be installed
    # ---> Package libXpm.x86_64 0:3.5.12-1.el7 will be installed
    # ---> Package libXt.x86_64 0:1.1.5-3.el7 will be installed
    # --> Processing Dependency: libSM.so.6()(64bit) for package: libXt-1.1.5-3.el7.x86_64
    # --> Running transaction check
    # ---> Package fontpackages-filesystem.noarch 0:1.44-8.el7 will be installed
    # ---> Package libSM.x86_64 0:1.2.2-2.el7 will be installed
    # ---> Package libX11-common.noarch 0:1.6.5-1.el7 will be installed
    # ---> Package libXrender.x86_64 0:0.9.10-1.el7 will be installed
    # ---> Package libxcb.x86_64 0:1.12-1.el7 will be installed
    # ---> Package lyx-fonts.noarch 0:2.2.3-1.el7 will be installed
    # --> Finished Dependency Resolution
    # 
    # Dependencies Resolved
    # 
    # ==========================================================================================================
    #  Package                             Arch               Version                    Repository        Size
    # ==========================================================================================================
    # Installing:
    #  mc                                  x86_64             1:4.8.7-11.el7             base             1.7 M
    #  xorg-x11-xauth                      x86_64             1:1.0.9-1.el7              base              30 k
    #  xterm                               x86_64             295-3.el7                  base             455 k
    # Installing for dependencies:
    #  fontconfig                          x86_64             2.10.95-11.el7             base             229 k
    #  fontpackages-filesystem             noarch             1.44-8.el7                 base             9.9 k
    #  libICE                              x86_64             1.0.9-9.el7                base              66 k
    #  libSM                               x86_64             1.2.2-2.el7                base              39 k
    #  libX11                              x86_64             1.6.5-1.el7                base             606 k
    #  libX11-common                       noarch             1.6.5-1.el7                base             164 k
    #  libXau                              x86_64             1.0.8-2.1.el7              base              29 k
    #  libXaw                              x86_64             1.0.13-4.el7               base             192 k
    #  libXext                             x86_64             1.3.3-3.el7                base              39 k
    #  libXft                              x86_64             2.3.2-2.el7                base              58 k
    #  libXmu                              x86_64             1.1.2-2.el7                base              71 k
    #  libXpm                              x86_64             3.5.12-1.el7               base              55 k
    #  libXrender                          x86_64             0.9.10-1.el7               base              26 k
    #  libXt                               x86_64             1.1.5-3.el7                base             173 k
    #  libxcb                              x86_64             1.12-1.el7                 base             211 k
    #  lyx-fonts                           noarch             2.2.3-1.el7                epel             159 k
    # 
    # Transaction Summary
    # ==========================================================================================================
    # Install  3 Packages (+16 Dependent packages)
    # 
    # Total download size: 4.3 M
    # Installed size: 13 M
    # Downloading packages:
    # (1/19): libICE-1.0.9-9.el7.x86_64.rpm                                              |  66 kB  00:00:00     
    # (2/19): fontpackages-filesystem-1.44-8.el7.noarch.rpm                              | 9.9 kB  00:00:00     
    # (3/19): libSM-1.2.2-2.el7.x86_64.rpm                                               |  39 kB  00:00:00     
    # (4/19): fontconfig-2.10.95-11.el7.x86_64.rpm                                       | 229 kB  00:00:00     
    # (5/19): libX11-common-1.6.5-1.el7.noarch.rpm                                       | 164 kB  00:00:00     
    # (6/19): libXau-1.0.8-2.1.el7.x86_64.rpm                                            |  29 kB  00:00:00     
    # (7/19): libXext-1.3.3-3.el7.x86_64.rpm                                             |  39 kB  00:00:00     
    # (8/19): libX11-1.6.5-1.el7.x86_64.rpm                                              | 606 kB  00:00:00     
    # (9/19): libXft-2.3.2-2.el7.x86_64.rpm                                              |  58 kB  00:00:00     
    # (10/19): libXpm-3.5.12-1.el7.x86_64.rpm                                            |  55 kB  00:00:00     
    # (11/19): libXrender-0.9.10-1.el7.x86_64.rpm                                        |  26 kB  00:00:00     
    # (12/19): libXt-1.1.5-3.el7.x86_64.rpm                                              | 173 kB  00:00:00     
    # (13/19): libXaw-1.0.13-4.el7.x86_64.rpm                                            | 192 kB  00:00:00     
    # (14/19): libxcb-1.12-1.el7.x86_64.rpm                                              | 211 kB  00:00:00     
    # (15/19): xorg-x11-xauth-1.0.9-1.el7.x86_64.rpm                                     |  30 kB  00:00:00     
    # (16/19): libXmu-1.1.2-2.el7.x86_64.rpm                                             |  71 kB  00:00:00     
    # (17/19): mc-4.8.7-11.el7.x86_64.rpm                                                | 1.7 MB  00:00:00     
    # (18/19): xterm-295-3.el7.x86_64.rpm                                                | 455 kB  00:00:00     
    # (19/19): lyx-fonts-2.2.3-1.el7.noarch.rpm                                          | 159 kB  00:00:01     
    # ----------------------------------------------------------------------------------------------------------
    # Total                                                                     2.2 MB/s | 4.3 MB  00:00:01     
    # Running transaction check
    # Running transaction test
    # Transaction test succeeded
    # Running transaction
    #   Installing : libICE-1.0.9-9.el7.x86_64                                                             1/19 
    #   Installing : fontpackages-filesystem-1.44-8.el7.noarch                                             2/19 
    #   Installing : libXau-1.0.8-2.1.el7.x86_64                                                           3/19 
    #   Installing : libxcb-1.12-1.el7.x86_64                                                              4/19 
    #   Installing : lyx-fonts-2.2.3-1.el7.noarch                                                          5/19 
    #   Installing : fontconfig-2.10.95-11.el7.x86_64                                                      6/19 
    #   Installing : libSM-1.2.2-2.el7.x86_64                                                              7/19 
    #   Installing : libX11-common-1.6.5-1.el7.noarch                                                      8/19 
    #   Installing : libX11-1.6.5-1.el7.x86_64                                                             9/19 
    #   Installing : libXext-1.3.3-3.el7.x86_64                                                           10/19 
    #   Installing : libXt-1.1.5-3.el7.x86_64                                                             11/19 
    #   Installing : libXmu-1.1.2-2.el7.x86_64                                                            12/19 
    #   Installing : libXpm-3.5.12-1.el7.x86_64                                                           13/19 
    #   Installing : libXaw-1.0.13-4.el7.x86_64                                                           14/19 
    #   Installing : libXrender-0.9.10-1.el7.x86_64                                                       15/19 
    #   Installing : libXft-2.3.2-2.el7.x86_64                                                            16/19 
    #   Installing : xterm-295-3.el7.x86_64                                                               17/19 
    #   Installing : 1:xorg-x11-xauth-1.0.9-1.el7.x86_64                                                  18/19 
    #   Installing : 1:mc-4.8.7-11.el7.x86_64                                                             19/19 
    #   Verifying  : 1:mc-4.8.7-11.el7.x86_64                                                              1/19 
    #   Verifying  : libXext-1.3.3-3.el7.x86_64                                                            2/19 
    #   Verifying  : lyx-fonts-2.2.3-1.el7.noarch                                                          3/19 
    #   Verifying  : libxcb-1.12-1.el7.x86_64                                                              4/19 
    #   Verifying  : libICE-1.0.9-9.el7.x86_64                                                             5/19 
    #   Verifying  : libX11-1.6.5-1.el7.x86_64                                                             6/19 
    #   Verifying  : libXau-1.0.8-2.1.el7.x86_64                                                           7/19 
    #   Verifying  : libXrender-0.9.10-1.el7.x86_64                                                        8/19 
    #   Verifying  : libXft-2.3.2-2.el7.x86_64                                                             9/19 
    #   Verifying  : fontconfig-2.10.95-11.el7.x86_64                                                     10/19 
    #   Verifying  : xterm-295-3.el7.x86_64                                                               11/19 
    #   Verifying  : libSM-1.2.2-2.el7.x86_64                                                             12/19 
    #   Verifying  : libXaw-1.0.13-4.el7.x86_64                                                           13/19 
    #   Verifying  : libXmu-1.1.2-2.el7.x86_64                                                            14/19 
    #   Verifying  : libXt-1.1.5-3.el7.x86_64                                                             15/19 
    #   Verifying  : libXpm-3.5.12-1.el7.x86_64                                                           16/19 
    #   Verifying  : libX11-common-1.6.5-1.el7.noarch                                                     17/19 
    #   Verifying  : fontpackages-filesystem-1.44-8.el7.noarch                                            18/19 
    #   Verifying  : 1:xorg-x11-xauth-1.0.9-1.el7.x86_64                                                  19/19 
    # 
    # Installed:
    #   mc.x86_64 1:4.8.7-11.el7       xorg-x11-xauth.x86_64 1:1.0.9-1.el7       xterm.x86_64 0:295-3.el7      
    # 
    # Dependency Installed:
    #   fontconfig.x86_64 0:2.10.95-11.el7              fontpackages-filesystem.noarch 0:1.44-8.el7             
    #   libICE.x86_64 0:1.0.9-9.el7                     libSM.x86_64 0:1.2.2-2.el7                              
    #   libX11.x86_64 0:1.6.5-1.el7                     libX11-common.noarch 0:1.6.5-1.el7                      
    #   libXau.x86_64 0:1.0.8-2.1.el7                   libXaw.x86_64 0:1.0.13-4.el7                            
    #   libXext.x86_64 0:1.3.3-3.el7                    libXft.x86_64 0:2.3.2-2.el7                             
    #   libXmu.x86_64 0:1.1.2-2.el7                     libXpm.x86_64 0:3.5.12-1.el7                            
    #   libXrender.x86_64 0:0.9.10-1.el7                libXt.x86_64 0:1.1.5-3.el7                              
    #   libxcb.x86_64 0:1.12-1.el7                      lyx-fonts.noarch 0:2.2.3-1.el7                          
    # 
    # Complete!

    exit

    ssh -Y -p 2222 vagrant@127.0.0.1
    yes
    vagrant

    xterm &


<a id="org13c4aee"></a>

## atlcon

    cd /misc/vagrant/opendevstack/ods-core/infrastructure-setup

    vagrant ssh atlcon

    uname -a

    # Linux atlcon 3.10.0-514.26.2.el7.x86_64 #1 SMP Tue Jul 4 15:04:05 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

    cat /etc/os-release

    # NAME="CentOS Linux"
    # VERSION="7 (Core)"
    # ID="centos"
    # ID_LIKE="rhel fedora"
    # VERSION_ID="7"
    # PRETTY_NAME="CentOS Linux 7 (Core)"
    # ANSI_COLOR="0;31"
    # CPE_NAME="cpe:/o:centos:centos:7"
    # HOME_URL="https://www.centos.org/"
    # BUG_REPORT_URL="https://bugs.centos.org/"
    # 
    # CENTOS_MANTISBT_PROJECT="CentOS-7"
    # CENTOS_MANTISBT_PROJECT_VERSION="7"
    # REDHAT_SUPPORT_PRODUCT="centos"
    # REDHAT_SUPPORT_PRODUCT_VERSION="7"
    # 

    type mc xterm xauth

    # -bash: type: mc: not found
    # -bash: type: xterm: not found
    # -bash: type: xauth: not found

    sudo yum -y install mc xterm xauth

    # Loaded plugins: fastestmirror
    # base                                                                               | 3.6 kB  00:00:00     
    # epel/x86_64/metalink                                                               |  20 kB  00:00:00     
    # epel                                                                               | 3.2 kB  00:00:00     
    # extras                                                                             | 3.4 kB  00:00:00     
    # pgdg94                                                                             | 4.1 kB  00:00:00     
    # updates                                                                            | 3.4 kB  00:00:00     
    # (1/3): pgdg94/7/x86_64/primary_db                                                  | 220 kB  00:00:00     
    # (2/3): epel/x86_64/updateinfo                                                      | 932 kB  00:00:01     
    # (3/3): epel/x86_64/primary                                                         | 3.6 MB  00:00:03     
    # Loading mirror speeds from cached hostfile
    #  * base: mirrors.clouvider.net
    #  * epel: mirror.serverbeheren.nl
    #  * extras: mirrors.vooservers.com
    #  * updates: mirrors.clouvider.net
    # epel                                                                                          12706/12706
    # Resolving Dependencies
    # --> Running transaction check
    # ---> Package mc.x86_64 1:4.8.7-11.el7 will be installed
    # ---> Package xorg-x11-xauth.x86_64 1:1.0.9-1.el7 will be installed
    # --> Processing Dependency: libXmuu.so.1()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # --> Processing Dependency: libXext.so.6()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # --> Processing Dependency: libXau.so.6()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # --> Processing Dependency: libX11.so.6()(64bit) for package: 1:xorg-x11-xauth-1.0.9-1.el7.x86_64
    # ---> Package xterm.x86_64 0:295-3.el7 will be installed
    # --> Processing Dependency: libfontconfig.so.1()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXt.so.6()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXpm.so.4()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXft.so.2()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libXaw.so.7()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Processing Dependency: libICE.so.6()(64bit) for package: xterm-295-3.el7.x86_64
    # --> Running transaction check
    # ---> Package fontconfig.x86_64 0:2.10.95-11.el7 will be installed
    # --> Processing Dependency: fontpackages-filesystem for package: fontconfig-2.10.95-11.el7.x86_64
    # --> Processing Dependency: font(:lang=en) for package: fontconfig-2.10.95-11.el7.x86_64
    # ---> Package libICE.x86_64 0:1.0.9-9.el7 will be installed
    # ---> Package libX11.x86_64 0:1.6.5-1.el7 will be installed
    # --> Processing Dependency: libX11-common >= 1.6.5-1.el7 for package: libX11-1.6.5-1.el7.x86_64
    # --> Processing Dependency: libxcb.so.1()(64bit) for package: libX11-1.6.5-1.el7.x86_64
    # ---> Package libXau.x86_64 0:1.0.8-2.1.el7 will be installed
    # ---> Package libXaw.x86_64 0:1.0.13-4.el7 will be installed
    # ---> Package libXext.x86_64 0:1.3.3-3.el7 will be installed
    # ---> Package libXft.x86_64 0:2.3.2-2.el7 will be installed
    # --> Processing Dependency: libXrender.so.1()(64bit) for package: libXft-2.3.2-2.el7.x86_64
    # ---> Package libXmu.x86_64 0:1.1.2-2.el7 will be installed
    # ---> Package libXpm.x86_64 0:3.5.12-1.el7 will be installed
    # ---> Package libXt.x86_64 0:1.1.5-3.el7 will be installed
    # --> Processing Dependency: libSM.so.6()(64bit) for package: libXt-1.1.5-3.el7.x86_64
    # --> Running transaction check
    # ---> Package fontpackages-filesystem.noarch 0:1.44-8.el7 will be installed
    # ---> Package libSM.x86_64 0:1.2.2-2.el7 will be installed
    # ---> Package libX11-common.noarch 0:1.6.5-1.el7 will be installed
    # ---> Package libXrender.x86_64 0:0.9.10-1.el7 will be installed
    # ---> Package libxcb.x86_64 0:1.12-1.el7 will be installed
    # ---> Package lyx-fonts.noarch 0:2.2.3-1.el7 will be installed
    # --> Finished Dependency Resolution
    # 
    # Dependencies Resolved
    # 
    # ==========================================================================================================
    #  Package                             Arch               Version                    Repository        Size
    # ==========================================================================================================
    # Installing:
    #  mc                                  x86_64             1:4.8.7-11.el7             base             1.7 M
    #  xorg-x11-xauth                      x86_64             1:1.0.9-1.el7              base              30 k
    #  xterm                               x86_64             295-3.el7                  base             455 k
    # Installing for dependencies:
    #  fontconfig                          x86_64             2.10.95-11.el7             base             229 k
    #  fontpackages-filesystem             noarch             1.44-8.el7                 base             9.9 k
    #  libICE                              x86_64             1.0.9-9.el7                base              66 k
    #  libSM                               x86_64             1.2.2-2.el7                base              39 k
    #  libX11                              x86_64             1.6.5-1.el7                base             606 k
    #  libX11-common                       noarch             1.6.5-1.el7                base             164 k
    #  libXau                              x86_64             1.0.8-2.1.el7              base              29 k
    #  libXaw                              x86_64             1.0.13-4.el7               base             192 k
    #  libXext                             x86_64             1.3.3-3.el7                base              39 k
    #  libXft                              x86_64             2.3.2-2.el7                base              58 k
    #  libXmu                              x86_64             1.1.2-2.el7                base              71 k
    #  libXpm                              x86_64             3.5.12-1.el7               base              55 k
    #  libXrender                          x86_64             0.9.10-1.el7               base              26 k
    #  libXt                               x86_64             1.1.5-3.el7                base             173 k
    #  libxcb                              x86_64             1.12-1.el7                 base             211 k
    #  lyx-fonts                           noarch             2.2.3-1.el7                epel             159 k
    # 
    # Transaction Summary
    # ==========================================================================================================
    # Install  3 Packages (+16 Dependent packages)
    # 
    # Total download size: 4.3 M
    # Installed size: 13 M
    # Downloading packages:
    # (1/19): fontpackages-filesystem-1.44-8.el7.noarch.rpm                              | 9.9 kB  00:00:00     
    # (2/19): libSM-1.2.2-2.el7.x86_64.rpm                                               |  39 kB  00:00:00     
    # (3/19): libICE-1.0.9-9.el7.x86_64.rpm                                              |  66 kB  00:00:00     
    # (4/19): libXau-1.0.8-2.1.el7.x86_64.rpm                                            |  29 kB  00:00:00     
    # (5/19): libX11-common-1.6.5-1.el7.noarch.rpm                                       | 164 kB  00:00:00     
    # (6/19): libXft-2.3.2-2.el7.x86_64.rpm                                              |  58 kB  00:00:00     
    # (7/19): libXext-1.3.3-3.el7.x86_64.rpm                                             |  39 kB  00:00:00     
    # (8/19): fontconfig-2.10.95-11.el7.x86_64.rpm                                       | 229 kB  00:00:00     
    # (9/19): libXmu-1.1.2-2.el7.x86_64.rpm                                              |  71 kB  00:00:00     
    # (10/19): libXaw-1.0.13-4.el7.x86_64.rpm                                            | 192 kB  00:00:00     
    # (11/19): libXpm-3.5.12-1.el7.x86_64.rpm                                            |  55 kB  00:00:00     
    # (12/19): libXt-1.1.5-3.el7.x86_64.rpm                                              | 173 kB  00:00:00     
    # (13/19): libXrender-0.9.10-1.el7.x86_64.rpm                                        |  26 kB  00:00:00     
    # (14/19): libxcb-1.12-1.el7.x86_64.rpm                                              | 211 kB  00:00:00     
    # (15/19): xorg-x11-xauth-1.0.9-1.el7.x86_64.rpm                                     |  30 kB  00:00:00     
    # (16/19): libX11-1.6.5-1.el7.x86_64.rpm                                             | 606 kB  00:00:01     
    # (17/19): xterm-295-3.el7.x86_64.rpm                                                | 455 kB  00:00:00     
    # (18/19): lyx-fonts-2.2.3-1.el7.noarch.rpm                                          | 159 kB  00:00:00     
    # (19/19): mc-4.8.7-11.el7.x86_64.rpm                                                | 1.7 MB  00:00:00     
    # ----------------------------------------------------------------------------------------------------------
    # Total                                                                     1.9 MB/s | 4.3 MB  00:00:02     
    # Running transaction check
    # Running transaction test
    # Transaction test succeeded
    # Running transaction
    #   Installing : libICE-1.0.9-9.el7.x86_64                                                             1/19 
    #   Installing : fontpackages-filesystem-1.44-8.el7.noarch                                             2/19 
    #   Installing : libXau-1.0.8-2.1.el7.x86_64                                                           3/19 
    #   Installing : libxcb-1.12-1.el7.x86_64                                                              4/19 
    #   Installing : lyx-fonts-2.2.3-1.el7.noarch                                                          5/19 
    #   Installing : fontconfig-2.10.95-11.el7.x86_64                                                      6/19 
    #   Installing : libSM-1.2.2-2.el7.x86_64                                                              7/19 
    #   Installing : libX11-common-1.6.5-1.el7.noarch                                                      8/19 
    #   Installing : libX11-1.6.5-1.el7.x86_64                                                             9/19 
    #   Installing : libXext-1.3.3-3.el7.x86_64                                                           10/19 
    #   Installing : libXt-1.1.5-3.el7.x86_64                                                             11/19 
    #   Installing : libXmu-1.1.2-2.el7.x86_64                                                            12/19 
    #   Installing : libXpm-3.5.12-1.el7.x86_64                                                           13/19 
    #   Installing : libXaw-1.0.13-4.el7.x86_64                                                           14/19 
    #   Installing : libXrender-0.9.10-1.el7.x86_64                                                       15/19 
    #   Installing : libXft-2.3.2-2.el7.x86_64                                                            16/19 
    #   Installing : xterm-295-3.el7.x86_64                                                               17/19 
    #   Installing : 1:xorg-x11-xauth-1.0.9-1.el7.x86_64                                                  18/19 
    #   Installing : 1:mc-4.8.7-11.el7.x86_64                                                             19/19 
    #   Verifying  : 1:mc-4.8.7-11.el7.x86_64                                                              1/19 
    #   Verifying  : libXext-1.3.3-3.el7.x86_64                                                            2/19 
    #   Verifying  : lyx-fonts-2.2.3-1.el7.noarch                                                          3/19 
    #   Verifying  : libxcb-1.12-1.el7.x86_64                                                              4/19 
    #   Verifying  : libICE-1.0.9-9.el7.x86_64                                                             5/19 
    #   Verifying  : libX11-1.6.5-1.el7.x86_64                                                             6/19 
    #   Verifying  : libXau-1.0.8-2.1.el7.x86_64                                                           7/19 
    #   Verifying  : libXrender-0.9.10-1.el7.x86_64                                                        8/19 
    #   Verifying  : libXft-2.3.2-2.el7.x86_64                                                             9/19 
    #   Verifying  : fontconfig-2.10.95-11.el7.x86_64                                                     10/19 
    #   Verifying  : xterm-295-3.el7.x86_64                                                               11/19 
    #   Verifying  : libSM-1.2.2-2.el7.x86_64                                                             12/19 
    #   Verifying  : libXaw-1.0.13-4.el7.x86_64                                                           13/19 
    #   Verifying  : libXmu-1.1.2-2.el7.x86_64                                                            14/19 
    #   Verifying  : libXt-1.1.5-3.el7.x86_64                                                             15/19 
    #   Verifying  : libXpm-3.5.12-1.el7.x86_64                                                           16/19 
    #   Verifying  : libX11-common-1.6.5-1.el7.noarch                                                     17/19 
    #   Verifying  : fontpackages-filesystem-1.44-8.el7.noarch                                            18/19 
    #   Verifying  : 1:xorg-x11-xauth-1.0.9-1.el7.x86_64                                                  19/19 
    # 
    # Installed:
    #   mc.x86_64 1:4.8.7-11.el7       xorg-x11-xauth.x86_64 1:1.0.9-1.el7       xterm.x86_64 0:295-3.el7      
    # 
    # Dependency Installed:
    #   fontconfig.x86_64 0:2.10.95-11.el7              fontpackages-filesystem.noarch 0:1.44-8.el7             
    #   libICE.x86_64 0:1.0.9-9.el7                     libSM.x86_64 0:1.2.2-2.el7                              
    #   libX11.x86_64 0:1.6.5-1.el7                     libX11-common.noarch 0:1.6.5-1.el7                      
    #   libXau.x86_64 0:1.0.8-2.1.el7                   libXaw.x86_64 0:1.0.13-4.el7                            
    #   libXext.x86_64 0:1.3.3-3.el7                    libXft.x86_64 0:2.3.2-2.el7                             
    #   libXmu.x86_64 0:1.1.2-2.el7                     libXpm.x86_64 0:3.5.12-1.el7                            
    #   libXrender.x86_64 0:0.9.10-1.el7                libXt.x86_64 0:1.1.5-3.el7                              
    #   libxcb.x86_64 0:1.12-1.el7                      lyx-fonts.noarch 0:2.2.3-1.el7                          
    # 
    # Complete!

    exit

    ssh -Y -p 2200 vagrant@127.0.0.1
    yes
    vagrant

    xterm &


<a id="orgd5ee7ed"></a>

# Installation and Runtime Topology


<a id="orgc292999"></a>

## Atlassian products


<a id="org418a62f"></a>

### Installation directory (/opt/atlassian)

    sudo yum -y install tree

    # #!/usr/bin/env bash
    # #
    # # One way to set the BITBUCKET_HOME path is here via this variable.  Simply uncomment it and set a valid path like
    # # /bitbucket/home.  You can of course set it outside in the command terminal; that will also work.
    # #
    # 
    # if [ "x${BITBUCKET_HOME}" = "x" ]; then
    #     export BITBUCKET_HOME=/srv/atlassian/bitbucket
    # fi
    # 
    # # When upgrading from the packaged distribution BITBUCKET_HOME may not be set. Fallback to legacy STASH_HOME
    # # and output a message for the user recommending that they update their environment
    # if [ "x${BITBUCKET_HOME}" = "x" ]; then
    #     if [ ! "x${STASH_HOME}" = "x" ]; then
    #         BITBUCKET_HOME=${STASH_HOME}
    #         echo ""
    #         echo "--------------------------------------------------------------------------------------"
    #         echo "  WARNING: STASH_HOME has been deprecated and replaced with BITBUCKET_HOME."
    #         echo "  We recommend you set BITBUCKET_HOME instead of STASH_HOME."
    #         echo "  Future versions of Bitbucket may not support the STASH_HOME variable."
    #         echo "--------------------------------------------------------------------------------------"
    #     fi
    # fi
    # 
    # echo $BITBUCKET_HOME | grep -q " "
    # if [ $? -eq 0 ]; then
    #     echo ""
    #     echo "-------------------------------------------------------------------------------"
    #     echo "  BITBUCKET_HOME \"$BITBUCKET_HOME\" contains spaces."
    #     echo "  Using a directory with spaces is likely to cause unexpected behaviour and is"
    #     echo "  not supported. Please use a directory which does not contain spaces."
    #     echo "-------------------------------------------------------------------------------"
    #     exit 1
    # fi
    # 
    # if [ -z "$BITBUCKET_HOME" ]; then
    #     echo ""
    #     echo "--------------------------------------------------------------------------------------"
    #     echo "  Bitbucket doesn't know where to store its data. Please configure the BITBUCKET_HOME"
    #     echo "  environment variable with the directory where Bitbucket should store its data."
    #     echo "  Ensure that the path to BITBUCKET_HOME does not contain spaces. BITBUCKET_HOME may"
    #     echo "  be configured in set-bitbucket-home.sh, if preferred, rather than exporting it as an"
    #     echo "  environment variable."
    #     echo "--------------------------------------------------------------------------------------"
    #     exit 1
    # fi
    # 
    # echo "BITBUCKET_HOME set to $BITBUCKET_HOME"[vagrant@atlassian1 atlassian]$ 
    # [vagrant@atlassian1 atlassian]$ 
    # [vagrant@atlassian1 atlassian]$ 
    # [vagrant@atlassian1 atlassian]$ 
    # [vagrant@atlassian1 atlassian]$ 
    # [vagrant@atlassian1 atlassian]$ sudo yum -y install tree
    # Loaded plugins: fastestmirror
    # Loading mirror speeds from cached hostfile
    #  * base: centos.serverspace.co.uk
    #  * epel: ftp.nluug.nl
    #  * extras: mirror.netweaver.uk
    #  * updates: mirrors.clouvider.net
    # Resolving Dependencies
    # --> Running transaction check
    # ---> Package tree.x86_64 0:1.6.0-10.el7 will be installed
    # --> Finished Dependency Resolution
    # 
    # Dependencies Resolved
    # 
    # ==========================================================================================================
    #  Package               Arch                    Version                        Repository             Size
    # ==========================================================================================================
    # Installing:
    #  tree                  x86_64                  1.6.0-10.el7                   base                   46 k
    # 
    # Transaction Summary
    # ==========================================================================================================
    # Install  1 Package
    # 
    # Total download size: 46 k
    # Installed size: 87 k
    # Downloading packages:
    # tree-1.6.0-10.el7.x86_64.rpm                                                       |  46 kB  00:00:00     
    # Running transaction check
    # Running transaction test
    # Transaction test succeeded
    # Running transaction
    #   Installing : tree-1.6.0-10.el7.x86_64                                                               1/1 
    #   Verifying  : tree-1.6.0-10.el7.x86_64                                                               1/1 
    # 
    # Installed:
    #   tree.x86_64 0:1.6.0-10.el7                                                                              
    # 
    # Complete!

    sudo tree -L 1 /opt/atlassian

    # /opt/atlassian
    # ├── atlassian-crowd-2.11.2
    # ├── atlassian-crowd-2.11.2.tar.gz
    # ├── bitbucket
    # ├── confluence
    # └── jira
    # 
    # 4 directories, 1 file

    sudo ls -lt

    # total 174348
    # drwxr-xr-x. 14 root root      4096 Nov 16 14:00 confluence
    # drwxr-xr-x. 15 root root       287 Nov 16 13:40 jira
    # drwxr-xr-x.  3 root root        20 Nov 16 12:16 bitbucket
    # drwxr-xr-x. 11 root root      4096 Nov 16 11:17 atlassian-crowd-2.11.2
    # -rw-r--r--.  1 root root 178523922 Nov 16 11:16 atlassian-crowd-2.11.2.tar.gz


<a id="orgfa1c006"></a>

### Crowd

    sudo ls -lt /opt/atlassian/atlassian-crowd-2.11.2

    # total 72
    # -rw-rw-r--.  1 crowd crowd   855 Nov 16 11:17 build.properties
    # drwxr-xr-x.  2 root  root  20480 Nov 16 11:17 licenses
    # drwxr-xr-x.  4 root  root    173 Nov 16 11:17 demo-src
    # drwxr-xr-x. 11 root  root   4096 Nov 16 11:17 demo-webapp
    # drwxr-xr-x. 10 root  root   4096 Nov 16 11:17 crowd-openidserver-webapp
    # drwxr-xr-x. 12 root  root    225 Nov 16 11:17 crowd-openidclient-webapp
    # drwxr-xr-x.  6 root  root    102 Nov 16 11:17 crowd-webapp
    # drwxr-xr-x. 11 root  root    123 Nov 16 11:17 apache-tomcat
    # drwxr-xr-x.  2 root  root     84 Nov 16 11:17 etc
    # -rw-rw-r--.  1 crowd crowd  1256 Mar 31  2017 README.txt
    # drwxr-xr-x.  4 crowd crowd    72 Mar 31  2017 client
    # -rw-rw-r--.  1 crowd crowd   252 Mar 31  2017 build.bat
    # -rwxr--r--.  1 crowd crowd   204 Mar 31  2017 build.sh
    # -rw-rw-r--.  1 crowd crowd  4445 Mar 31  2017 build.xml
    # -rw-rw-r--.  1 crowd crowd    99 Mar 31  2017 start_crowd.bat
    # -rwxr--r--.  1 crowd crowd    70 Mar 31  2017 start_crowd.sh
    # -rw-rw-r--.  1 crowd crowd    98 Mar 31  2017 stop_crowd.bat
    # -rwxr--r--.  1 crowd crowd    71 Mar 31  2017 stop_crowd.sh

    cat /opt/atlassian/atlassian-crowd-2.11.2/crowd-webapp/WEB-INF/classes/crowd-init.properties

    # ## You can specify your crowd.home property here or in your system environment variables.
    # 
    # ###############
    # ##           ##
    # ##  WINDOWS  ##
    # ##           ##
    # ###############
    # ## On Windows-based operating systems, uncomment the following
    # ## line and set crowd.home to a directory Crowd should use to
    # ## store its configuration.
    # ## NOTE: use forward slashes instead of backward slashes.
    # 
    # #crowd.home=c:/data/crowd-home
    # 
    # 
    # ###############
    # ##           ##
    # ##  UNIX     ##
    # ##           ##
    # ###############
    # ## On Unix-based operating systems, uncomment the following
    # ## line and set crowd.home to a directory Crowd should use to
    # ## store its configuration.
    # 
    # #crowd.home=/var/crowd-home
    # crowd.home = /srv/atlassian/crowd

    sudo tree -L 2 /opt/atlassian/atlassian-crowd-2.11.2

    # /opt/atlassian/atlassian-crowd-2.11.2
    # ├── apache-tomcat
    # │   ├── bin
    # │   ├── conf
    # │   ├── lib
    # │   ├── logs
    # │   ├── temp
    # │   ├── tomcat-docs
    # │   ├── tools
    # │   ├── webapps
    # │   └── work
    # ├── build.bat
    # ├── build.properties
    # ├── build.sh
    # ├── build.xml
    # ├── client
    # │   ├── conf
    # │   ├── crowd-integration-client-2.11.2.jar
    # │   └── lib
    # ├── crowd-openidclient-webapp
    # │   ├── 500.jsp
    # │   ├── consumer
    # │   ├── decorator
    # │   ├── favicon.ico
    # │   ├── images
    # │   ├── include
    # │   ├── index.jsp
    # │   ├── login.jsp
    # │   ├── META-INF
    # │   ├── scripts
    # │   ├── secure
    # │   ├── style
    # │   ├── template
    # │   └── WEB-INF
    # ├── crowd-openidserver-webapp
    # │   ├── 500.jsp
    # │   ├── about.jsp
    # │   ├── decorator
    # │   ├── error.jsp
    # │   ├── favicon.ico
    # │   ├── forgottenlogindetails_complete.jsp
    # │   ├── forgottenlogindetails.jsp
    # │   ├── images
    # │   ├── include
    # │   ├── index.jsp
    # │   ├── login.jsp
    # │   ├── META-INF
    # │   ├── secure
    # │   ├── style
    # │   ├── template
    # │   ├── view_identity.jsp
    # │   └── WEB-INF
    # ├── crowd-webapp
    # │   ├── about.jsp
    # │   ├── console
    # │   ├── index.jsp
    # │   ├── META-INF
    # │   ├── template
    # │   └── WEB-INF
    # ├── demo-src
    # │   ├── com
    # │   ├── crowd-ehcache.xml
    # │   ├── crowd.properties
    # │   ├── log4j.properties
    # │   ├── META-INF
    # │   ├── struts.properties
    # │   ├── struts.xml
    # │   └── views.properties
    # ├── demo-webapp
    # │   ├── com
    # │   ├── crowd-ehcache.xml
    # │   ├── crowd.properties
    # │   ├── decorator
    # │   ├── favicon.ico
    # │   ├── images
    # │   ├── include
    # │   ├── index.jsp
    # │   ├── log4j.properties
    # │   ├── login.jsp
    # │   ├── META-INF
    # │   ├── resetpassword.jsp
    # │   ├── secure
    # │   ├── struts.properties
    # │   ├── struts.xml
    # │   ├── style
    # │   ├── template
    # │   ├── views.properties
    # │   └── WEB-INF
    # ├── etc
    # │   ├── crowd.properties
    # │   ├── demo.properties
    # │   └── openidserver.properties
    # ├── licenses
    # │   ├── antlr--antlr--2.7.7.txt
    # │   ├── aopalliance--aopalliance--1.0.txt
    # │   ├── asm--asm--3.3.txt
    # │   ├── asm--asm-commons--3.3.txt
    # │   ├── asm--asm-tree--3.3.txt
    # │   ├── biz.aQute.bnd--biz.aQute.bndlib--2.4.1.txt
    # │   ├── cglib--cglib--2.1_3.txt
    # │   ├── com.amazonaws--aws-java-sdk--1.8.9.txt
    # │   ├── com.atlassian.annotations--atlassian-annotations--0.16.txt
    # │   ├── com.atlassian.annotations--atlassian-annotations--1.1.0.txt
    # │   ├── com.atlassian.applinks--applinks-api--5.2.6.txt
    # │   ├── com.atlassian.applinks--applinks-common--5.2.6.txt
    # │   ├── com.atlassian.applinks--applinks-host--5.2.6.txt
    # │   ├── com.atlassian.applinks--applinks-plugin--5.2.6.txt
    # │   ├── com.atlassian.applinks--applinks-spi--5.2.6.txt
    # │   ├── com.atlassian.aui--auiplugin--5.7.3.txt
    # │   ├── com.atlassian.cache--atlassian-cache-api--2.8.3.txt
    # │   ├── com.atlassian.cache--atlassian-cache-common-impl--2.8.3.txt
    # │   ├── com.atlassian.cache--atlassian-cache-memory--2.8.3.txt
    # │   ├── com.atlassian.config--atlassian-config--0.27.txt
    # │   ├── com.atlassian.core--atlassian-core--5.0.5.txt
    # │   ├── com.atlassian.crowd.client--crowd-scala-client-model_2.11--1.0.0.txt
    # │   ├── com.atlassian.crowd.client--crowd-scala-rest-client_2.11--1.0.0.txt
    # │   ├── com.atlassian.csv--atlassian-csv--1.0.txt
    # │   ├── com.atlassian.event--atlassian-event--3.1.3.txt
    # │   ├── com.atlassian.fugue--fugue--2.2.1.txt
    # │   ├── com.atlassian.healthcheck--atlassian-healthcheck--5.2.1.txt
    # │   ├── com.atlassian.healthcheck--atlassian-healthcheck-plugin-check-api--5.2.1.txt
    # │   ├── com.atlassian.healthcheck--atlassian-healthcheck-spi--5.2.1.txt
    # │   ├── com.atlassian.hibernate--atlassian-hibernate4-extras--6.0.1.txt
    # │   ├── com.atlassian.html--atlassian-html-encoder--1.4.txt
    # │   ├── com.atlassian.http--atlassian-http--1.1.4.txt
    # │   ├── com.atlassian.http--atlassian-http--1.1.6.txt
    # │   ├── com.atlassian.image--atlassian-image-consumer--1.0.1.txt
    # │   ├── com.atlassian.ip--atlassian-ip--3.1.txt
    # │   ├── com.atlassian.jersey--atlassian-jersey-restdoc--1.0.0.txt
    # │   ├── com.atlassian.jersey--atlassian-jersey-restdoc--1.0.3.txt
    # │   ├── com.atlassian.johnson--atlassian-johnson-core--2.1.0.txt
    # │   ├── com.atlassian.json--atlassian-json-api--0.9.txt
    # │   ├── com.atlassian.lesscss--lesscss-core--3.0.1.txt
    # │   ├── com.atlassian.lesscss--lesscss-spi--3.0.1.txt
    # │   ├── com.atlassian.mail--atlassian-mail--2.7.0.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-api--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-bridge--2.0.1-m001.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-bridge--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-consumer-core--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-consumer-plugin--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-consumer-sal-plugin--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-consumer-spi--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-service-provider-plugin--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-service-provider-sal-plugin--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-service-provider-spi--2.0.4.txt
    # │   ├── com.atlassian.oauth--atlassian-oauth-shared--2.0.4.txt
    # │   ├── com.atlassian.pdkinstall--pdkinstall-plugin--0.4.txt
    # │   ├── com.atlassian.plugin--atlassian-spring-scanner-annotation--1.2.13.txt
    # │   ├── com.atlassian.plugin--atlassian-spring-scanner-runtime--1.2.13.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-api--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-core--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-osgi--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-osgi-events--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-servlet--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-spring--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webfragment--4.0.0.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webfragment-api--4.0.0.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webresource--3.5.29.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webresource-api--3.5.29.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webresource-common--4.4.3.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webresource-plugin--3.5.29.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webresource-rest--3.5.29.txt
    # │   ├── com.atlassian.plugins--atlassian-plugins-webresource-spi--3.5.29.txt
    # │   ├── com.atlassian.plugins--jquery--1.8.3.txt
    # │   ├── com.atlassian.plugins--less-transformer-plugin--3.0.1.txt
    # │   ├── com.atlassian.plugins.rest--atlassian-rest-common--3.0.5.txt
    # │   ├── com.atlassian.plugins.rest--atlassian-rest-doclet--3.0.5.txt
    # │   ├── com.atlassian.plugins.rest--atlassian-rest-module--3.0.5.txt
    # │   ├── com.atlassian.profiling--atlassian-profiling--1.8.txt
    # │   ├── com.atlassian.sal--sal-api--3.0.2.txt
    # │   ├── com.atlassian.sal--sal-core--3.0.2.txt
    # │   ├── com.atlassian.sal--sal-spi--3.0.2.txt
    # │   ├── com.atlassian.sal--sal-spring--3.0.2.txt
    # │   ├── com.atlassian.security--atlassian-secure-xml--3.2.10.txt
    # │   ├── com.atlassian.sourcemap--sourcemap--1.7.6.txt
    # │   ├── com.atlassian.soy--atlassian-soy-core--4.0.4.txt
    # │   ├── com.atlassian.soy--soy-template-plugin--4.0.4.txt
    # │   ├── com.atlassian.soy--soy-template-renderer-api--4.0.4.txt
    # │   ├── com.atlassian.soy--soy-template-renderer-plugin-api--4.0.4.txt
    # │   ├── com.atlassian.spring--atlassian-spring--2.0.8.txt
    # │   ├── com.atlassian.support--cdn-bridge-stp--3.9.15.txt
    # │   ├── com.atlassian.support--stp--3.9.15.txt
    # │   ├── com.atlassian.support--stp-api--3.9.15.txt
    # │   ├── com.atlassian.support--stp-spi--3.9.15.txt
    # │   ├── com.atlassian.templaterenderer--atlassian-template-renderer-api--2.0.0.txt
    # │   ├── com.atlassian.templaterenderer--atlassian-template-renderer-velocity16-plugin--2.0.0.txt
    # │   ├── com.atlassian.templaterenderer--atlassian-template-renderer-velocity-common--2.0.0.txt
    # │   ├── com.atlassian.util.concurrent--atlassian-util-concurrent--3.0.0.txt
    # │   ├── com.chuusai--shapeless_2.11--1.2.4.txt
    # │   ├── com.fasterxml.jackson.core--jackson-annotations--2.1.1.txt
    # │   ├── com.fasterxml.jackson.core--jackson-annotations--2.3.0.txt
    # │   ├── com.fasterxml.jackson.core--jackson-core--2.1.1.txt
    # │   ├── com.fasterxml.jackson.core--jackson-core--2.3.3.txt
    # │   ├── com.fasterxml.jackson.core--jackson-databind--2.1.1.txt
    # │   ├── com.fasterxml.jackson.core--jackson-databind--2.3.3.txt
    # │   ├── com.fasterxml.jackson.jaxrs--jackson-jaxrs-base--2.3.3.txt
    # │   ├── com.fasterxml.jackson.jaxrs--jackson-jaxrs-json-provider--2.3.3.txt
    # │   ├── com.fasterxml.jackson.module--jackson-module-jaxb-annotations--2.3.3.txt
    # │   ├── com.google.code.findbugs--findbugs-annotations--3.0.1.txt
    # │   ├── com.google.code.findbugs--jsr305--3.0.0.txt
    # │   ├── com.google.code.gson--gson--2.2.3.txt
    # │   ├── com.googlecode.jtype--jtype--0.1.0.txt
    # │   ├── com.google.guava--guava--18.0.txt
    # │   ├── com.google.inject--guice--3.0.txt
    # │   ├── com.google.template.soy--soycompiler--20140422-8ece726-atlassian-5.txt
    # │   ├── com.ibm.icu--icu4j--4.8.1.txt
    # │   ├── com.ibm.icu--icu4j--51.1.txt
    # │   ├── com.mchange--c3p0--0.9.2.1.txt
    # │   ├── com.mchange--mchange-commons-java--0.2.3.4.txt
    # │   ├── commons-beanutils--commons-beanutils--1.9.2.txt
    # │   ├── commons-codec--commons-codec--1.10.txt
    # │   ├── commons-codec--commons-codec--1.4.txt
    # │   ├── commons-codec--commons-codec--1.8.txt
    # │   ├── commons-collections--commons-collections--3.2.1.txt
    # │   ├── commons-collections--commons-collections--3.2.2.txt
    # │   ├── commons-digester--commons-digester--1.4.1.txt
    # │   ├── commons-fileupload--commons-fileupload--1.3.1.txt
    # │   ├── commons-fileupload--commons-fileupload--1.3.txt
    # │   ├── commons-httpclient--commons-httpclient--3.1-atlassian-2.txt
    # │   ├── commons-io--commons-io--1.4.txt
    # │   ├── commons-io--commons-io--2.4.txt
    # │   ├── commons-lang--commons-lang--2.5.txt
    # │   ├── commons-lang--commons-lang--2.6.txt
    # │   ├── commons-logging--commons-logging--1.2.txt
    # │   ├── commons-pool--commons-pool--1.5.4.txt
    # │   ├── com.oracle--ojdbc6--11.2.0.2.0.txt
    # │   ├── com.sun.jersey.contribs--wadl-resourcedoc-doclet--1.8-atlassian-16.txt
    # │   ├── com.sun.jersey--jersey-client--1.8-atlassian-16.txt
    # │   ├── com.sun.jersey--jersey-core--1.8-atlassian-16.txt
    # │   ├── com.sun.jersey--jersey-json--1.8-atlassian-16.txt
    # │   ├── com.sun.jersey--jersey-server--1.8-atlassian-16.txt
    # │   ├── com.sun.jersey--jersey-servlet--1.19.txt
    # │   ├── com.thoughtworks.paranamer--paranamer--2.3.txt
    # │   ├── com.typesafe.akka--akka-actor_2.11--2.3.7.txt
    # │   ├── com.typesafe.akka--akka-slf4j_2.11--2.3.7.txt
    # │   ├── com.typesafe--config--1.2.1.txt
    # │   ├── dom4j--dom4j--1.6.1.txt
    # │   ├── hsqldb--hsqldb--1.8.0.10.txt
    # │   ├── io.spray--spray-can_2.11--1.3.2.txt
    # │   ├── io.spray--spray-client_2.11--1.3.2.txt
    # │   ├── io.spray--spray-http_2.11--1.3.2.txt
    # │   ├── io.spray--spray-httpx_2.11--1.3.2.txt
    # │   ├── io.spray--spray-io_2.11--1.3.2.txt
    # │   ├── io.spray--spray-json_2.11--1.3.1.txt
    # │   ├── io.spray--spray-routing_2.11--1.3.2.txt
    # │   ├── io.spray--spray-servlet_2.11--1.3.2.txt
    # │   ├── io.spray--spray-util_2.11--1.3.2.txt
    # │   ├── javax.activation--activation--1.1.1.txt
    # │   ├── javax.activation--activation--1.1.txt
    # │   ├── javax.annotation--javax.annotation-api--1.2.txt
    # │   ├── javax.inject--javax.inject--1.txt
    # │   ├── javax.mail--mail--1.4.7.txt
    # │   ├── javax.servlet--servlet-api--2.5.txt
    # │   ├── javax.transaction--jta--1.1.txt
    # │   ├── javax.validation--validation-api--1.1.0.Final.txt
    # │   ├── javax.ws.rs--javax.ws.rs-api--2.0.txt
    # │   ├── javax.ws.rs--jsr311-api--1.1.1.txt
    # │   ├── javax.ws.rs--jsr311-api--1.1.txt
    # │   ├── jaxen--jaxen--1.1.6.txt
    # │   ├── joda-time--joda-time--2.6.txt
    # │   ├── jug--jug--1.1.2.txt
    # │   ├── log4j--log4j--1.2.17.txt
    # │   ├── net.java.dev.stax-utils--stax-utils--20040917.txt
    # │   ├── net.jcip--jcip-annotations--1.0.txt
    # │   ├── net.oauth.core--oauth--20100601-atlassian-2.txt
    # │   ├── net.oauth.core--oauth-provider--20100601-atlassian-2.txt
    # │   ├── net.sf.ehcache--ehcache--2.9.0.txt
    # │   ├── net.sf.ehcache--sizeof-agent--1.0.1.txt
    # │   ├── net.sourceforge.jtds--jtds--1.3.1.txt
    # │   ├── net.sourceforge.nekohtml--nekohtml--1.9.21.txt
    # │   ├── ognl--ognl--3.0.17.txt
    # │   ├── opensymphony--oscore--2.2.7-atlassian-1.txt
    # │   ├── opensymphony--propertyset--1.3-21Nov03.txt
    # │   ├── opensymphony--sitemesh--2.3.txt
    # │   ├── org.antlr--antlr-runtime--3.5.2.txt
    # │   ├── org.apache.avro--avro--1.7.7.txt
    # │   ├── org.apache.commons--commons-lang3--3.1.txt
    # │   ├── org.apache.commons--commons-lang3--3.3.2.txt
    # │   ├── org.apache.commons--commons-pool2--2.0.txt
    # │   ├── org.apache.felix--org.apache.felix.framework--4.2.1.txt
    # │   ├── org.apache.httpcomponents--httpclient--4.4.1.txt
    # │   ├── org.apache.httpcomponents--httpclient--4.5.3.txt
    # │   ├── org.apache.httpcomponents--httpclient-cache--4.5.3.txt
    # │   ├── org.apache.httpcomponents--httpcore--4.4.1.txt
    # │   ├── org.apache.httpcomponents--httpmime--4.5.3.txt
    # │   ├── org.apache.servicemix.bundles--org.apache.servicemix.bundles.velocity--1.6.4_4.txt
    # │   ├── org.apache.struts--struts2-core--2.3.32.txt
    # │   ├── org.apache.struts--struts2-sitemesh-plugin--2.3.32.txt
    # │   ├── org.apache.struts--struts2-spring-plugin--2.3.32.txt
    # │   ├── org.apache.struts.xwork--xwork-core--2.3.32.txt
    # │   ├── org.apache.tomcat--apache-tomcat--7.0.69-atlassian-hosted.txt
    # │   ├── org.apache.velocity--velocity--1.6.1.txt
    # │   ├── org.apache.ws.commons--XmlSchema--1.1.txt
    # │   ├── org.apache.xbean--xbean-spring--2.8.txt
    # │   ├── org.bouncycastle--bcprov-jdk15on--1.51.txt
    # │   ├── org.codehaus.jackson--jackson-core-asl--1.9.13.txt
    # │   ├── org.codehaus.jackson--jackson-jaxrs--1.9.13.txt
    # │   ├── org.codehaus.jackson--jackson-mapper-asl--1.9.13.txt
    # │   ├── org.codehaus.jackson--jackson-xc--1.9.13.txt
    # │   ├── org.codehaus.jettison--jettison--1.1.txt
    # │   ├── org.codehaus.woodstox--wstx-asl--3.2.4.txt
    # │   ├── org.codehaus.xfire--xfire-aegis--1.2.6.txt
    # │   ├── org.codehaus.xfire--xfire-core--1.2.6.txt
    # │   ├── org.codehaus.xfire--xfire-java5--1.2.6.txt
    # │   ├── org.codehaus.xfire--xfire-spring--1.2.6.txt
    # │   ├── org.codehaus.xfire--xfire-xmlbeans--1.2.6.txt
    # │   ├── org.eclipse.jetty--jetty-continuation--8.1.15.v20140411.txt
    # │   ├── org.eclipse.jetty--jetty-http--8.1.15.v20140411.txt
    # │   ├── org.eclipse.jetty--jetty-io--8.1.15.v20140411.txt
    # │   ├── org.eclipse.jetty--jetty-security--8.1.15.v20140411.txt
    # │   ├── org.eclipse.jetty--jetty-server--8.1.15.v20140411.txt
    # │   ├── org.eclipse.jetty--jetty-servlet--8.1.15.v20140411.txt
    # │   ├── org.eclipse.jetty--jetty-util--8.1.15.v20140411.txt
    # │   ├── org.freemarker--freemarker--2.3.22.txt
    # │   ├── org.glassfish.hk2--osgi-resource-locator--1.0.1.txt
    # │   ├── org.hamcrest--hamcrest-core--1.3.txt
    # │   ├── org.hibernate.common--hibernate-commons-annotations--4.0.2.Final.txt
    # │   ├── org.hibernate--hibernate-c3p0--4.2.13.Final.txt
    # │   ├── org.hibernate--hibernate-core--4.2.13.Final.txt
    # │   ├── org.hibernate--hibernate-ehcache--4.2.13.Final.txt
    # │   ├── org.hibernate--hibernate-validator--4.0.2.GA.txt
    # │   ├── org.hibernate.javax.persistence--hibernate-jpa-2.0-api--1.0.1.Final.txt
    # │   ├── org.hsqldb--hsqldb--1.8.0.10.txt
    # │   ├── org.javassist--javassist--3.18.1-GA.txt
    # │   ├── org.jboss.logging--jboss-logging--3.1.0.GA.txt
    # │   ├── org.jboss.spec.javax.transaction--jboss-transaction-api_1.1_spec--1.0.1.Final.txt
    # │   ├── org.jdom--jdom--1.1.3.txt
    # │   ├── org.json--json--20080701.txt
    # │   ├── org.jsoup--jsoup--1.8.3.txt
    # │   ├── org.jvnet.mimepull--mimepull--1.9.4.txt
    # │   ├── org.jvnet--tiger-types--1.4.txt
    # │   ├── org.mindrot--jbcrypt--0.4-atlassian-1.txt
    # │   ├── org.mockito--mockito-core--1.10.19.txt
    # │   ├── org.mozilla--rhino--1.7R5.txt
    # │   ├── org.objenesis--objenesis--2.1.txt
    # │   ├── org.openid4java--openid4java--0.9.8.txt
    # │   ├── org.openxri--openxri-client--1.2.1.txt
    # │   ├── org.openxri--openxri-syntax--1.2.1.txt
    # │   ├── org.ow2.asm--asm--5.0.3.txt
    # │   ├── org.parboiled--parboiled-core--1.1.6.txt
    # │   ├── org.parboiled--parboiled-scala_2.11--1.1.6.txt
    # │   ├── org.postgresql--postgresql--9.2-1003-jdbc4.txt
    # │   ├── org.quartz-scheduler--quartz--1.8.6.txt
    # │   ├── org.quartz-scheduler--quartz-oracle--1.8.6.txt
    # │   ├── org.scala-lang.modules--scala-xml_2.11--1.0.2.txt
    # │   ├── org.scala-lang--scala-library--2.11.6.txt
    # │   ├── org.slf4j--jcl-over-slf4j--1.7.10.txt
    # │   ├── org.slf4j--jul-to-slf4j--1.7.10.txt
    # │   ├── org.slf4j--slf4j-api--1.7.10.txt
    # │   ├── org.slf4j--slf4j-log4j12--1.6.4.txt
    # │   ├── org.slf4j--slf4j-log4j12--1.7.10.txt
    # │   ├── org.sonatype.sisu.inject--cglib--3.1.1.txt
    # │   ├── org.sonatype.sisu.inject--guice-assistedinject--3.1.8.txt
    # │   ├── org.sonatype.sisu.inject--guice-multibindings--3.1.8.txt
    # │   ├── org.sonatype.sisu--sisu-guice--3.1.8.txt
    # │   ├── org.springframework.ldap--spring-ldap-core--2.2.0-atlassian-1.txt
    # │   ├── org.springframework.security--spring-security-config--3.2.5.RELEASE.txt
    # │   ├── org.springframework.security--spring-security-core--3.2.5.RELEASE.txt
    # │   ├── org.springframework.security--spring-security-web--3.2.5.RELEASE.txt
    # │   ├── org.springframework--spring-aop--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-beans--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-context--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-context-support--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-core--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-expression--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-jdbc--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-orm--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-tx--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-web--3.2.10.RELEASE.txt
    # │   ├── org.springframework--spring-webmvc--3.2.10.RELEASE.txt
    # │   ├── org.tuckey--urlrewritefilter--4.0.3.txt
    # │   ├── org.twdata.pkgscanner--package-scanner--0.9.5.txt
    # │   ├── oro--oro--2.0.8.txt
    # │   ├── redis.clients--jedis--2.6.1.txt
    # │   ├── spring--spring-aopalliance--1.0.txt
    # │   ├── stax-utils--stax-utils--snapshot-20040917.txt
    # │   ├── uk.org.simonsite--log4j-rolling-appender--20131024-2017.txt
    # │   ├── wsdl4j--wsdl4j--1.6.1.txt
    # │   ├── xalan--xalan--2.7.0.txt
    # │   ├── xerces--xercesImpl--2.8.1.txt
    # │   ├── xfire--xfire-jsr181-api--1.0-M1.txt
    # │   ├── xml-apis--xml-apis--1.4.01.txt
    # │   ├── xmlbeans--xbean--2.2.0.txt
    # │   └── xml-security--xmlsec--1.4.2.txt
    # ├── README.txt
    # ├── start_crowd.bat
    # ├── start_crowd.sh
    # ├── stop_crowd.bat
    # └── stop_crowd.sh
    # 
    # 53 directories, 335 files


<a id="org15f026d"></a>

### Confluence

    sudo ls -lt /opt/atlassian/confluence

    # total 268
    # drwx------.  2 confluence root  4096 Nov 18 11:10 logs
    # drwx------.  5 confluence root   167 Nov 16 14:55 temp
    # drwx------.  3 confluence root    44 Nov 16 14:53 work
    # drwxr-xr-x.  2 root       root  4096 Nov 16 14:00 bin
    # drwxr-xr-x.  3 root       root   200 Nov 16 14:00 conf
    # -rw-r--r--.  1 root       root 81775 Nov 16 14:00 install.reg
    # drwxr-xr-x.  4 root       root    37 Nov 16 14:00 synchrony-proxy
    # drwxr-xr-x.  2 root       root 45056 Nov 16 14:00 licenses
    # drwxr-xr-x.  2 root       root  4096 Nov 16 14:00 lib
    # drwxr-xr-x. 26 root       root  4096 Nov 16 14:00 confluence
    # drwxr-xr-x.  4 root       root   129 Nov 16 13:59 jre
    # -rwx------.  1 root       root 11200 May  2  2017 uninstall
    # drwxr-xr-x.  2 root       root     6 May  2  2017 webapps
    # -rw-r--r--.  1 root       root 58068 May  2  2017 LICENSE
    # -rw-r--r--.  1 root       root  1489 May  2  2017 NOTICE
    # -rw-r--r--.  1 root       root  2291 May  2  2017 README.html
    # -rw-r--r--.  1 root       root  1202 May  2  2017 README.txt
    # -rw-r--r--.  1 root       root  6913 May  2  2017 RELEASE-NOTES
    # -rw-r--r--.  1 root       root 16671 May  2  2017 RUNNING.txt

    cat /opt/atlassian/confluence/confluence/WEB-INF/classes/confluence-init.properties

    # # This file allows you to set the directory for Confluence to store its configuration files.
    # #
    # ###########################
    # # Note for Windows Users  #
    # ###########################
    # #
    # # Each backslash in your path must be written as a forward slash.
    # # - For example:
    # # c:\confluence\data
    # #
    # # should be written as:
    # #
    # # c:/confluence/data
    # 
    # ###########################
    # # Note for Unix Users     #
    # ###########################
    # # - For example:
    # # confluence.home=/var/confluence
    # #
    # # NOTE: If the path of your confluence.home directory contains symlinks,
    # # please set confluence.home to the absolute path, otherwise problems may occur.
    # # - For example:
    # # confluence.home=/data/confluence/ (where /data is a symlink to -> /var/data/)
    # # should be written as:
    # # confluence.home=/var/data/confluence/
    # 
    # ###########################
    # # Configuration Directory #
    # ###########################
    # 
    # # specify your directory below (don't forget to remove the '#' in front)
    # 
    # confluence.home = /srv/atlassian/confluence

    sudo tree -L 2 /opt/atlassian/atlassian-crowd-2.11.2


<a id="org7bf33bc"></a>

### Jira

    sudo ls -lt /opt/atlassian/jira

    # total 184
    # drwx------.  2 jira root   270 Nov 19 00:58 logs
    # drwx------.  3 jira root    42 Nov 16 14:55 work
    # drwxr-xr-x.  3 root root  4096 Nov 16 13:40 bin
    # drwxr-xr-x.  2 root root   238 Nov 16 13:40 conf
    # -rw-r--r--.  1 root root 83729 Nov 16 13:40 install.reg
    # drwxr-xr-x.  2 root root    61 Nov 16 13:39 tomcat-docs
    # drwx------.  2 jira root    48 Nov 16 13:39 temp
    # drwxr-xr-x.  2 root root 49152 Nov 16 13:39 licenses
    # drwxr-xr-x.  2 root root  4096 Nov 16 13:39 lib
    # drwxr-xr-x.  2 root root    41 Nov 16 13:39 external-source
    # drwxr-xr-x. 17 root root  4096 Nov 16 13:39 atlassian-jira
    # drwxr-xr-x.  4 root root   129 Nov 16 13:39 jre
    # -rwx------.  1 root root 11200 Apr 25  2017 uninstall
    # drwxr-xr-x.  2 root root     6 Apr 25  2017 webapps
    # -rw-r--r--.  1 root root  1774 Apr 25  2017 NOTICE
    # -rw-r--r--.  1 root root  3825 Apr 25  2017 README.html
    # -rw-r--r--.  1 root root  2089 Apr 25  2017 README.txt

    cat /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/jira-application.properties

    # # Do not modify this file unless instructed. It is here to store the location of the JIRA home directory only and is typically written to by the installer.
    # jira.home = /srv/atlassian/jira

    sudo tree -L 2 /opt/atlassian/atlassian-crowd-2.11.2


<a id="org8e35a84"></a>

### BitBucket

    sudo ls -lt /opt/atlassian/bitbucket/4.14.3

    # total 64
    # drwx------. 2 atlbitbucket atlbitbucket   282 Nov 18 11:31 logs
    # drwx------. 3 atlbitbucket atlbitbucket    42 Nov 18 11:31 work
    # drwxr-xr-x. 3 atlbitbucket atlbitbucket   226 Nov 16 12:16 conf
    # drwxr-xr-x. 2 atlbitbucket atlbitbucket    75 Nov 16 12:16 tomcat-docs
    # drwx------. 2 atlbitbucket atlbitbucket    30 Nov 16 12:16 temp
    # drwxr-xr-x. 2 atlbitbucket atlbitbucket 32768 Nov 16 12:16 licenses
    # drwxr-xr-x. 3 atlbitbucket atlbitbucket  4096 Nov 16 12:16 lib
    # drwxr-xr-x. 7 atlbitbucket atlbitbucket   140 Nov 16 12:16 elasticsearch
    # drwxr-xr-x. 2 atlbitbucket atlbitbucket  4096 Nov 16 12:16 bin
    # drwxr-xr-x. 5 atlbitbucket atlbitbucket   126 Nov 16 12:16 atlassian-bitbucket
    # -rw-r--r--. 1 atlbitbucket atlbitbucket   127 Mar 19  2017 Launch Bitbucket in browser.url
    # -rw-r--r--. 1 atlbitbucket atlbitbucket  2588 Mar 19  2017 README.txt
    # drwxr-xr-x. 2 atlbitbucket atlbitbucket     6 Mar 19  2017 webapps

    cat /opt/atlassian/bitbucket/4.14.3/bin/set-bitbucket-user.sh

    # # START INSTALLER MAGIC ! DO NOT EDIT !
    # BITBUCKET_USER="atlbitbucket" # user created by installer
    # # END INSTALLER MAGIC ! DO NOT EDIT !
    # 
    # export BITBUCKET_USER

    cat /opt/atlassian/bitbucket/4.14.3/bin/set-bitbucket-home.sh

    # #!/usr/bin/env bash
    # #
    # # One way to set the BITBUCKET_HOME path is here via this variable.  Simply uncomment it and set a valid path like
    # # /bitbucket/home.  You can of course set it outside in the command terminal; that will also work.
    # #
    # 
    # if [ "x${BITBUCKET_HOME}" = "x" ]; then
    #     export BITBUCKET_HOME=/srv/atlassian/bitbucket
    # fi
    # 
    # # When upgrading from the packaged distribution BITBUCKET_HOME may not be set. Fallback to legacy STASH_HOME
    # # and output a message for the user recommending that they update their environment
    # if [ "x${BITBUCKET_HOME}" = "x" ]; then
    #     if [ ! "x${STASH_HOME}" = "x" ]; then
    #         BITBUCKET_HOME=${STASH_HOME}
    #         echo ""
    #         echo "--------------------------------------------------------------------------------------"
    #         echo "  WARNING: STASH_HOME has been deprecated and replaced with BITBUCKET_HOME."
    #         echo "  We recommend you set BITBUCKET_HOME instead of STASH_HOME."
    #         echo "  Future versions of Bitbucket may not support the STASH_HOME variable."
    #         echo "--------------------------------------------------------------------------------------"
    #     fi
    # fi
    # 
    # echo $BITBUCKET_HOME | grep -q " "
    # if [ $? -eq 0 ]; then
    #     echo ""
    #     echo "-------------------------------------------------------------------------------"
    #     echo "  BITBUCKET_HOME \"$BITBUCKET_HOME\" contains spaces."
    #     echo "  Using a directory with spaces is likely to cause unexpected behaviour and is"
    #     echo "  not supported. Please use a directory which does not contain spaces."
    #     echo "-------------------------------------------------------------------------------"
    #     exit 1
    # fi
    # 
    # if [ -z "$BITBUCKET_HOME" ]; then
    #     echo ""
    #     echo "--------------------------------------------------------------------------------------"
    #     echo "  Bitbucket doesn't know where to store its data. Please configure the BITBUCKET_HOME"
    #     echo "  environment variable with the directory where Bitbucket should store its data."
    #     echo "  Ensure that the path to BITBUCKET_HOME does not contain spaces. BITBUCKET_HOME may"
    #     echo "  be configured in set-bitbucket-home.sh, if preferred, rather than exporting it as an"
    #     echo "  environment variable."
    #     echo "--------------------------------------------------------------------------------------"
    #     exit 1
    # fi

    sudo tree -L 2 /opt/atlassian/atlassian-crowd-2.11.2


<a id="orgc4e5d69"></a>

### Home directory structure (/srv/atlassian)


<a id="orgec66ecb"></a>

#### Atlassian products

    sudo ls -lt /srv/atlassian

    # total 4
    # drwxr-xr-x. 11 atlbitbucket atlbitbucket  158 Nov 18 11:31 bitbucket
    # drwxr-xr-x.  8 crowd        crowd         152 Nov 17 02:00 crowd
    # drwx------. 17 confluence   root         4096 Nov 16 14:55 confluence
    # drwx------. 12 jira         root          190 Nov 16 13:53 jira

    sudo tree -L 2 /srv/atlassian

    # /srv/atlassian
    # ├── bitbucket
    # │   ├── analytics-logs
    # │   ├── bin
    # │   ├── caches
    # │   ├── export
    # │   ├── lib
    # │   ├── log
    # │   ├── plugins
    # │   ├── shared
    # │   └── tmp
    # ├── confluence
    # │   ├── analytics-logs
    # │   ├── attachments
    # │   ├── backups
    # │   ├── bundled-plugins
    # │   ├── confluence.cfg.xml
    # │   ├── imgEffects
    # │   ├── index
    # │   ├── journal
    # │   ├── lock
    # │   ├── logs
    # │   ├── plugins-cache
    # │   ├── plugins-osgi-cache
    # │   ├── plugins-temp
    # │   ├── shared-home
    # │   ├── synchrony-args.properties
    # │   ├── temp
    # │   ├── viewfile
    # │   └── webresource-temp
    # ├── crowd
    # │   ├── analytics-logs
    # │   ├── backups
    # │   ├── bundled-plugins
    # │   ├── caches
    # │   ├── crowd.cfg.xml
    # │   ├── crowd.properties
    # │   ├── logs
    # │   └── plugins
    # └── jira
    #     ├── analytics-logs
    #     ├── caches
    #     ├── data
    #     ├── dbconfig.xml
    #     ├── export
    #     ├── import
    #     ├── log
    #     ├── logos
    #     ├── monitor
    #     ├── plugins
    #     └── tmp
    # 
    # 44 directories, 6 files


<a id="org12dd7e7"></a>

#### Crowd

    cat /srv/atlassian/crowd/crowd.properties

    # #Fri Nov 16 11:37:58 UTC 2018
    # session.lastvalidation=session.lastvalidation
    # session.tokenkey=session.tokenkey
    # crowd.server.url=http\://192.168.56.31\:8095/crowd/services/
    # application.name=crowd
    # http.timeout=30000
    # session.isauthenticated=session.isauthenticated
    # application.login.url=http\://192.168.56.31\:8095/crowd
    # session.validationinterval=0
    # application.password=QGJSxFjwpsj8S5bIW0AwoY

    cat /srv/atlassian/crowd/crowd.cfg.xml

    # <?xml version="1.0" encoding="UTF-8"?>
    # 
    # <application-configuration>
    #   <setupStep>complete</setupStep>
    #   <setupType>install.new</setupType>
    #   <buildNumber>727</buildNumber>
    #   <properties>
    #     <property name="crowd.server.id">BN4K-VUOS-XN1O-GKL4</property>
    #     <property name="hibernate.c3p0.acquire_increment">1</property>
    #     <property name="hibernate.c3p0.idle_test_period">100</property>
    #     <property name="hibernate.c3p0.max_size">30</property>
    #     <property name="hibernate.c3p0.max_statements">0</property>
    #     <property name="hibernate.c3p0.min_size">0</property>
    #     <property name="hibernate.c3p0.timeout">30</property>
    #     <property name="hibernate.connection.driver_class">org.postgresql.Driver</property>
    #     <property name="hibernate.connection.password">crowd</property>
    #     <property name="hibernate.connection.url">jdbc:postgresql://localhost:5432/atlassian?currentSchema=crowd&amp;reWriteBatchedInserts=true&amp;prepareThreshold=0</property>
    #     <property name="hibernate.connection.username">crowd</property>
    #     <property name="hibernate.dialect">org.hibernate.dialect.PostgreSQLDialect</property>
    #     <property name="hibernate.setup">true</property>
    #     <property name="license">AAABOQ0ODAoPeNqFkV1LwzAYhe/zKwLe6EXG0tUig4DaVhnrWrHb8MKbGN/NYJaUJK3OX2+71k8EL wLhPclzzkmOrqzEuWkwjfD4dBpMpu0mLpc4GNMzlIATVlZeGs1ia14e8XEJtgF7cj/FacNVzTsNi U4bceFlA8zbGlBs4SAl3APrWIRSQiMUG+3bcznfAWuMegY7egOlzk0l/RsRRrtaeam3I2F2A7b03 HqwbMOVg2GWSQHawXJfwQEVF4tFehvPLrIPh3TBpfrf4qtEn1v14DVY180C1GK0B821gPS1knb/r VHQNSrslmvpekbReeD40wP1zzVL2GUezsl6VZTkLqcFuZ5nISrTnLWLZDSIokkYToZ2eb17AFtsV q6NwQhFQ90Wk82SnzcG6e9sN7UVT9zB7194B11Wp40wLQIVAI//QeVO1pC/OyPFySAUq08HDX2jA hQ3WTO7ucUj+gm+KRZkkjhR+5uw9Q==X02fn</property>
    #   </properties>
    # </application-configuration>


<a id="org65c5988"></a>

#### Confluence

    cat /srv/atlassian/crowd/crowd.cfg.xml

    # <?xml version="1.0" encoding="UTF-8"?>
    # 
    # <application-configuration>
    #   <setupStep>complete</setupStep>
    #   <setupType>install.new</setupType>
    #   <buildNumber>727</buildNumber>
    #   <properties>
    #     <property name="crowd.server.id">BN4K-VUOS-XN1O-GKL4</property>
    #     <property name="hibernate.c3p0.acquire_increment">1</property>
    #     <property name="hibernate.c3p0.idle_test_period">100</property>
    #     <property name="hibernate.c3p0.max_size">30</property>
    #     <property name="hibernate.c3p0.max_statements">0</property>
    #     <property name="hibernate.c3p0.min_size">0</property>
    #     <property name="hibernate.c3p0.timeout">30</property>
    #     <property name="hibernate.connection.driver_class">org.postgresql.Driver</property>
    #     <property name="hibernate.connection.password">crowd</property>
    #     <property name="hibernate.connection.url">jdbc:postgresql://localhost:5432/atlassian?currentSchema=crowd&amp;reWriteBatchedInserts=true&amp;prepareThreshold=0</property>
    #     <property name="hibernate.connection.username">crowd</property>
    #     <property name="hibernate.dialect">org.hibernate.dialect.PostgreSQLDialect</property>
    #     <property name="hibernate.setup">true</property>
    #     <property name="license">AAABOQ0ODAoPeNqFkV1LwzAYhe/zKwLe6EXG0tUig4DaVhnrWrHb8MKbGN/NYJaUJK3OX2+71k8EL wLhPclzzkmOrqzEuWkwjfD4dBpMpu0mLpc4GNMzlIATVlZeGs1ia14e8XEJtgF7cj/FacNVzTsNi U4bceFlA8zbGlBs4SAl3APrWIRSQiMUG+3bcznfAWuMegY7egOlzk0l/RsRRrtaeam3I2F2A7b03 HqwbMOVg2GWSQHawXJfwQEVF4tFehvPLrIPh3TBpfrf4qtEn1v14DVY180C1GK0B821gPS1knb/r VHQNSrslmvpekbReeD40wP1zzVL2GUezsl6VZTkLqcFuZ5nISrTnLWLZDSIokkYToZ2eb17AFtsV q6NwQhFQ90Wk82SnzcG6e9sN7UVT9zB7194B11Wp40wLQIVAI//QeVO1pC/OyPFySAUq08HDX2jA hQ3WTO7ucUj+gm+KRZkkjhR+5uw9Q==X02fn</property>
    #   </properties>
    # </application-configuration>


<a id="org2f3277c"></a>

#### Jira

    sudo cat /srv/atlassian/jira/dbconfig.xml

    # <?xml version="1.0" encoding="UTF-8"?>
    # 
    # <jira-database-config>
    #   <name>defaultDS</name>
    #   <delegator-name>default</delegator-name>
    #   <database-type>postgres72</database-type>
    #   <schema-name>jira</schema-name>
    #   <jdbc-datasource>
    #     <url>jdbc:postgresql://localhost:5432/atlassian</url>
    #     <driver-class>org.postgresql.Driver</driver-class>
    #     <username>jira</username>
    #     <password>jira</password>
    #     <pool-min-size>20</pool-min-size>
    #     <pool-max-size>20</pool-max-size>
    #     <pool-max-wait>30000</pool-max-wait>
    #     <validation-query>select 1</validation-query>
    #     <min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
    #     <time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
    #     <pool-max-idle>20</pool-max-idle>
    #     <pool-remove-abandoned>true</pool-remove-abandoned>
    #     <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
    #     <pool-test-on-borrow>false</pool-test-on-borrow>
    #     <pool-test-while-idle>true</pool-test-while-idle>
    #   </jdbc-datasource>
    # </jira-database-config>


<a id="org84e1f99"></a>

#### BitBucket

    cat /srv/atlassian/bitbucket/shared/bitbucket.properties

    # # see documentation here: https://confluence.atlassian.com/bitbucketserver/automated-setup-for-bitbucket-server-776640098.html
    # #The display name for the Bitbucket Server application.
    # # setup.displayName removed by unattended setup on 2018-11-16T12:18:47.797Z
    # 
    # #The base URL
    # # setup.baseUrl removed by unattended setup on 2018-11-16T12:18:47.798Z
    # 
    # #The Bitbucket Server license.
    # #Use the \ character at the end of each line if you wish to break the license
    # #string over multiple lines.
    # setup.license=
    # jdbc.driver=org.postgresql.Driver
    # jdbc.url=jdbc:postgresql://localhost:5432/bitbucket
    # jdbc.user=bitbucket
    # jdbc.password=bitbucket
    # server.port=7990
    # #plugin.search.elasticsearch.baseurl=http://localhost:7992/
    # #plugin.search.elasticsearch.username=bitbucket
    # #plugin.search.elasticsearch.password=bitbucket
    # plugin.auth-crowd.sso.enabled=true


<a id="orgb3f7038"></a>

### User home directories

    ls -lt /home

    # total 0
    # drwx------. 7 vagrant      vagrant      194 Nov 19 10:22 vagrant
    # drwx------. 3 confluence   confluence    87 Nov 16 14:00 confluence
    # drwx------. 3 jira         jira          87 Nov 16 13:39 jira
    # drwx------. 3 atlbitbucket atlbitbucket  78 Nov 16 12:17 atlbitbucket


<a id="org5f133e0"></a>

## Rundeck

    cd /etc/rundeck

    ls -lt

    # total 56
    # -rw-r-----. 1 rundeck rundeck  756 Nov 18 07:41 rundeck-config.properties
    # -rw-r-----. 1 rundeck rundeck 2925 Nov 18 07:41 profile
    # -rw-r-----. 1 rundeck rundeck 1128 Nov 18 07:41 apitoken.aclpolicy
    # -rw-r-----. 1 rundeck rundeck  782 Nov 18 07:41 admin.aclpolicy
    # -rw-------. 1 rundeck rundeck  248 Nov 18 07:41 jaas-crowd.conf
    # -rw-r-----. 1 rundeck rundeck 1450 Nov 18 07:40 framework.properties
    # drwxr-x---. 2 rundeck rundeck   28 Nov 18 07:40 ssl
    # -rw-r-----. 1 rundeck rundeck  738 Apr 19  2017 admin.aclpolicy.31371.2018-11-18@07:41:20~
    # -rw-r-----. 1 rundeck rundeck 1104 Apr 19  2017 apitoken.aclpolicy.31446.2018-11-18@07:41:20~
    # -rw-r-----. 1 rundeck rundeck  511 Apr 19  2017 cli-log4j.properties
    # -rw-r-----. 1 rundeck rundeck  136 Apr 19  2017 jaas-loginmodule.conf
    # -rw-r-----. 1 rundeck rundeck 7538 Apr 19  2017 log4j.properties
    # -rw-r-----. 1 rundeck rundeck  549 Apr 19  2017 project.properties
    # -rw-r-----. 1 rundeck rundeck  986 Apr 19  2017 realm.properties

    sudo cat /etc/rundeck/rundeck-config.properties

    # #loglevel.default is the default log level for jobs: ERROR,WARN,INFO,VERBOSE,DEBUG
    # loglevel.default=INFO
    # rdeck.base=/var/lib/rundeck
    # 
    # #rss.enabled if set to true enables RSS feeds that are public (non-authenticated)
    # rss.enabled=false
    # # change hostname here
    # grails.serverURL=http://192.168.56.31:4440/rundeck
    # dataSource.dbCreate = update
    # dataSource.url=jdbc:postgresql://192.168.56.31:5432/rundeck
    # dataSource.driverClassName=org.postgresql.Driver
    # dataSource.dialect=org.hibernate.dialect.PostgreSQLDialect
    # dataSource.username=rundeck
    # dataSource.password=rundeck
    # rundeck.projectsStorageType=db
    # # BEGIN ANSIBLE MANAGED BLOCK (EMAIL)
    # grails.mail.host=localhost
    # grails.mail.port=25
    # grails.mail.default.from=rundeck@localhost
    # # END ANSIBLE MANAGED BLOCK (EMAIL)

    sudo tree -L 2 /etc/rundeck

    # /etc/rundeck
    # ├── admin.aclpolicy
    # ├── admin.aclpolicy.31371.2018-11-18@07:41:20~
    # ├── apitoken.aclpolicy
    # ├── apitoken.aclpolicy.31446.2018-11-18@07:41:20~
    # ├── cli-log4j.properties
    # ├── framework.properties
    # ├── jaas-crowd.conf
    # ├── jaas-loginmodule.conf
    # ├── log4j.properties
    # ├── profile
    # ├── project.properties
    # ├── realm.properties
    # ├── rundeck-config.properties
    # └── ssl
    #     └── ssl.properties
    # 
    # 1 directory, 14 files

    cd /var/lib/rundeck

    ls -lt

    # total 12
    # drwxrwxr-x. 7 rundeck rundeck  208 Nov 18 11:35 ods-project-quickstarters
    # drwxrwxr-x. 3 rundeck rundeck 4096 Nov 18 07:45 libext
    # drwxrwxr-x. 2 rundeck rundeck 4096 Nov 18 07:41 bootstrap
    # drw-r-xr-x. 2 rundeck rundeck   43 Nov 18 07:40 lib
    # drwxrwxr-x. 3 rundeck rundeck   17 Nov 18 07:40 var
    # drwxrwxr-x. 2 rundeck rundeck 4096 Nov 18 07:40 cli
    # drwxrwxr-x. 3 rundeck rundeck   20 Nov 18 07:40 exp
    # drwxrwxr-x. 2 rundeck rundeck    6 Apr 19  2017 data
    # drwxrwxr-x. 2 rundeck rundeck    6 Apr 19  2017 logs
    # drwxrwxr-x. 2 rundeck rundeck    6 Apr 19  2017 work

    tree -L 2 /var/lib/rundeck

    # /var/lib/rundeck
    # ├── bootstrap
    # │   ├── commons-codec-1.2.jar
    # │   ├── commons-httpclient-3.1.jar
    # │   ├── commons-logging-1.1.1.jar
    # │   ├── jaas-jetty-crowd-1.0.jar
    # │   ├── javax.servlet-3.0.0.v201112011016.jar
    # │   ├── jersey-apache-client-1.19.3.jar
    # │   ├── jersey-client-1.19.3.jar
    # │   ├── jersey-core-1.19.3.jar
    # │   ├── jetty-all-9.0.7.v20131107.jar
    # │   ├── jetty-http-9.0.7.v20131107.jar
    # │   ├── jetty-io-9.0.7.v20131107.jar
    # │   ├── jetty-jaas-9.0.7.v20131107.jar
    # │   ├── jetty-security-9.0.7.v20131107.jar
    # │   ├── jetty-server-9.0.7.v20131107.jar
    # │   ├── jetty-util-9.0.7.v20131107.jar
    # │   ├── jna-3.2.2.jar
    # │   ├── jsr311-api-1.1.1.jar
    # │   ├── libpam4j-1.5.jar
    # │   ├── log4j-1.2.16.jar
    # │   ├── not-yet-commons-ssl-0.3.11.jar
    # │   ├── rundeck-jetty-server-2.8.2.jar
    # │   ├── slf4j-api-1.7.5.jar
    # │   └── slf4j-simple-1.7.5.jar
    # ├── cli
    # │   ├── ant-1.8.3.jar
    # │   ├── ant-jsch-1.8.3.jar
    # │   ├── ant-launcher-1.8.3.jar
    # │   ├── commons-beanutils-1.8.3.jar
    # │   ├── commons-cli-1.0.jar
    # │   ├── commons-codec-1.5.jar
    # │   ├── commons-collections-3.2.2.jar
    # │   ├── commons-httpclient-3.0.1.jar
    # │   ├── commons-lang-2.6.jar
    # │   ├── commons-logging-1.1.1.jar
    # │   ├── dom4j-1.6.1.jar
    # │   ├── guava-15.0.jar
    # │   ├── icu4j-2.6.1.jar
    # │   ├── jackson-annotations-2.5.3.jar
    # │   ├── jackson-core-2.5.3.jar
    # │   ├── jackson-databind-2.5.3.jar
    # │   ├── jaxen-1.1.jar
    # │   ├── jdom-1.0.jar
    # │   ├── jna-4.1.0.jar
    # │   ├── jna-platform-4.1.0.jar
    # │   ├── jsch-0.1.53.jar
    # │   ├── jsch.agentproxy.connector-factory-0.0.9.jar
    # │   ├── jsch.agentproxy.core-0.0.9.jar
    # │   ├── jsch.agentproxy.jsch-0.0.9.jar
    # │   ├── jsch.agentproxy.pageant-0.0.9.jar
    # │   ├── jsch.agentproxy.sshagent-0.0.9.jar
    # │   ├── jsch.agentproxy.usocket-jna-0.0.9.jar
    # │   ├── jsch.agentproxy.usocket-nc-0.0.9.jar
    # │   ├── log4j-1.2.17.jar
    # │   ├── rundeck-core-2.8.2.jar
    # │   ├── rundeck-storage-api-2.8.2.jar
    # │   ├── rundeck-storage-conf-2.8.2.jar
    # │   ├── rundeck-storage-data-2.8.2.jar
    # │   ├── snakeyaml-1.9.jar
    # │   ├── xercesImpl-2.11.0.jar
    # │   ├── xml-apis-1.4.01.jar
    # │   └── xom-1.0.jar
    # ├── data
    # ├── exp
    # │   └── webapp
    # ├── lib
    # │   └── postgresql-9.3-1103.jdbc3.jar
    # ├── libext
    # │   ├── cache
    # │   ├── rundeck-copyfile-plugin-2.8.2.jar
    # │   ├── rundeck-flow-control-plugin-2.8.2.jar
    # │   ├── rundeck-git-plugin-2.8.2.jar
    # │   ├── rundeck-jasypt-encryption-plugin-2.8.2.jar
    # │   ├── rundeck-job-state-plugin-2.8.2.jar
    # │   ├── rundeck-localexec-plugin-2.8.2.jar
    # │   ├── rundeck-orchestrator-plugin-2.8.2.jar
    # │   ├── rundeck-script-plugin-2.8.2.jar
    # │   ├── rundeck-source-refresh-plugin-2.8.2.jar
    # │   └── rundeck-stub-plugin-2.8.2.jar
    # ├── logs
    # ├── ods-project-quickstarters
    # │   ├── boilerplates
    # │   ├── CHANGELOG.md
    # │   ├── jenkins-slaves
    # │   ├── LICENSE
    # │   ├── logfile
    # │   ├── ocp-templates
    # │   ├── README.md
    # │   └── rundeck-jobs
    # ├── var
    # │   └── tmp
    # └── work
    # 
    # 17 directories, 75 files

    ps -ef | grep rundeck

    # root      2005     1  0 Nov18 ?        00:00:00 runuser -s /bin/bash -l rundeck -c java -Djava.security.auth.login.config=/etc/rundeck/jaas-crowd.conf         -Dloginmodule.name=crowd            -Drdeck.config=/etc/rundeck            -Drundeck.server.configDir=/etc/rundeck            -Dserver.datastore.path=/var/lib/rundeck/data/rundeck            -Drundeck.server.serverDir=/var/lib/rundeck            -Drdeck.projects=/var/lib/rundeck/projects            -Drdeck.runlogs=/var/lib/rundeck/logs            -Drundeck.config.location=/etc/rundeck/rundeck-config.properties            -Djava.io.tmpdir=/tmp/rundeck            -Drundeck.server.workDir=/tmp/rundeck            -Dserver.http.port=4440  -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -Dserver.web.context=/rundeck  -cp /var/lib/rundeck/bootstrap/javax.servlet-3.0.0.v201112011016.jar:/var/lib/rundeck/bootstrap/jetty-all-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-http-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-io-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-jaas-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-security-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-server-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-util-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jna-3.2.2.jar:/var/lib/rundeck/bootstrap/libpam4j-1.5.jar:/var/lib/rundeck/bootstrap/log4j-1.2.16.jar:/var/lib/rundeck/bootstrap/not-yet-commons-ssl-0.3.11.jar:/var/lib/rundeck/bootstrap/rundeck-jetty-server-2.8.2.jar:/var/lib/rundeck/bootstrap/commons-codec-1.2.jar:/var/lib/rundeck/bootstrap/commons-httpclient-3.1.jar:/var/lib/rundeck/bootstrap/commons-logging-1.1.1.jar:/var/lib/rundeck/bootstrap/jaas-jetty-crowd-1.0.jar:/var/lib/rundeck/bootstrap/jersey-apache-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-core-1.19.3.jar:/var/lib/rundeck/bootstrap/jsr311-api-1.1.1.jar:/var/lib/rundeck/bootstrap/slf4j-api-1.7.5.jar:/var/lib/rundeck/bootstrap/slf4j-simple-1.7.5.jar com.dtolabs.rundeck.RunServer /var/lib/rundeck
    # rundeck   2009  2005  0 Nov18 ?        00:03:40 java -Djava.security.auth.login.config=/etc/rundeck/jaas-crowd.conf -Dloginmodule.name=crowd -Drdeck.config=/etc/rundeck -Drundeck.server.configDir=/etc/rundeck -Dserver.datastore.path=/var/lib/rundeck/data/rundeck -Drundeck.server.serverDir=/var/lib/rundeck -Drdeck.projects=/var/lib/rundeck/projects -Drdeck.runlogs=/var/lib/rundeck/logs -Drundeck.config.location=/etc/rundeck/rundeck-config.properties -Djava.io.tmpdir=/tmp/rundeck -Drundeck.server.workDir=/tmp/rundeck -Dserver.http.port=4440 -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -Dserver.web.context=/rundeck -cp /var/lib/rundeck/bootstrap/javax.servlet-3.0.0.v201112011016.jar:/var/lib/rundeck/bootstrap/jetty-all-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-http-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-io-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-jaas-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-security-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-server-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-util-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jna-3.2.2.jar:/var/lib/rundeck/bootstrap/libpam4j-1.5.jar:/var/lib/rundeck/bootstrap/log4j-1.2.16.jar:/var/lib/rundeck/bootstrap/not-yet-commons-ssl-0.3.11.jar:/var/lib/rundeck/bootstrap/rundeck-jetty-server-2.8.2.jar:/var/lib/rundeck/bootstrap/commons-codec-1.2.jar:/var/lib/rundeck/bootstrap/commons-httpclient-3.1.jar:/var/lib/rundeck/bootstrap/commons-logging-1.1.1.jar:/var/lib/rundeck/bootstrap/jaas-jetty-crowd-1.0.jar:/var/lib/rundeck/bootstrap/jersey-apache-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-core-1.19.3.jar:/var/lib/rundeck/bootstrap/jsr311-api-1.1.1.jar:/var/lib/rundeck/bootstrap/slf4j-api-1.7.5.jar:/var/lib/rundeck/bootstrap/slf4j-simple-1.7.5.jar com.dtolabs.rundeck.RunServer /var/lib/rundeck


<a id="org470ad84"></a>

## Docker

    cd /var/lib/docker

    sudo ls -lt

    # total 0
    # drwx------. 4 root root 92 Nov 18 07:44 buildkit
    # drwx------. 2 root root 24 Nov 18 07:44 builder
    # drwx------. 2 root root  6 Nov 18 07:44 swarm
    # drwx------. 3 root root 40 Nov 18 07:44 overlay2
    # drwxr-x---. 3 root root 19 Nov 18 07:44 network
    # drwx------. 2 root root  6 Nov 18 07:44 trust
    # drwx------. 3 root root 22 Nov 18 07:44 image
    # drwx------. 2 root root 25 Nov 18 07:44 volumes
    # drwx------. 4 root root 32 Nov 18 07:44 plugins
    # drwx------. 2 root root  6 Nov 18 07:44 containers
    # drwx------. 2 root root  6 Nov 18 07:44 runtimes
    # drwx------. 2 root root  6 Nov 18 07:44 tmp
    # drwx------. 3 root root 20 Nov 18 07:44 containerd


<a id="orgb530457"></a>

### Nexus3


<a id="orgb0b5fce"></a>

### SonarQube


<a id="orgb7bb123"></a>

#### SonarQube-PostGreSQL


<a id="org106f383"></a>

## PostGreSQL

    sudo ls -lisat /var/lib/pgsql

    # total 8
    # 67146824 4 drwxr-xr-x. 36 root     root     4096 Nov 18 07:44 ..
    # 33577588 0 drwx------.  4 postgres postgres   54 Nov 16 10:54 .
    # 67588032 0 drwx------.  3 postgres postgres   17 Nov 16 10:54 .ansible
    # 67158261 0 drwx------.  4 postgres postgres   51 Nov 16 10:53 9.4
    # 33577590 4 -rwx------.  1 postgres postgres  267 Nov 16 10:53 .bash_profile

    sudo tree -L 2 /var/lib/pgsql/9.4

    # /var/lib/pgsql/9.4
    # ├── backups
    # ├── data
    # │   ├── base
    # │   ├── global
    # │   ├── log
    # │   ├── pg_clog
    # │   ├── pg_dynshmem
    # │   ├── pg_hba.conf
    # │   ├── pg_ident.conf
    # │   ├── pg_log
    # │   ├── pg_logical
    # │   ├── pg_multixact
    # │   ├── pg_notify
    # │   ├── pg_replslot
    # │   ├── pg_serial
    # │   ├── pg_snapshots
    # │   ├── pg_stat
    # │   ├── pg_stat_tmp
    # │   ├── pg_subtrans
    # │   ├── pg_tblspc
    # │   ├── pg_twophase
    # │   ├── PG_VERSION
    # │   ├── pg_xlog
    # │   ├── postgresql.auto.conf
    # │   ├── postgresql.conf
    # │   ├── postmaster.opts
    # │   └── postmaster.pid
    # └── initdb.log
    # 
    # 20 directories, 8 files


<a id="orge023282"></a>

## Processes

    ps -ef | grep java | grep -v grep | sort

    # atlbitb+ 11135     1  0 Nov18 ?        00:10:07 /usr/java/jdk1.8.0_192-amd64/jre/bin/java -Djava.util.logging.config.file=/opt/atlassian/bitbucket/4.14.3/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms512m -Xmx768m -XX:+UseG1GC -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Datlassian.standalone=BITBUCKET -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true -Dorg.apache.catalina.connector.Response.ENFORCE_ENCODING_IN_GET_WRITER=false -Dcom.sun.jndi.ldap.connect.pool.protocol=plain ssl -Dcom.sun.jndi.ldap.connect.pool.authentication=none simple DIGEST-MD5 -Djava.library.path=/opt/atlassian/bitbucket/4.14.3/lib/native:/srv/atlassian/bitbucket/lib/native -Dbitbucket.home=/srv/atlassian/bitbucket -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Djava.endorsed.dirs=/opt/atlassian/bitbucket/4.14.3/endorsed -classpath /opt/atlassian/bitbucket/4.14.3/bin/bitbucket-bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/bootstrap.jar:/opt/atlassian/bitbucket/4.14.3/bin/tomcat-juli.jar -Dcatalina.base=/opt/atlassian/bitbucket/4.14.3 -Dcatalina.home=/opt/atlassian/bitbucket/4.14.3 -Djava.io.tmpdir=/opt/atlassian/bitbucket/4.14.3/temp com.atlassian.stash.internal.catalina.startup.Bootstrap start
    # atlbitb+ 23944     1  0 Nov16 ?        00:06:20 /usr/java/jdk1.8.0_192-amd64/jre/bin/java -Xms256m -Xmx1g -Djava.awt.headless=true -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError -XX:+DisableExplicitGC -Dfile.encoding=UTF-8 -Djna.nosys=true -Des.path.home=/opt/atlassian/bitbucket/4.14.3/elasticsearch -cp /opt/atlassian/bitbucket/4.14.3/elasticsearch/lib/elasticsearch-2.3.1.jar:/opt/atlassian/bitbucket/4.14.3/elasticsearch/lib/* org.elasticsearch.bootstrap.Elasticsearch start -d -p /srv/atlassian/bitbucket/shared/search/elasticsearch.pid -Dpath.conf=/srv/atlassian/bitbucket/shared/search -Dpath.logs=/srv/atlassian/bitbucket/log/search -Dpath.data=/srv/atlassian/bitbucket/shared/search/data
    # conflue+ 25695     1  0 Nov16 ?        00:22:26 /opt/atlassian/confluence/jre//bin/java -Djava.util.logging.config.file=/opt/atlassian/confluence/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dconfluence.context.path= -Datlassian.plugins.startup.options= -Dorg.apache.tomcat.websocket.DEFAULT_BUFFER_SIZE=32768 -Dsynchrony.enable.xhr.fallback=true -Datlassian.plugins.enable.wait=300 -Djava.awt.headless=true -XX:G1ReservePercent=20 -Xloggc:/opt/atlassian/confluence/logs/gc-2018-11-16_14-53-00.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=2M -XX:-PrintGCDetails -XX:+PrintGCDateStamps -XX:-PrintTenuringDistribution -Djava.endorsed.dirs=/opt/atlassian/confluence/endorsed -classpath /opt/atlassian/confluence/bin/bootstrap.jar:/opt/atlassian/confluence/bin/tomcat-juli.jar -Dcatalina.base=/opt/atlassian/confluence -Dcatalina.home=/opt/atlassian/confluence -Djava.io.tmpdir=/opt/atlassian/confluence/temp org.apache.catalina.startup.Bootstrap start
    # conflue+ 26528 25695  0 Nov16 ?        00:21:38 /opt/atlassian/confluence/jre/bin/java -classpath /opt/atlassian/confluence/temp/0.3.1-release-confluence_6.1-e20fb944.jar:/opt/atlassian/confluence/confluence/WEB-INF/lib/postgresql-9.4.1212.jar -Xss2048k -Xmx1g synchrony.core sql
    # crowd    13216     1  0 Nov16 ?        00:25:14 /usr/bin/java -Djava.util.logging.config.file=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms128m -Xmx512m -Dfile.encoding=UTF-8 -Djdk.tls.ephemeralDHKeySize=2048 -Djava.endorsed.dirs=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/endorsed -classpath /opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/bootstrap.jar:/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/bin/tomcat-juli.jar -Dcatalina.base=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat -Dcatalina.home=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat -Djava.io.tmpdir=/opt/atlassian/atlassian-crowd-2.11.2/apache-tomcat/temp org.apache.catalina.startup.Bootstrap start
    # jira     26686     1  0 Nov16 ?        00:11:27 /opt/atlassian/jira/jre//bin/java -Djava.util.logging.config.file=/opt/atlassian/jira/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms384m -Xmx4096m -Djava.awt.headless=true -Datlassian.standalone=JIRA -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true -Dorg.dom4j.factory=com.atlassian.core.xml.InterningDocumentFactory -Dfile.encoding=UTF-8 -XX:+PrintGCDateStamps -XX:-OmitStackTraceInFastThrow -Datlassian.plugins.startup.options= -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -classpath /opt/atlassian/jira/bin/bootstrap.jar:/opt/atlassian/jira/bin/tomcat-juli.jar -Dcatalina.base=/opt/atlassian/jira -Dcatalina.home=/opt/atlassian/jira -Djava.io.tmpdir=/opt/atlassian/jira/temp org.apache.catalina.startup.Bootstrap start
    # root      2005     1  0 Nov18 ?        00:00:00 runuser -s /bin/bash -l rundeck -c java -Djava.security.auth.login.config=/etc/rundeck/jaas-crowd.conf         -Dloginmodule.name=crowd            -Drdeck.config=/etc/rundeck            -Drundeck.server.configDir=/etc/rundeck            -Dserver.datastore.path=/var/lib/rundeck/data/rundeck            -Drundeck.server.serverDir=/var/lib/rundeck            -Drdeck.projects=/var/lib/rundeck/projects            -Drdeck.runlogs=/var/lib/rundeck/logs            -Drundeck.config.location=/etc/rundeck/rundeck-config.properties            -Djava.io.tmpdir=/tmp/rundeck            -Drundeck.server.workDir=/tmp/rundeck            -Dserver.http.port=4440  -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -Dserver.web.context=/rundeck  -cp /var/lib/rundeck/bootstrap/javax.servlet-3.0.0.v201112011016.jar:/var/lib/rundeck/bootstrap/jetty-all-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-http-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-io-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-jaas-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-security-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-server-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-util-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jna-3.2.2.jar:/var/lib/rundeck/bootstrap/libpam4j-1.5.jar:/var/lib/rundeck/bootstrap/log4j-1.2.16.jar:/var/lib/rundeck/bootstrap/not-yet-commons-ssl-0.3.11.jar:/var/lib/rundeck/bootstrap/rundeck-jetty-server-2.8.2.jar:/var/lib/rundeck/bootstrap/commons-codec-1.2.jar:/var/lib/rundeck/bootstrap/commons-httpclient-3.1.jar:/var/lib/rundeck/bootstrap/commons-logging-1.1.1.jar:/var/lib/rundeck/bootstrap/jaas-jetty-crowd-1.0.jar:/var/lib/rundeck/bootstrap/jersey-apache-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-core-1.19.3.jar:/var/lib/rundeck/bootstrap/jsr311-api-1.1.1.jar:/var/lib/rundeck/bootstrap/slf4j-api-1.7.5.jar:/var/lib/rundeck/bootstrap/slf4j-simple-1.7.5.jar com.dtolabs.rundeck.RunServer /var/lib/rundeck
    # rundeck   2009  2005  0 Nov18 ?        00:03:52 java -Djava.security.auth.login.config=/etc/rundeck/jaas-crowd.conf -Dloginmodule.name=crowd -Drdeck.config=/etc/rundeck -Drundeck.server.configDir=/etc/rundeck -Dserver.datastore.path=/var/lib/rundeck/data/rundeck -Drundeck.server.serverDir=/var/lib/rundeck -Drdeck.projects=/var/lib/rundeck/projects -Drdeck.runlogs=/var/lib/rundeck/logs -Drundeck.config.location=/etc/rundeck/rundeck-config.properties -Djava.io.tmpdir=/tmp/rundeck -Drundeck.server.workDir=/tmp/rundeck -Dserver.http.port=4440 -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -Dserver.web.context=/rundeck -cp /var/lib/rundeck/bootstrap/javax.servlet-3.0.0.v201112011016.jar:/var/lib/rundeck/bootstrap/jetty-all-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-http-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-io-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-jaas-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-security-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-server-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jetty-util-9.0.7.v20131107.jar:/var/lib/rundeck/bootstrap/jna-3.2.2.jar:/var/lib/rundeck/bootstrap/libpam4j-1.5.jar:/var/lib/rundeck/bootstrap/log4j-1.2.16.jar:/var/lib/rundeck/bootstrap/not-yet-commons-ssl-0.3.11.jar:/var/lib/rundeck/bootstrap/rundeck-jetty-server-2.8.2.jar:/var/lib/rundeck/bootstrap/commons-codec-1.2.jar:/var/lib/rundeck/bootstrap/commons-httpclient-3.1.jar:/var/lib/rundeck/bootstrap/commons-logging-1.1.1.jar:/var/lib/rundeck/bootstrap/jaas-jetty-crowd-1.0.jar:/var/lib/rundeck/bootstrap/jersey-apache-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-client-1.19.3.jar:/var/lib/rundeck/bootstrap/jersey-core-1.19.3.jar:/var/lib/rundeck/bootstrap/jsr311-api-1.1.1.jar:/var/lib/rundeck/bootstrap/slf4j-api-1.7.5.jar:/var/lib/rundeck/bootstrap/slf4j-simple-1.7.5.jar com.dtolabs.rundeck.RunServer /var/lib/rundeck

    ps -ef | grep sql | grep -v grep

    # postgres  7678     1  0 Nov16 ?        00:01:10 /usr/pgsql-9.4/bin/postgres -D /var/lib/pgsql/9.4/data
    # conflue+ 26528 25695  0 Nov16 ?        00:21:39 /opt/atlassian/confluence/jre/bin/java -classpath /opt/atlassian/confluence/temp/0.3.1-release-confluence_6.1-e20fb944.jar:/opt/atlassian/confluence/confluence/WEB-INF/lib/postgresql-9.4.1212.jar -Xss2048k -Xmx1g synchrony.core sql


<a id="org1eed050"></a>

# ToDo


<a id="org96aacfa"></a>

## Configuring Minishift

    export MINISHIFT_HOME="D:\misc\vagrant\opendevstack\.minishift"

    cd /misc/vagrant/opendevstack/.minishift


<a id="orga88857b"></a>

## Using Minishift - An OpenShift Origin All-in-One VM

    minishift version

    # minishift v1.26.1+1e20f27

    minishift config set vm-driver virtualbox

    # No Minishift instance exists. New 'vm-driver' setting will be applied on next 'minishift start'

This command creates the following directory structure:

    tree -a -L 3 /misc/vagrant/opendevstack/.minishift

    # /misc/vagrant/opendevstack/.minishift
    # ├── addons
    # │   ├── admin-user
    # │   │   ├── admin-user.addon
    # │   │   └── admin-user.addon.remove
    # │   ├── anyuid
    # │   │   ├── anyuid.addon
    # │   │   └── anyuid.addon.remove
    # │   ├── che
    # │   │   ├── che.addon
    # │   │   ├── che.addon.remove
    # │   │   ├── README.md
    # │   │   └── templates
    # │   ├── htpasswd-identity-provider
    # │   │   ├── htpasswd-identity-provider.addon
    # │   │   ├── htpasswd-identity-provider.addon.remove
    # │   │   └── README.adoc
    # │   ├── registry-route
    # │   │   └── registry-route.addon
    # │   └── xpaas
    # │       ├── v3.10
    # │       ├── v3.9
    # │       └── xpaas.addon
    # ├── cache
    # │   ├── images
    # │   ├── iso
    # │   └── oc
    # ├── certs
    # ├── config
    # │   ├── allinstances.json
    # │   ├── config.json
    # │   ├── global.json
    # │   └── minishift.json
    # ├── logs
    # ├── machines
    # │   └── minishift-state.json
    # └── tmp
    # 
    # 19 directories, 17 files

    cat /misc/vagrant/opendevstack/.minishift/config/config.json

    # {
    #     "vm-driver": "virtualbox"
    # }

Before you start up Minishift with the **minishift start** command you will have to
modify the `config.json` file

    cat > /misc/vagrant/opendevstack/.minishift/config/config.json <<-"_EOF"
    {
        "cpus": 2,
        "memory": "8192",
        "openshift-version": "v3.9.0",
        "disk-size": "40GB",
        "vm-driver": "virtualbox"
    }
    _EOF

To avoid the following error during startup

    # Could not set oc CLI context for 'minishift' profile: Error during setting 'minishift' as active profile: The specified path to the kube config 'D:\misc\vagrant\opendevstack\.minishift\machines\minishift_kubeconfig' does not exist

we make sure that the file **minishift\_kubeconfig** exists.

    touch /misc/vagrant/opendevstack/.minishift/machines/minishift_kubeconfig

    minishift start

    # -- Starting profile 'minishift'
    # -- Check if deprecated options are used ... OK
    # -- Checking if https://github.com is reachable ... OK
    # -- Checking if requested OpenShift version 'v3.9.0' is valid ... OK
    # -- Checking if requested OpenShift version 'v3.9.0' is supported ... FAIL
    #    Minishift does not support OpenShift version v3.9.0. You need to use a version >= v3.10.0

    cat > /misc/vagrant/opendevstack/.minishift/config/config.json <<-"_EOF"
    {
        "cpus": 2,
        "memory": "8192",
        "openshift-version": "v3.10.0",
        "disk-size": "40GB",
        "vm-driver": "virtualbox"
    }
    _EOF


<a id="org37597a5"></a>

## Problems when starting

    # -- Starting profile 'minishift'
    # -- Check if deprecated options are used ... OK
    # -- Checking if https://github.com is reachable ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is valid ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is supported ... OK
    # -- Checking if requested hypervisor 'virtualbox' is supported on this platform ... OK
    # -- Checking if VirtualBox is installed ... OK
    # -- Checking the ISO URL ... OK
    # -- Downloading OpenShift binary 'oc' version 'v3.10.0'
    #  23.94 MiB / 23.94 MiB  100.00% 0s-- Downloading OpenShift v3.10.0 checksums ... OK
    # -- Checking if provided oc flags are supported ... OK
    # -- Starting the OpenShift cluster using 'virtualbox' hypervisor ...
    # -- Minishift VM will be configured with ...
    #    Memory:    8 GB
    #    vCPUs :    2
    #    Disk size: 40 GB
    # 
    #    Downloading ISO 'https://github.com/minishift/minishift-centos-iso/releases/download/v1.13.0/minishift-centos7.iso'
    #  346.00 MiB / 346.00 MiB  100.00% 0s
    # -- Starting Minishift VM ......... FAIL E1118 09:33:24.629309     856 start.go:491] Error starting the VM: Error creating new host: Error attempting to get plugin server address for RPC: Failed to dial the plugin server in 10s. Retrying.
    # Error starting the VM: Error creating new host: Error attempting to get plugin server address for RPC: Failed to dial the plugin server in 10s

    minishift start

    # -- Starting profile 'minishift'
    # -- Check if deprecated options are used ... OK
    # -- Checking if https://github.com is reachable ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is valid ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is supported ... OK
    # -- Checking if requested hypervisor 'virtualbox' is supported on this platform ... OK
    # -- Checking if VirtualBox is installed ... OK
    # -- Checking the ISO URL ... OK
    # -- Checking if provided oc flags are supported ... OK
    # -- Starting the OpenShift cluster using 'virtualbox' hypervisor ...
    # -- Minishift VM will be configured with ...
    #    Memory:    8 GB
    #    vCPUs :    2
    #    Disk size: 40 GB
    # -- Starting Minishift VM ................. FAIL E1118 09:37:19.414190   12424 start.go:491] Error starting the VM: Error creating the VM. Error creating machine: Error in driver during machine creation: C:\Program Files\Oracle\VirtualBox\VBoxManage.exe storagectl minishift --name SATA --add sata --hostiocache on failed:
    # VBoxManage.exe: error: Storage controller named 'SATA' already exists
    # VBoxManage.exe: error: Details: code VBOX_E_OBJECT_IN_USE (0x80bb000c), component SessionMachine, interface IMachine, callee IUnknown
    # VBoxManage.exe: error: Context: "AddStorageController(Bstr(pszCtl).raw(), StorageBus_SATA, ctl.asOutParam())" at line 1080 of file VBoxManageStorageController.cpp
    # . Retrying.
    # Error starting the VM: Error creating the VM. Error creating machine: Error in driver during machine creation: C:\Program Files\Oracle\VirtualBox\VBoxManage.exe storagectl minishift --name SATA --add sata --hostiocache on failed:
    # VBoxManage.exe: error: Storage controller named 'SATA' already exists
    # VBoxManage.exe: error: Details: code VBOX_E_OBJECT_IN_USE (0x80bb000c), component SessionMachine, interface IMachine, callee IUnknown
    # VBoxManage.exe: error: Context: "AddStorageController(Bstr(pszCtl).raw(), StorageBus_SATA, ctl.asOutParam())" at line 1080 of file VBoxManageStorageController.cpp

    minishift start

    # -- Starting profile 'minishift'
    # -- Check if deprecated options are used ... OK
    # -- Checking if https://github.com is reachable ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is valid ... OK
    # -- Checking if requested OpenShift version 'v3.10.0' is supported ... OK
    # -- Checking if requested hypervisor 'virtualbox' is supported on this platform ... OK
    # -- Checking if VirtualBox is installed ... OK
    # -- Checking the ISO URL ... OK
    # -- Checking if provided oc flags are supported ... OK
    # -- Starting the OpenShift cluster using 'virtualbox' hypervisor ...
    # -- Starting Minishift VM ...... FAIL E1118 09:43:23.909778   20532 start.go:491] Error starting the VM: Error starting stopped host: Checking if hardware virtualization is enabled failed: open D:\misc\vagrant\opendevstack\.minishift\machines\minishift\minishift\Logs\VBox.log: The system cannot find the path specified.. Retrying.
    # Error starting the VM: Error starting stopped host: Checking if hardware virtualization is enabled failed: open D:\misc\vagrant\opendevstack\.minishift\machines\minishift\minishift\Logs\VBox.log: The system cannot find the path specified.

    minishift stop

    # Stopping the OpenShift cluster...
    # Cluster stopped.

