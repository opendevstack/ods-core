#!/usr/bin/env bash
# cp this file to /usr/local/sbin/fixSsm.sh
# cp fix-ssm.service to /etc/systemd/system/fix-ssm.service
# sudo systemctl daemon-reload
# sudo systemctl enable --now fix-ssm.service

set -eu

function restart_amazon_ssm() {
    sudo systemctl restart amazon-ssm-agent.service
}

function setup_dnsmasq() {
    echo "Setting up dnsmasq DNS service"
    local dnsmasq_conf_path
    dnsmasq_conf_path="/etc/dnsmasq.conf"

    # tear down old running dnsmasq instances
    local job_id
    for job_id in $(ps -ef | grep dnsmasq | grep -v grep | grep -v setup_dnsmasq | awk -v col=2 '{print $2}')
    do
        sudo kill -9 "${job_id}" || true
    done

    if ! >/dev/null command -v dnsmasq
    then
        sudo yum install -y dnsmasq
    fi

    sudo systemctl start dnsmasq
    sleep 10
    if ! sudo systemctl status dnsmasq | grep -q active
    then
        echo "dnsmasq startup appears to have failed."
        exit
    else
        echo "dnsmasq service up and running"
    fi

    # if script runs for the 2nd time on a machine, backup dnsmasq.conf from orig
    if [[ -f "${dnsmasq_conf_path}.orig" ]]
    then
        sudo cp "${dnsmasq_conf_path}.orig" "${dnsmasq_conf_path}"
    else
        sudo cp "${dnsmasq_conf_path}" "${dnsmasq_conf_path}.orig"
    fi

    sudo sed -i "s|#domain-needed|domain-needed|" "${dnsmasq_conf_path}"
    sudo sed -i "s|#bogus-priv|bogus-priv|" "${dnsmasq_conf_path}"
    # might also want to add 172.31.0.2 as forward name server
    # sudo sed -i "/#server=\/localnet\/192.168.0.1/a server=172.31.0.2\nserver=8.8.8.8\nserver=8.8.4.4" "${dnsmasq_conf_path}"
    sudo sed -i "/#server=\/localnet\/192.168.0.1/a server=8.8.8.8\nserver=8.8.4.4" "${dnsmasq_conf_path}"
    
    local public_hostname
    public_hostname=$(hostname -I | awk '{print $1}')
    sudo sed -i "/#address=\/double-click.net\/127.0.0.1/a address=\/odsbox.lan\/${public_hostname}\naddress=\/odsbox.lan\/172.17.0.1\naddress=\/odsbox.lan\/127.0.0.1" "${dnsmasq_conf_path}"
    sudo sed -i "s|#listen-address=.*$|listen-address=::1,127.0.0.1,${public_hostname}|" "${dnsmasq_conf_path}"
    sudo sed -i "s|#domain=thekelleys.org.uk|domain=odsbox.lan|" "${dnsmasq_conf_path}"
    echo "172.30.1.1     docker-registry.default.svc" | sudo tee -a /etc/hosts

    # dnsmasq logs on stderr (?!)
    if !  2>&1 dnsmasq --test | grep -q "dnsmasq: syntax check OK."
    then
        echo "dnsmasq configuration failed. Please check ${dnsmasq_conf_path} and compare with ${dnsmasq_conf_path}.orig"
    else
        echo "dnsmasq is ok with configuration changes."
    fi

    sudo chattr -i /etc/resolv.conf
    sudo sed -i "s|nameserver .*$|nameserver ${public_hostname}|" /etc/resolv.conf
    
    while ! grep "${public_hostname}" /etc/resolv.conf
    do
        echo "WARN: could not write nameserver ${public_hostname} to /etc/resolv.conf"
        sleep 1
    done
    
    sudo chattr +i /etc/resolv.conf
    sudo systemctl restart dnsmasq.service
    sudo systemctl enable --now dnsmasq.service
}

setup_dnsmasq
restart_amazon_ssm
