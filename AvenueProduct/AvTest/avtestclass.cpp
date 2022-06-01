#include "avtestclass.h"
#include "util/fileloader.h"
#include <QCryptographicHash>
#include <QUrl>

#include <QDebug>

namespace avtest
{

AvTestClass::AvTestClass(QObject *parent)
    : m_fwName("Not selected")
{
    Q_UNUSED(parent)
}

AvTestClass::~AvTestClass()
{
}

//-----------------------------------------------------------------

void AvTestClass::show(const QString &base64)
{
    QByteArray ba = QByteArray::fromBase64(base64.toLocal8Bit());
    qDebug() << "AvTestClass::show: ba: " << ba.toHex();
}

//-----------------------------------------------------------------

void AvTestClass::file(const QString &file)
{
    QByteArray ba = QByteArray::fromBase64(file.toLocal8Bit());
    QByteArray md5 = QCryptographicHash::hash(ba, QCryptographicHash::Md5);

    qDebug() << "AvTestClass::file: md5: " << md5.toHex();

}

//-----------------------------------------------------------------

void AvTestClass::openFile(const QString &filePath)
{
    qDebug() << "File: " << filePath;
    QByteArray data = util::FileLoader::instance().getFileAsBin(QUrl(filePath).toLocalFile());
    QStringList list = filePath.split("/");
    m_fwName = list.last();

    // Md5 hash
    QByteArray md5 = QCryptographicHash::hash(data, QCryptographicHash::Md5);
    qDebug() << "Md5 hash: " << md5.toHex();
    m_fwMd5 = md5.toBase64();
    qDebug() << "MD5 base64: " << m_fwMd5;

    m_fwFile = data.toBase64();

    emit fwNameChanged();
    emit fwMd5Changed();
    emit fwFileChanged();
}

//-----------------------------------------------------------------

void AvTestClass::parseFile(const QString &md5, const QString &file)
{
    QByteArray rmd5 = QByteArray::fromBase64(md5.toLocal8Bit());
    qDebug() << "AvTestClass::parseFile: Received MD5: " << rmd5.toHex();

    QByteArray data = QByteArray::fromBase64(file.toLocal8Bit());
    QByteArray cmd5 = QCryptographicHash::hash(data, QCryptographicHash::Md5);
    qDebug() << "AvTestClass::parseFile: Calculated MD5: " << cmd5.toHex();
}

//-----------------------------------------------------------------

void AvTestClass::test()
{
    static int count = 0;
    qDebug() << "AvTestClass::test: count: " << count;
    count++;
}

//-----------------------------------------------------------------


}    // namespace avtest

