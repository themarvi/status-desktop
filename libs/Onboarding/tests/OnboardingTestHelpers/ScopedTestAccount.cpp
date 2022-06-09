#include "ScopedTestAccount.h"

#include <Constants.h>
#include <LocalAccountsSettings.h>
#include <ServiceInterfaceTestData.h>

#include <IOTestHelpers.h>

#include <Core/Conversions.h>

#include <Onboarding/Accounts/Service.h>
#include <Onboarding/OnboardingController.h>

#include <QCoreApplication>

#include <IOTestHelpers.h>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

namespace Testing = Status::Testing;
namespace Accounts = Status::Accounts;
namespace Onboarding = Status::Onboarding;

namespace fs = std::filesystem;

namespace Status::Testing {

ScopedTestAccount::ScopedTestAccount(const std::string &tempTestSubfolderName)
    : m_fusedTestFolder{std::make_unique<AutoCleanTempTestDir>(tempTestSubfolderName)}
{
    int argc = 1;
    std::string appName{"test"};
    char* args[] = {appName.data()};
    m_app = std::make_unique<QCoreApplication>(argc, reinterpret_cast<char**>(args));

    m_testFolderPath = m_fusedTestFolder->tempFolder() / Constants::statusGoDataDirName;
    fs::create_directory(m_testFolderPath);

    // Setup accounts
    auto accountsService = std::make_shared<Accounts::Service>();
    auto result = accountsService->init(m_testFolderPath);
    if(!result)
        throw std::runtime_error("ScopedTestAccount - Failed to create temporary test account");

    // TODO refactor and merge account creation events with login into Onboarding controller
    //
    // Create Login early to register and not miss onLoggedIn event signal from setupAccountAndLogin
    //

    // Setup login
    auto dummyKeychainService = std::make_shared<ServiceInterfaceTestData>(
                [](const QString& username, const QString& password) {},
                [](const QString& username) {},
                [](std::weak_ptr<Keychain::Listener> listener) {}
            );
    auto dummySettings = std::make_shared<LocalAccountsSettings>(
                // getStoreToKeychain
                []() -> Accounts::StoreToKeychainOptions {
                    return Accounts::StoreToKeychainOptions::Never;
                },
                // setStoreToKeychain
                [](const QString&) {},
                // removeStoreToKeychain
                []() {},
                // isKeycardEnabled
                []() -> QString {
                    return QString();
                },
                // setKeycardEnabled
                [](bool) {}
            );

    // Beware, smartpointer is a requirement
    m_onboarding = std::make_shared<Onboarding::OnboardingController>(accountsService, dummyKeychainService, dummySettings);
    if(m_onboarding->getOpenedAccounts().count() != 0)
        throw std::runtime_error("ScopedTestAccount - already have opened account");

    int accountLoggedInCount = 0;
    QObject::connect(m_onboarding.get(), &Onboarding::OnboardingController::accountLoggedIn, [&accountLoggedInCount]() {
        accountLoggedInCount++;
    });
    bool accountLoggedInError = false;
    QObject::connect(m_onboarding.get(), &Onboarding::OnboardingController::accountLoginError, [&accountLoggedInError]() {
        accountLoggedInError = true;
    });

    // Create Accounts
    auto genAccounts = accountsService->generatedAccounts();
    if(genAccounts.count() == 0)
        throw std::runtime_error("ScopedTestAccount - missing generated accounts");

    if(accountsService->isFirstTimeAccountLogin())
        throw std::runtime_error("ScopedTestAccount - Service::isFirstTimeAccountLogin returned true");

    constexpr auto accountName = "test_name";
    constexpr auto accountPassword = "test_pwd*";
    if(!accountsService->setupAccountAndLogin(genAccounts[0].id, accountPassword, accountName))
        throw std::runtime_error("ScopedTestAccount - Service::setupAccountAndLogin failed");

    if(!accountsService->isFirstTimeAccountLogin())
        throw std::runtime_error("ScopedTestAccount - Service::isFirstTimeAccountLogin returned false");
    if(!accountsService->getLoggedInAccount().isValid())
        throw std::runtime_error("ScopedTestAccount - newly created account is not valid");
    if(accountsService->getLoggedInAccount().name != accountName)
        throw std::runtime_error("ScopedTestAccount - newly created account has a wrong name");
    processMessages(2000, [accountLoggedInCount]() {
        return accountLoggedInCount == 0;
    });
    if(accountLoggedInCount != 1)
        throw std::runtime_error("ScopedTestAccount - missing confirmation of account creation");
    if(accountLoggedInError)
        throw std::runtime_error("ScopedTestAccount - account loggedin error");
}

ScopedTestAccount::~ScopedTestAccount()
{

}

void ScopedTestAccount::processMessages(size_t maxWaitTimeMillis, std::function<bool()> shouldWaitUntilTimeout) {
    using namespace std::chrono_literals;
    std::chrono::milliseconds maxWaitTime{maxWaitTimeMillis};
    auto iterationSleepTime = 2ms;
    auto remainingIterations = maxWaitTime/iterationSleepTime;
    while (remainingIterations-- > 0 && shouldWaitUntilTimeout()) {
        std::this_thread::sleep_for(iterationSleepTime);

        QCoreApplication::sendPostedEvents();
    }
}

Onboarding::OnboardingController *ScopedTestAccount::onboardingController() const
{
    return m_onboarding.get();
}

}
