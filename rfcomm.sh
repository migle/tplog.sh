#!/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

sudo systemctl disable ModemManager
sudo rfcomm bind rfcomm0 00:04:3E:9C:6E:FF 1
# sudo rfcomm bind rfcomm1 20:16:07:05:92:08 1
