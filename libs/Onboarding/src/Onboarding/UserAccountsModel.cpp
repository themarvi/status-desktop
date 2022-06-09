#include "UserAccountsModel.h"

#include "UserAccount.h"

#include <QObject>

namespace Status::Onboarding {


UserAccountsModel::UserAccountsModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

QHash<int, QByteArray> UserAccountsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[userAccount] = "userAccount";
    return roles;
}

int UserAccountsModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return m_items.size();
}

QVariant UserAccountsModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
        return QVariant();

    if(index.row() < 0 || index.row() > m_items.size())
        return QVariant();

    return QVariant::fromValue(m_items[index.row()].get());
}

}
