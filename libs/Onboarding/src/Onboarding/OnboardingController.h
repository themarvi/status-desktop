#pragma once

#include "UserAccountsModel.h"

#include "Accounts/ServiceInterface.h"
#include "Keychain/ServiceInterface.h"
#include "Accounts/AccountDto.h"

#include <QQmlEngine>
#include <QtQmlIntegration>

#include <memory>

namespace Status::Accounts {
    class LocalAccountSettings;
}

namespace Status::Onboarding
{

class NewAccountController;

/*!
 * \todo refactor and remove the requirement to build only shared_ptr instances or use a factory
 * \todo refactor unnedded multiple inheritance
 * \todo don't use DTOs in controllers, use QObjects directly
 * \todo make dependency on SignalManager explicit. Now it is hidden.
 */
class OnboardingController final : public QObject
        , public Keychain::Listener
        , public std::enable_shared_from_this<OnboardingController>
{
    Q_OBJECT

    QML_ELEMENT
    QML_UNCREATABLE("Created by Module, for now")

    Q_PROPERTY(UserAccountsModel* accounts READ accounts CONSTANT)
    Q_PROPERTY(NewAccountController* newAccountController READ newAccountController NOTIFY newAccountControllerChanged)

public:
    explicit OnboardingController(std::shared_ptr<Accounts::ServiceInterface> accountsService,
                        std::shared_ptr<Keychain::ServiceInterface> keychainService,
                        std::shared_ptr<Accounts::LocalAccountSettings> settings);
    ~OnboardingController();

    /// Retrieve available accounts
    QVector<Accounts::AccountDto> getOpenedAccounts() const;

    /// Select active account id
    /// \todo use UserAccount
    Q_INVOKABLE void setSelectedAccountKeyUid(const QString& keyUid);

    /// Login active user account
    Q_INVOKABLE void login(const QString& password);

    // Keychain::Listener Interface
    void onKeychainManagerError(const QString& errorType, const int errorCode,
                                const QString& errorDescription) override;
    void onKeychainManagerSuccess(const QString& data) override;

    UserAccountsModel *accounts();

    Q_INVOKABLE NewAccountController *initNewAccountController();
    Q_INVOKABLE void terminateNewAccountController();
    NewAccountController *newAccountController() const;

signals:
    void accountLoggedIn();
    void accountLoginError(const QString& error);
    void obtainingPasswordError(const QString& errorDescription);
    void obtainingPasswordSuccess(const QString& password);

    void newAccountControllerChanged();

private slots:
    void onLogin(const QString& error);

private:
    Accounts::AccountDto getSelectedAccount() const;

private:
    std::shared_ptr<Accounts::ServiceInterface> m_accountsService;
    std::shared_ptr<Keychain::ServiceInterface> m_keychainService;
    std::shared_ptr<Accounts::LocalAccountSettings> m_settings;
    QString m_selectedAccountKeyUid;
    UserAccountsModel m_accounts;

    std::unique_ptr<NewAccountController> m_newAccountController;
};

}
