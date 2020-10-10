#!/usr/bin/env bash
######################################################
# Copyright (C) 2019 @Boos4721(Telegram and Github)  #
#                                                    #
# SPDX-License-Identifier: GPL-3.0-or-later          #
#                                                    #
######################################################
echo "Enable SSH ...."
# sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config; 
echo "AllowUsers root admin xiaolegun " >>  /etc/ssh/sshd_config
echo "Patch xiaolegun User...."
sudo adduser xiaolegun && sudo passwd 20071101
echo "Patch Boos To Root User…."
usermod -aG sudo xiaolegun
sudo /sbin/service sshd restart
echo "Done ...."
