#pragma once

#include <Keychain/ServiceInterface.h>
#include <Onboarding/Accounts/LocalAccountSettings.h>

namespace Accounts = Status::Accounts;

namespace Status::Testing {

class ServiceInterfaceTestData: public Keychain::ServiceInterface
{
    using StorePasswordFn = std::function<void (const QString&, const QString&)>;
    using TryToObtainPasswordFn = std::function<void (const QString&)>;
    using SubscribeFn = std::function<void (std::weak_ptr<Keychain::Listener>)>;
public:

    ServiceInterfaceTestData(StorePasswordFn storePassword,
                             TryToObtainPasswordFn tryToObtainPassword,
                             SubscribeFn subscribe)
        : m_storePassword(storePassword)
        , m_tryToObtainPassword(tryToObtainPassword)
        , m_subscribe(subscribe)
    {}

    void storePassword(const QString& username, const QString& password) {
        m_storePassword(username, password);
    };
    void tryToObtainPassword(const QString& username) {
        m_tryToObtainPassword(username);
    };
    void subscribe(std::weak_ptr<Keychain::Listener> listener) {
        m_subscribe(listener);
    };

private:
    StorePasswordFn m_storePassword;
    TryToObtainPasswordFn m_tryToObtainPassword;
    SubscribeFn m_subscribe;
};

}
