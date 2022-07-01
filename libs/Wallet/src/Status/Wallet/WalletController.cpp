#include "WalletController.h"

namespace Status::Wallet {
        
WalletController::WalletController()
{
}

WalletController::~WalletController()
{
}

WalletController *WalletController::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    return new WalletController();
}

}