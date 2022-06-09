#include "OnboardingController.h"

#include "NewAccountController.h"

#include "Accounts/LocalAccountSettings.h"

#include <StatusGo/SignalsManager.h>

namespace Status::Onboarding {

namespace StatusGo = Status::StatusGo;
namespace Accounts = Status::Accounts;

OnboardingController::OnboardingController(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                       std::shared_ptr<Keychain::ServiceInterface> keychainService,
                       std::shared_ptr<Accounts::LocalAccountSettings> settings)
    : QObject(nullptr)
    , m_accountsService(std::move(accountsService))
    , m_keychainService(std::move(keychainService))
    , m_settings(settings)
{
    QObject::connect(StatusGo::SignalsManager::instance(), &StatusGo::SignalsManager::nodeLogin, this, &OnboardingController::onLogin);
}

OnboardingController::~OnboardingController()
{
    // Here to move instatiation of unique_ptrs into this compilation unit
}

void OnboardingController::onLogin(const QString& error)
{
    if(error.isEmpty())
        emit accountLoggedIn();
    else
        emit accountLoginError(error);
}

QVector<Status::Accounts::AccountDto> OnboardingController::getOpenedAccounts() const
{
    return m_accountsService->openAndListAccounts();
}

Status::Accounts::AccountDto OnboardingController::getSelectedAccount() const
{
    auto openedAccounts = getOpenedAccounts();
    foreach(const auto& acc, openedAccounts)
    {
        if(acc.keyUid == m_selectedAccountKeyUid)
        {
            return acc;
        }
    }

    // TODO: For situations like this, should be better to return a std::optional instead?
    return Accounts::AccountDto();
}

void OnboardingController::setSelectedAccountKeyUid(const QString& keyUid)
{
    m_selectedAccountKeyUid = keyUid;

#ifdef Q_OS_MACOS
    // Dealing with Keychain is the MacOS only feature

    auto selectedAccount = getSelectedAccount();

    auto value = m_settings->getStoreToKeychain();
    if (value != Accounts::StoreToKeychainOptions::Store)
        return;

    m_keychainService->tryToObtainPassword(selectedAccount.name);
#endif
}

void OnboardingController::login(const QString& password)
{
    auto selectedAccount = OnboardingController::getSelectedAccount();
    auto error = m_accountsService->login(selectedAccount, password);
    if(!error.isEmpty())
    {
        emit accountLoginError(error);
    }
}

void OnboardingController::onKeychainManagerError(const QString& errorType, const int errorCode, const QString& errorDescription)
{
    // We are notifying user only about keychain errors.
    if (errorType == Keychain::ErrorTypeAuthentication)
        return;

    m_settings->removeStoreToKeychain();
    emit obtainingPasswordError(errorDescription);
}

void OnboardingController::onKeychainManagerSuccess(const QString& data)
{
    emit obtainingPasswordSuccess(data);
}

UserAccountsModel *OnboardingController::accounts()
{
    return &m_accounts;
}

NewAccountController *OnboardingController::initNewAccountController()
{
    m_newAccountController = std::make_unique<NewAccountController>(m_accountsService);
    emit newAccountControllerChanged();
    return m_newAccountController.get();
}

void OnboardingController::terminateNewAccountController()
{
    m_newAccountController.release()->deleteLater();
    emit newAccountControllerChanged();
}

NewAccountController *OnboardingController::newAccountController() const
{
    return m_newAccountController.get();
}

}
