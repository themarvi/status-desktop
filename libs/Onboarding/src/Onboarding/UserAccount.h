#pragma once

#include <QtQmlIntegration>

namespace Status::Accounts {
    class AccountDto;
}
namespace Accounts = Status::Accounts;

namespace Status::Onboarding
{

/*!
 * \brief Represents a user account in Onboarding Presentation Layer
 *
 * @see OnboardingController
 * @see UserAccountsModel
 */
class UserAccount: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Created by Controller")

    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
public:

    const QString &name() const;

    const Accounts::AccountDto& accountData() const;
    void updateAccountData(const Accounts::AccountDto& newData);

signals:
    void nameChanged();

private:
    std::unique_ptr<Accounts::AccountDto> m_data;
};

}
