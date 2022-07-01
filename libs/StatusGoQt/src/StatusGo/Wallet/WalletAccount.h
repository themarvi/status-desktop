#pragma once

#include "WalletToken.h"

#include <vector>

namespace Status::StatusGo::Wallet {

/*! \brief Unique wallet account entity
 */
struct WalletAccount
{
    std::string name;
    std::string address;
    std::string path;
    std::string color;
    std::string publicKey;
    std::string walletType;
    bool isWallet;
    bool isChat;
    std::vector<WalletToken> tokens;
};

using WalletAccounts = std::vector<WalletAccount>;

}