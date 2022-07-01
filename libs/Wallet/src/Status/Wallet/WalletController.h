#pragma once

#include <QtQmlIntegration>

namespace Status::Wallet {
    
class WalletController: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    WalletController();
    ~WalletController();

        /// Called by QML engine to register the instance. QML takes ownership of the instance
    static OnboardingController *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
};

} // namespace Status::Wallet