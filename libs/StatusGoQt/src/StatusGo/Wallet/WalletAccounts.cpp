#include "WalletAccounts.h"

#include "Utils.h"

#include <nlohmann/json.hpp>

#include <iostream>

// for convenience
using json = nlohmann::json;

namespace Status::StatusGo::Wallet
{

std::vector<WalletAccount> getAccounts() {
    // or even nicer with a raw string literal
    json inJson = {
        {"jsonrpc", "2.0"},
        {"method", "accounts_getAccounts"},
        {"params", json::array()}
    };

    auto result = Utils::statusgoCallPrivateRPC(inJson.dump().c_str());
    auto outJson = json::parse(result);
    // TODO: check error in outJson and throw exception if failed or error
    // TODO: generalize extracting result to have on source of truth
    std::vector<WalletAccount> accounts;
    for(auto accJson : outJson["result"]) {
        // Define and parse WalletAccount
        accounts.push_back(WalletAccount());
    }
    return accounts;
}

}
