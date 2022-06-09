#pragma once

#include <string>
#include <filesystem>

class QCoreApplication;

namespace Status::Onboarding {
    class OnboardingController;
}

namespace Status::Testing {

class AutoCleanTempTestDir;

class ScopedTestAccount final {
public:
    /*!
     * \brief Create and logs in a new test account
     * \param tempTestSubfolderName subfolder name of the temporary test folder where to initalize user data \see AutoCleanTempTestDir
     * \todo make it more flexible by splitting into create account, login and wait for events
     */
    explicit ScopedTestAccount(const std::string &tempTestSubfolderName);
    ~ScopedTestAccount();

    void processMessages(size_t millis, std::function<bool()> shouldWaitUntilTimeout);

    Status::Onboarding::OnboardingController* onboardingController() const;
private:
    std::unique_ptr<AutoCleanTempTestDir> m_fusedTestFolder;
    std::unique_ptr<QCoreApplication> m_app;
    std::filesystem::path m_testFolderPath;
    std::shared_ptr<Status::Onboarding::OnboardingController> m_onboarding;
    std::function<bool()> m_checkIfShouldContinue;
};

}
