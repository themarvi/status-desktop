#pragma once

#include "Types.h"

#include <QtCore>
#include <QLatin1StringView>

namespace Status::StatusGo::General
{

RpcResponse<QJsonObject> initKeystore(const char* keystoreDir);

}
