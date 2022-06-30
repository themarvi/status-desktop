#pragma once

#include "OnboardingController.h"

#include <QObject>
#include <QtQmlIntegration>

namespace Status::Accounts {
    class Service;
}

namespace std::filesystem {
    class path;
}

namespace Accounts = Status::Accounts;

namespace Status::Onboarding {

/*!
 * \brief Provide bootstrap of controllers and corresponding services
 *
 * \note status-go is a stateful library and having multiple insteances of the same module is undefined behaviour
 *       hence the QML singleton
 * \todo current state is temporary until refactor StatusGo wrapper to match status-go requirements
 */
class OnboardingModule : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(OnboardingController* controller READ controller CONSTANT)

public:
    explicit OnboardingModule(const fs::path& userDataPath, QObject *parent = nullptr);

    /// Called by QML engine to register the instance. QML takes ownership of the instance
    static OnboardingModule *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    OnboardingController* controller() const;

private:

    void initWithUserDataPath(const fs::path &path);

    // TODO: plain object after refactoring shared_ptr requirement for now
    std::shared_ptr<Accounts::Service> m_accountsService;
    std::shared_ptr<OnboardingController> m_controller;
};

}
