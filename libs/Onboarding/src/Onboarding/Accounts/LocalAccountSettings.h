#pragma once

#include <QSettings>

namespace Status::Accounts
{

enum StoreToKeychainOptions
{
    Store,
    NotNow,
    Never
};

static StoreToKeychainOptions kStoreToKeychainOptionsDefault = NotNow;
static bool isKeycardEnabledDefault = false;

class LocalAccountSettings
{
public:
    virtual StoreToKeychainOptions getStoreToKeychain() const = 0;
    virtual void setStoreToKeychain(const QString& newVal) = 0;
    virtual void removeStoreToKeychain() = 0;
    virtual QString isKeycardEnabled() const = 0;
    virtual void setKeycardEnabled(bool enable) const = 0;
};

}
