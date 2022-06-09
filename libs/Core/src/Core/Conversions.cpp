#include "Conversions.h"

namespace fs = std::filesystem;

namespace Status {

QString convert(fs::path path) {
    return QString::fromStdString(path.string());
}

}
