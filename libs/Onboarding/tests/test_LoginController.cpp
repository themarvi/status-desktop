#include "ServiceMock.h"

#include <Constants.h>
#include <LocalAccountsSettings.h>
#include <ServiceInterfaceTestData.h>

#include <IOTestHelpers.h>

#include <Core/Conversions.h>

#include <Onboarding/Accounts/Service.h>
#include <Onboarding/OnboardingController.h>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include <memory>

namespace Accounts = Status::Accounts;
namespace Onboarding = Status::Onboarding;

namespace fs = std::filesystem;

namespace Status::Testing {

class LoginTest : public ::testing::Test
{
protected:
    static std::shared_ptr<AccountsServiceMock> m_accountsServiceMock;
    // TODO: replace dummies with mocks
    //static std::shared_ptr<ServiceInterfaceMock> m_keychainServiceMock;
    //static std::shared_ptr<LocalAccountSettingsMock> m_settingsMock;

    static std::shared_ptr<ServiceInterfaceTestData> m_dummyKeychainService;
    static std::shared_ptr<LocalAccountsSettings> m_dummySettings;

    std::unique_ptr<Status::Accounts::Service> m_accountsService;
    std::unique_ptr<Testing::AutoCleanTempTestDir> m_fusedTestFolder;

    static void SetUpTestSuite() {
        m_accountsServiceMock = std::make_shared<AccountsServiceMock>();
        m_dummyKeychainService = std::make_shared<ServiceInterfaceTestData>(nullptr, nullptr, nullptr);
        m_dummySettings = std::make_shared<LocalAccountsSettings>(nullptr, nullptr, nullptr, nullptr, nullptr);
    }
    static void TearDownTestSuite() {
        m_accountsServiceMock.reset();
        m_dummyKeychainService.reset();
        m_dummySettings.reset();
    }

    void SetUp() override {
        m_fusedTestFolder = std::make_unique<Testing::AutoCleanTempTestDir>("LoginTest");
        m_accountsService = std::make_unique<Accounts::Service>();
        m_accountsService->init(m_fusedTestFolder->tempFolder() / Constants::statusGoDataDirName);
    }

    void TearDown() override {
        m_fusedTestFolder.release();
        m_accountsService.release();
    }
};

std::shared_ptr<AccountsServiceMock> LoginTest::m_accountsServiceMock;
std::shared_ptr<ServiceInterfaceTestData> LoginTest::m_dummyKeychainService;
std::shared_ptr<LocalAccountsSettings> LoginTest::m_dummySettings;

TEST_F(LoginTest, DISABLED_TestLoginController)
{
    // Controller hides as a regular class but at runtime it must be a shared pointer; TODO: refactor
    auto controller = std::make_shared<Onboarding::OnboardingController>(m_accountsServiceMock, m_dummyKeychainService, m_dummySettings);
}

} // namespace
