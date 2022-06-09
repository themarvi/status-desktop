#include <IOTestHelpers.h>

#include "ServiceMock.h"

#include <Constants.h>
#include <LocalAccountsSettings.h>
#include <ServiceInterfaceTestData.h>

#include <Core/Conversions.h>

#include <Onboarding/Accounts/Service.h>
#include <Onboarding/OnboardingController.h>

#include <QCoreApplication>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

namespace Testing = Status::Testing;
namespace Accounts = Status::Accounts;
namespace Onboarding = Status::Onboarding;

namespace fs = std::filesystem;

namespace Status::Testing {

static std::unique_ptr<Status::Accounts::Service> m_accountsServiceMock;

TEST(OnboardingModule, TestInitService)
{
    Testing::AutoCleanTempTestDir fusedTestFolder{test_info_->name()};
    auto testFolderPath = fusedTestFolder.tempFolder() / Constants::statusGoDataDirName;
    fs::create_directory(testFolderPath);
    auto accountsService = std::make_unique<Accounts::Service>();
    ASSERT_TRUE(accountsService->init(testFolderPath));
}

/// This integration end to end test is here for documentation purpose and until all the functionality is covered by unit-tests
/// \warning the test depends on IO and it is not deterministic, fast, focused or reliable and uses production classes. It is here for documenting only and dev process
/// \todo refactor into unit-tests with mocked interfaces
TEST(OnboardingModule, TestCreateAndLoginAccountEndToEnd)
{
    int argc = 1;
    std::string appName{"test"};
    char* args[] = {appName.data()};
    QCoreApplication dummyApp{argc, reinterpret_cast<char**>(args)};

    Testing::AutoCleanTempTestDir fusedTestFolder{test_info_->name()};
    auto testFolderPath = fusedTestFolder.tempFolder() / Constants::statusGoDataDirName;
    fs::create_directory(testFolderPath);

    // Setup accounts
    auto accountsService = std::make_shared<Accounts::Service>();
    auto result = accountsService->init(testFolderPath);
    ASSERT_TRUE(result);

    // TODO refactor and merge account creation events with login into Onboarding controller
    //
    // Create Login early to register and not miss onLoggedIn event signal from setupAccountAndLogin
    //

    int keychainCallCount = 0;
    // Setup login
    auto dummyKeychainService = std::make_shared<ServiceInterfaceTestData>(
                [&keychainCallCount](const QString& username, const QString& password) {
                    keychainCallCount++;
                },
                [&keychainCallCount](const QString& username) {
                    keychainCallCount++;
                },
                [&keychainCallCount](std::weak_ptr<Keychain::Listener> listener) {
                    keychainCallCount++;
                }
            );
    int settingsCallCount = 0;
    auto dummySettings = std::make_shared<LocalAccountsSettings>(
                // getStoreToKeychain
                [&settingsCallCount]() -> Accounts::StoreToKeychainOptions {
                    settingsCallCount++;
                    return Accounts::StoreToKeychainOptions::Never;
                },
                // setStoreToKeychain
                [&settingsCallCount](const QString&) {
                    settingsCallCount++;
                },
                // removeStoreToKeychain
                [&settingsCallCount]() {
                    settingsCallCount++;
                },
                // isKeycardEnabled
                [&settingsCallCount]() -> QString {
                    settingsCallCount++;
                    return QString();
                },
                // setKeycardEnabled
                [&settingsCallCount](bool) {
                    settingsCallCount++;
                }
            );

    // Beware, smartpointer is a requirement
    auto onboarding = std::make_shared<Onboarding::OnboardingController>(accountsService, dummyKeychainService, dummySettings);
    EXPECT_EQ(onboarding->getOpenedAccounts().count(), 0);

    int accountLoggedInCount = 0;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoggedIn, [&accountLoggedInCount]() {
        accountLoggedInCount++;
    });
    bool accountLoggedInError = false;
    QObject::connect(onboarding.get(), &Onboarding::OnboardingController::accountLoginError, [&accountLoggedInError]() {
        accountLoggedInError = true;
    });

    // Create Accounts
    auto genAccounts = accountsService->generatedAccounts();
    ASSERT_GT(genAccounts.size(), 0);

    ASSERT_FALSE(accountsService->isFirstTimeAccountLogin());

    constexpr auto accountName = "test_name";
    constexpr auto accountPassword = "test_pwd*";
    ASSERT_TRUE(accountsService->setupAccountAndLogin(genAccounts[0].id, accountPassword, accountName));

    ASSERT_TRUE(accountsService->isFirstTimeAccountLogin());
    ASSERT_TRUE(accountsService->getLoggedInAccount().isValid());
    ASSERT_TRUE(accountsService->getLoggedInAccount().name == accountName);
    ASSERT_FALSE(accountsService->getImportedAccount().isValid());

    EXPECT_EQ(keychainCallCount, 0);
    EXPECT_EQ(settingsCallCount, 0);

    using namespace std::chrono_literals;
    auto maxWaitTime = 2000ms;
    auto iterationSleepTime = 2ms;
    auto remainingIterations = maxWaitTime/iterationSleepTime;
    while (remainingIterations-- > 0 && accountLoggedInCount == 0) {
        std::this_thread::sleep_for(iterationSleepTime);

        QCoreApplication::sendPostedEvents();
    }

    // TODO: clarify why the logged in is called twice
    EXPECT_EQ(accountLoggedInCount, 1);
    EXPECT_FALSE(accountLoggedInError);
}

} // namespace
