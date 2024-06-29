// SPDX-License-Identifier: GPL-2.0-or-later
// PDX-FileCopyrightText: 2022 illusion <vladyslav.makarov1@nure.ua>

#include "about.h"

KAboutData AboutType::aboutData() const
{
    return KAboutData::applicationData();
}
