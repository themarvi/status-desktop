#pragma once

#include <Keychain/ServiceInterface.h>
#include <Onboarding/Accounts/LocalAccountSettings.h>

namespace Accounts = Status::Accounts;

namespace Status::Testing {

class LocalAccountsSettings: public Accounts::LocalAccountSettings
{
    using GetStoreToKeychainFn = std::function<Accounts::StoreToKeychainOptions ()>;
    using SetStoreToKeychainFn = std::function<void (const QString&)>;
    using RemoveStoreToKeychainFn = std::function<void ()>;
    using IsKeycardEnabledFn = std::function<QString ()>;
    using SetKeycardEnabledFn = std::function<void (bool)>;
public:
    LocalAccountsSettings( GetStoreToKeychainFn getStoreToKeychain,
                           SetStoreToKeychainFn setStoreToKeychain,
                           RemoveStoreToKeychainFn removeStoreToKeychain,
                           IsKeycardEnabledFn isKeycardEnabled,
                           SetKeycardEnabledFn setKeycardEnabled)
        : m_getStoreToKeychain(getStoreToKeychain)
        , m_setStoreToKeychain(setStoreToKeychain)
        , m_removeStoreToKeychain(removeStoreToKeychain)
        , m_isKeycardEnabled(isKeycardEnabled)
        , m_setKeycardEnabled(setKeycardEnabled)
    {}

    Accounts::StoreToKeychainOptions getStoreToKeychain() const override {
        return m_getStoreToKeychain();
    }
    void setStoreToKeychain(const QString& newVal) override {
        m_setStoreToKeychain(newVal);
    }
    void removeStoreToKeychain() override {
        m_removeStoreToKeychain();
    }
    QString isKeycardEnabled() const override {
        return m_isKeycardEnabled();
    }
    void setKeycardEnabled(bool enable) const override {
        m_setKeycardEnabled(enable);
    }

private:
    GetStoreToKeychainFn m_getStoreToKeychain;
    SetStoreToKeychainFn m_setStoreToKeychain;
    RemoveStoreToKeychainFn m_removeStoreToKeychain;
    IsKeycardEnabledFn m_isKeycardEnabled;
    SetKeycardEnabledFn m_setKeycardEnabled;
};



}
