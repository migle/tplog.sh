#!/bin/bash
# Miguel Ramos, 2019.
# vim: set et fo+=t sw=2 sts=2 tw=100:

sudo systemctl disable ModemManager
sudo rfcomm bind 0 20:16:07:05:92:08 1
