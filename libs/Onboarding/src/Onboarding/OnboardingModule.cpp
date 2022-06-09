#include "OnboardingModule.h"

#include "Accounts/Service.h"

#include <Keychain/ServiceInterface.h>
#include <Onboarding/Accounts/LocalAccountSettings.h>

#include <QStandardPaths>

#include <filesystem>

namespace Accounts = Status::Accounts;

namespace fs = std::filesystem;

namespace Status::Onboarding {

// Temporary workaround for the login POC. TODO refactor it
class DummyLocalAccountsSettings: public Accounts::LocalAccountSettings
{
public:
    Accounts::StoreToKeychainOptions getStoreToKeychain() const override {
        return Accounts::Never;
    }
    void setStoreToKeychain(const QString&) override {}
    void removeStoreToKeychain() override {}
    QString isKeycardEnabled() const override {
        return u""_qs;
    }
    void setKeycardEnabled(bool) const override {}
};

class DummyServiceInterface: public Keychain::ServiceInterface
{
public:
    void storePassword(const QString&, const QString&) {};
    void tryToObtainPassword(const QString&) {};
    void subscribe(std::weak_ptr<Keychain::Listener>) {};
};


OnboardingModule::OnboardingModule(QObject *parent)
    : QObject{parent}
    , m_accountsService(std::make_shared<Accounts::Service>())
{
    auto userConfigFolder = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation).toStdString();
    initWithUserDataPath(fs::path(userConfigFolder)/"cpp-dev");
}

OnboardingController* OnboardingModule::controller() const
{
    return m_controller.get();
}

void OnboardingModule::initWithUserDataPath(const fs::path &path)
{
    // Setup accounts
    try {
        auto result = m_accountsService->init(path);
        if(!result)
            throw std::runtime_error(std::string("Failed to initialize OnboadingService") + path.string());
        m_controller = std::make_shared<OnboardingController>(
                    m_accountsService,
                    std::make_shared<DummyServiceInterface>(),
                    std::make_shared<DummyLocalAccountsSettings>());
    } catch (const std::exception& e) {
        qWarning() << "Failed constructing the OnboardingController instance! Error: " << e.what();
    }
}

}
