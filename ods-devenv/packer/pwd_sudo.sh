#!/usr/bin/env bash
# give wheel their pwd back
sudo chattr -i /etc/sudoers
sudo sed -i '0,/%wheel[[:space:]]*ALL=(ALL)[[:space:]]*NOPASSWD:[[:space:]]*ALL/{s||%wheel  ALL=(ALL)       ALL|}' /etc/sudoers
