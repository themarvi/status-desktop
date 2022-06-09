#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>

namespace Status::Onboarding {

class UserAccount;

/*!
 * \brief Available UserAccount elements
 */
class UserAccountsModel : public QAbstractListModel
{
    Q_OBJECT

    QML_ELEMENT
    QML_UNCREATABLE("Created by OnboardingController")

    enum ModelRole {
        userAccount = Qt::UserRole + 1
    };
public:

    explicit UserAccountsModel(QObject* parent = nullptr);
    QHash<int, QByteArray> roleNames() const override;
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

private:
    std::vector<std::shared_ptr<UserAccount>> m_items;
};

}
