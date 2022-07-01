#pragma once

#include <string>

namespace Status::StatusGo::Wallet {

/*! \brief Unique wallet account entity
 */
struct WalletToken
{
    std::string name;
    std::string address;
    std::string symbol;
    int decimals;
    bool hasIcon;
    std::string color;
    bool isCustom;
    float balance;
    float currencyBalance;
};

}