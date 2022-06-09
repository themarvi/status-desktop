#pragma once

#include "ServiceInterface.h"

// TODO: Status::Onboarding
namespace Status::Accounts
{

/*!
 * \brief The Service class
 *
 * \todo Refactor static dependencies
 *      :/resources/default-networks.json
 *      :/resources/node-config.json
 *      :/resources/fleets.json
 *      :/resources/infura_key
 * \todo AccountsService
 */
class Service : public ServiceInterface
{
public:
    Service();

    /// \see ServiceInterface
    bool init(const fs::path& statusgoDataDir) override;

    /// \see ServiceInterface
    [[nodiscard]] QVector<AccountDto> openAndListAccounts() override;

    /// \see ServiceInterface
    [[nodiscard]] const QVector<GeneratedAccountDto>& generatedAccounts() const override;

    /// \see ServiceInterface
    bool setupAccountAndLogin(const QString& accountId, const QString& password, const QString& displayName) override;

    /// \see ServiceInterface
    [[nodiscard]] const AccountDto& getLoggedInAccount() const override;

    [[nodiscard]] const GeneratedAccountDto& getImportedAccount() const override;

    /// \see ServiceInterface
    [[nodiscard]] bool isFirstTimeAccountLogin() const override;

    /// \see ServiceInterface
    bool setKeyStoreDir(const QString &key) override;

    QString validateMnemonic(const QString& mnemonic) override;

    bool importMnemonic(const QString& mnemonic) override;

    QString login(AccountDto account, const QString& password) override;

    void clear() override;

    QString generateAlias(const QString& publicKey) override;

    QString generateIdenticon(const QString& publicKey) override;

    // TODO: implementation
    bool verifyAccountPassword(const QString& account, const QString& password) override { return false; };

private:
    QJsonObject prepareAccountJsonObject(const GeneratedAccountDto& account, const QString& displayName) const;

    DerivedAccounts storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                         const QVector<QString>& paths);
    StoredAccountDto storeAccount(const QString& accountId, const QString& hashedPassword);

    AccountDto saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                   const QJsonArray& subaccounts, const QJsonObject& settings,
                                   const QJsonObject& config);

    QJsonObject getAccountDataForAccountId(const QString& accountId, const QString& displayName) const;

    QJsonArray prepareSubaccountJsonObject(const GeneratedAccountDto& account, const QString& displayName) const;

    QJsonArray getSubaccountDataForAccountId(const QString& accountId, const QString& displayName) const;

    QString generateSigningPhrase(const int count) const;

    QJsonObject prepareAccountSettingsJsonObject(const GeneratedAccountDto& account,
                                                 const QString& installationId,
                                                 const QString& displayName) const;

    QJsonObject getAccountSettings(const QString& accountId, const QString& installationId, const QString& displayName) const;

    QJsonObject getDefaultNodeConfig(const QString& installationId) const;

private:
    QVector<GeneratedAccountDto> m_generatedAccounts;

    fs::path m_statusgoDataDir;
    bool m_isFirstTimeAccountLogin;
    AccountDto m_loggedInAccount;
    GeneratedAccountDto m_importedAccount;

    // Here for now. Extract them if used by other services
    static constexpr auto m_keyStoreDirName = "keystore";
};

}
