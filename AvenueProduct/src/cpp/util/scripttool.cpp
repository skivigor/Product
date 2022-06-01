#include "scripttool.h"
#include "util/bcddec.h"

#include "../lib/AvUtilsLib/include/avutilslib.h"

#include <QCoreApplication>
#include <QString>
#include <QDateTime>
#include <QtEndian>
#include <QCryptographicHash>
#include <QFile>
#include <QString>
#include <QProcess>

#include <QDebug>
#include "assert.h"

namespace
{

//QString GetRandomString()
//{
//   const QString possibleCharacters("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");
//   const int randomStringLength = 12; // assuming you want random strings of 12 characters

//   QString randomString;
//   for(int i = 0; i < randomStringLength; ++i)
//   {
//       int index = qrand() % possibleCharacters.length();
//       QChar nextChar = possibleCharacters.at(index);
//       randomString.append(nextChar);
//   }
//   return randomString;
//}

}   // namespace

namespace util
{

ScriptTool::ScriptTool(QObject *parent)
//    : m_loop(this)
{
    Q_UNUSED(parent)
    qsrand(QDateTime::currentMSecsSinceEpoch()%UINT_MAX);
}

ScriptTool::~ScriptTool()
{
}

//-----------------------------------------------------------------

void ScriptTool::wait(int ms)
{
    QTime dieTime = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < dieTime)
    {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
    }
}

//-----------------------------------------------------------------

QJsonObject ScriptTool::createVendorSettings(const QString &euiHex) const
{
    ::lib_avutils::AvUtilsLib lib;
    return lib.createVendorSettings(euiHex);
//    Q_UNUSED(euiHex)

//    QString vendorKey = QCryptographicHash::hash(GetRandomString().toLocal8Bit(), QCryptographicHash::Md5).toHex().toUpper();
//    QJsonObject obj;
//    obj.insert("key", vendorKey);

//    return obj;
}

//-----------------------------------------------------------------

QJsonObject ScriptTool::createLoraSettings(const QString &euiHex, const QString &appEui) const
{
    ::lib_avutils::AvUtilsLib lib;
    return lib.createLoraSettings(euiHex, appEui);
//    QString devEui = euiHex;
//    devEui.remove(QRegExp("[\r\n]"));

//    QString addr = devEui;
//    addr.remove(0, 10);
//    addr.prepend("01");
//    qDebug() << "Dev Addr: " << addr;

//    QString appEui("0018B250554C5331");

//    QString appKey = QCryptographicHash::hash(GetRandomString().toLocal8Bit(), QCryptographicHash::Md5).toHex().toUpper();
//    QString netSKey = QCryptographicHash::hash(GetRandomString().toLocal8Bit(), QCryptographicHash::Md5).toHex().toUpper();
//    QString appSKey = QCryptographicHash::hash(GetRandomString().toLocal8Bit(), QCryptographicHash::Md5).toHex().toUpper();

//    QJsonObject obj;
//    obj.insert("deveui", devEui);
//    obj.insert("devaddr", addr);
//    obj.insert("appeui", appEui);
//    obj.insert("appkey", appKey);
//    obj.insert("nwkskey", netSKey);
//    obj.insert("appskey", appSKey);

//    return obj;
}

//-----------------------------------------------------------------

QJsonObject ScriptTool::createWiFiSettings(const QString &euiHex) const
{
    ::lib_avutils::AvUtilsLib lib;
    return lib.createWiFiSettings(euiHex);

//    QString devEui = euiHex;
//    devEui.remove(QRegExp("[\r\n]"));

//    QString wifiSsid = "@L" + devEui;

//    QJsonObject obj;
//    obj.insert("WiFi_SSID", wifiSsid);
//    obj.insert("WiFi_Password", GetRandomString());
//    return obj;
}

//-----------------------------------------------------------------

std::vector<int> ScriptTool::createSerialNumber(const QString devId) const
{
    QString str = devId;
    str.remove(QRegExp("[a-zA-Z]"));
    str = QString("%1").arg(str, 16, QLatin1Char('0'));
    assert(str.size() == 16);

    QByteArray ba = QByteArray::fromHex(str.toLocal8Bit());
    qDebug() << "ScriptTool::createSerialNumber: " << devId << " to: " << ba.toHex();

    std::vector<int> vec(ba.begin(), ba.end());
    return vec;
}

//-----------------------------------------------------------------

std::vector<int> ScriptTool::createHwVersion(const QString &ver) const
{
    QString str = ver;
    str.remove(QRegExp("[\r\n]"));
    str = QString("%1").arg(str, 8, QLatin1Char('0'));
    assert(str.size() == 8);

    QByteArray ba(str.toLocal8Bit());
    std::vector<int> vec(ba.begin(), ba.end());
    return vec;
}

//-----------------------------------------------------------------

int ScriptTool::arrayToInt(const QByteArray &data, int pos, int size) const
{
    int val = 0;
    memcpy(&val, data.data() + pos, static_cast<size_t>(size));
    return val;
}

//-----------------------------------------------------------------

std::vector<int> ScriptTool::intToArray(int value, int size) const
{
    QByteArray ba;
    ba.append((const char *)&value, size);
    std::vector<int> vec(ba.begin(), ba.end());
    return vec;
}

//-----------------------------------------------------------------

quint32 ScriptTool::utcDateTimeToOffset() const
{
    QDateTime dt = QDateTime::currentDateTimeUtc();
    QDate d = dt.date();
    quint8 date = static_cast<quint8>(d.day());
    quint8 month = static_cast<quint8>(d.month());
    quint8 year = static_cast<quint8>(d.year() - 2000);

    QTime t = dt.time();
    quint8 hour = static_cast<quint8>(t.hour());
    quint8 min = static_cast<quint8>(t.minute());
    quint8 sec = static_cast<quint8>(t.second());
    qint8 tz = static_cast<qint8>(QDateTime::currentDateTime().offsetFromUtc() / 3600);
    if (dt.isDaylightTime()) tz--;

    quint32 a, y, m, j;
    a = (14 - month) / 12L;
    y = (quint32)year + 6800L - a;
    m = (quint32)month + (12 * a) - 3;
    // julian days since Jan 1, 2000; 5.8e6 years range in 32-bit signed no.
    j = (quint32)date
            + (((153 * m) + 2)/5)
            + (365 * y)
            + (y / 4)
            - (y / 100)
            + (y / 400)
            - 2483590;
    //    #if 1
    // julian seconds... 68 years range in a 32-bit signed number
    j = (j * 86400)
            + (((quint32)hour - 12) * 3600)
            + ((quint32)min * 60)
            + (quint32)sec
            + 43200L;
    return j;
}

//-----------------------------------------------------------------

void ScriptTool::utcDateTimeFromOffset(quint32 offset) const
{
    quint32 jd, w, x, a, b, c, d, e, f, month;
    quint8 dayWeek, hour, min, sec, date, mon, year;
    sec = offset % 60;
    min = (offset / 60) % 60;
    hour = (offset / 3600) % 24;
    jd = (offset / 86400L) + 2451545L; // jd = julian days

    // Calculate day of week: 1 = Sunday
    dayWeek = ((jd + 1) % 7) + 1; // January 1, 2000 was saturday
    dayWeek--;
    if (dayWeek <= 0) dayWeek = 7;

    // In standard calculation w = int((jd - 1867216.25)/36524.25);
    w = ((4L * jd) - 7468865L) / 146097L;
    x = w / 4L;
    a = (jd + w + 1L) - x;
    b = a + 1524L;

    // In standard calculation c = int((b - 122.1) / 365.25);
    c = ((20L * b) - 2442L) / 7305L;

    // In standard calculation d = int(c * 365.25);
    d = (c * 1461L) / 4;

    // In standard calculation e = int((b - d)/30.6001);
    e = ((b - d) * 10000L)/306001L; // b - d is a few hundred, so no overflow
    f = (306001L * e)/10000L; // e is less than 25, so no overflow
    date = (b - d) - f;
    month = (e < 14) ? (e - 1) : (e - 13);
    mon = month;
    year = ((month < 3) ? (c - 4715) : (c - 4716)) - 2000L;

    qDebug() << "UTC date: " << date << "." << mon << "." << year;
    qDebug() << "UTC time: " << hour << "." << min << "." << sec;
}

//-----------------------------------------------------------------

std::vector<int> ScriptTool::getProductScopeCommand(const QString &vendorKey) const
{
    qDebug() << "ScriptTool::getProductScopeCommand: VK: " << vendorKey;

    QDate d = QDate::currentDate();
    quint8 date = static_cast<quint8>(d.day());
    quint8 month = static_cast<quint8>(d.month());
    quint8 year = static_cast<quint8>(d.year() - 2000);

    QByteArray ba = QByteArray::fromHex(vendorKey.toLatin1());
    ba.append(static_cast<char>(util::ByteToBcd2(date)));
    ba.append(static_cast<char>(util::ByteToBcd2(month)));
    ba.append(static_cast<char>(util::ByteToBcd2(year)));
    qDebug() << "ScriptTool::getProductScopeCommand: Cmd to hash: " << ba.toHex();

    QByteArray md5 = QCryptographicHash::hash(ba, QCryptographicHash::Md5);
    std::vector<int> vec(md5.begin(), md5.end());
    return vec;
}

//-----------------------------------------------------------------

QString ScriptTool::runShellScript(const QString &path, const QStringList &args) const
{
    QProcess proc;
    QStringList sh;
    sh << path;
    sh << args;
    proc.start("sh", sh);
    proc.waitForFinished();

    QString out = proc.readAllStandardOutput();
    qDebug() << "ScriptTool::runShellScript: " << out;
    return out;
}

//-----------------------------------------------------------------

}    // namespace util

