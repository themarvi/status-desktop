#pragma once

#include "ServiceInterface.h"
#include "KeychainManager.h"

// TODO: Status::Onboarding
namespace Status::Keychain
{


/*!
 * \brief The Service class
 *
 * \todo KeychainService
 */
class Service : public QObject,
        public ServiceInterface
{
    Q_OBJECT

public:
    explicit Service();

    void storePassword(const QString& username, const QString& password) override;

    void tryToObtainPassword(const QString& username) override;

    void subscribe(std::weak_ptr<Listener> listener) override;

private slots:
    void onKeychainManagerError(const QString& errorType, const int errorCode, const QString& errorDescription);
    void onKeychainManagerSuccess(const QString& data);

private:
    QVector<std::weak_ptr<Listener>> m_listeners;
    std::unique_ptr<KeychainManager> m_keychainManager;
};

}
