#ifndef AVUTILSLIB_H
#define AVUTILSLIB_H

#include <QJsonObject>

namespace lib_avutils
{

class AvUtilsLib
{
public:
    AvUtilsLib();

    QJsonObject createVendorSettings(const QString &euiHex) const;
    QJsonObject createLoraSettings(const QString &euiHex, const QString &appEui = "0018B250554C5331") const;
    QJsonObject createWiFiSettings(const QString &euiHex) const;
};


}    // namespace lib_avutils


#endif // AVUTILSLIB_H
