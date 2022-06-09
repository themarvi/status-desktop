#pragma once

#include "Onboarding/Accounts/ServiceInterface.h"

#include <gmock/gmock.h>

namespace Status::Testing
{

/*!
 * \brief The AccountsServiceMock test class
 *
 * \todo Consider if this is really neaded for testing controllers
 * \todo Move it to mocks subfolder
 */
class AccountsServiceMock final : public Accounts::ServiceInterface
{
public:
    virtual ~AccountsServiceMock() override {};

    MOCK_METHOD(bool, init, (const fs::path&), (override));
    MOCK_METHOD(QVector<Accounts::AccountDto>, openAndListAccounts, (), (override));
    MOCK_METHOD(const QVector<Accounts::GeneratedAccountDto>&, generatedAccounts, (), (const, override));
    MOCK_METHOD(bool, setupAccountAndLogin, (const QString&, const QString&, const QString&), (override));
    MOCK_METHOD(const Accounts::AccountDto&, getLoggedInAccount, (), (const, override));
    MOCK_METHOD(const Accounts::GeneratedAccountDto&, getImportedAccount, (), (const, override));
    MOCK_METHOD(bool, isFirstTimeAccountLogin, (), (const, override));
    MOCK_METHOD(bool, setKeyStoreDir, (const QString&), (override));
    MOCK_METHOD(QString, validateMnemonic, (const QString&), (override));
    MOCK_METHOD(bool, importMnemonic, (const QString&), (override));
    MOCK_METHOD(QString, login, (Accounts::AccountDto, const QString&), (override));
    MOCK_METHOD(void, clear, (), (override));
    MOCK_METHOD(QString, generateAlias, (const QString&), (override));
    MOCK_METHOD(QString, generateIdenticon, (const QString&), (override));
    MOCK_METHOD(bool, verifyAccountPassword, (const QString&, const QString&), (override));
};

}
