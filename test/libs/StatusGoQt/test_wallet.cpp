#include <StatusGo/Wallet/WalletAccounts.h>

#include <Onboarding/Accounts/Service.h>

#include <StatusGo/SignalsManager.h>

#include <ScopedTestAccount.h>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

namespace Accounts = Status::Accounts;

namespace fs = std::filesystem;

/// \warning for now this namespace contains integration test to check the basic assumptions of status-go while building the C++ wrapper.
/// \warning the tests depend on IO and are not deterministic, fast, focused or reliable. They are here for validation only
/// \todo after status-go API coverage all the integration tests should go away and only test the thin wrapper code
namespace Status::Testing {

/// \todo fin a way to test the integration within a test environment. Also how about reusing an existing account
TEST(WalletModule, TestGetAccounts)
{
    bool nodeReady = false;
    QObject::connect(StatusGo::SignalsManager::instance(), &StatusGo::SignalsManager::nodeReady, [&nodeReady](const QString& error) {
        if(error.isEmpty()) {
            if(nodeReady) {
                nodeReady = false;
            } else
                nodeReady = true;
        }
    });

    ScopedTestAccount testAccount(test_info_->name());

    auto accounts = StatusGo::Wallet::getAccounts();
    ASSERT_EQ(accounts.size(), 2);

    // TODO: check that
    // one entry is wallet account
    // another is chat
}

} // namespace
