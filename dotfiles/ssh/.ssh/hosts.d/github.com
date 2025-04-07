# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

Host github github.com
  HostName github.com
  IdentityFile ~/.ssh/keys.d/pigeonf@github.com.pub
