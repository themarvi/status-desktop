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
 * \brief Workaround until refactoring OnboardingController to a QML instantiable type
 */
class OnboardingModule : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(OnboardingController* controller READ controller CONSTANT)

public:
    explicit OnboardingModule(QObject *parent = nullptr);

    OnboardingController* controller() const;

private:

    void initWithUserDataPath(const fs::path &path);

    // TODO: plain object after refactoring shared_ptr requirement for now
    std::shared_ptr<Accounts::Service> m_accountsService;
    std::shared_ptr<OnboardingController> m_controller;
};

}
