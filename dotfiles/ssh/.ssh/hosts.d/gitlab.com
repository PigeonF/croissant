# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

Host gitlab gitlab.com
    HostName gitlab.com
    IdentityFile ~/.ssh/keys.d/pigeonf@gitlab.com.pub
