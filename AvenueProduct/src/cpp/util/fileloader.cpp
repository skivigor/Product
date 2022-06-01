#include "fileloader.h"
#include <QFile>
#include <QDir>
#include <QUrl>
#include <QTextStream>
#include <QJsonParseError>
#include <QCryptographicHash>
#include <QCoreApplication>

#include <QDebug>
#include "assert.h"


namespace util
{

FileLoader::FileLoader(QObject *parent)
{
    Q_UNUSED(parent)
}

FileLoader::~FileLoader()
{
}

//-----------------------------------------------------------------

FileLoader &FileLoader::instance()
{
    static FileLoader ldr;
    return ldr;
}

//-----------------------------------------------------------------

bool FileLoader::isFileExists(const QString &path) const
{
    QFile file(path);
    if (file.exists()) return true;
    return false;
}

//-----------------------------------------------------------------

QStringList FileLoader::getFilesNameList(const QString &dirPath, QStringList filters)
{
    QDir dir(dirPath);
    dir.setNameFilters(filters);
    QStringList list = dir.entryList();

    qDebug() << "FileLoader::getFilesNameList: size: " << list.size();

    for (int i = 0; i < list.size(); ++i) qDebug() << "FileLoader::getFilesNameList: name: " << list.at(i);
    return list;

//    QStringList list = dir.entryInfoList(filters, QDir::Files|QDir::NoDotAndDotDot);
//    QStringList filters;
//     filters << "*.png" << "*.jpg" << "*.bmp";
    //     fileInfoList = dir.entryInfoList(filters, QDir::Files|QDir::NoDotAndDotDot);
}

//-----------------------------------------------------------------

QString FileLoader::getFileAsString(const QString &path)
{
    return QString(getFileAsBin(path));
}

//-----------------------------------------------------------------

QByteArray FileLoader::getFileAsBin(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
    {
        file.close();
        qWarning() << "FileLoader::getFileAsBin: Can not open " << path;
        return QByteArray();
    }
    QByteArray ba = file.readAll();
    file.close();

    return ba;
}

//-----------------------------------------------------------------

QJsonDocument FileLoader::getFileAsJsonDoc(const QString &path)
{
    QString str = getFileAsString(path);

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(str.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError)
    {
        qWarning() << "FileLoader::getFileAsJsonDoc: ERROR at " << path;
        return QJsonDocument();
    }

    return doc;
}

//-----------------------------------------------------------------

QJsonObject FileLoader::getJsonObject(const QString &path, const QString &chapter)
{
    QJsonDocument doc = getFileAsJsonDoc(path);
    QJsonObject jObj = doc.object();
    assert(jObj[chapter].isObject());

    return jObj.value(chapter).toObject();
}

//-----------------------------------------------------------------

QJsonArray FileLoader::getJsonArray(const QString &path, const QString &chapter)
{
    QJsonDocument doc = getFileAsJsonDoc(path);
    QJsonObject jObj = doc.object();
    assert(jObj[chapter].isArray());

    return jObj.value(chapter).toArray();
}

//-----------------------------------------------------------------

QStringList FileLoader::toStringList(const QList<QUrl> &list)
{
    return QUrl::toStringList(list, QUrl::PreferLocalFile);
}

//-----------------------------------------------------------------

bool FileLoader::saveFile(const QString &path, const QString &data) const
{
    qDebug() << "FileLoader::saveToFile: " << path;

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;

    QTextStream stream(&file);
    stream << data;
    file.close();

    return true;
}

//-----------------------------------------------------------------

bool FileLoader::saveFileAsJsonDoc(const QString &path, const QJsonObject &obj) const
{
    qDebug() << "FileLoader::saveFileAsJsonDoc: path: " << path;
//    QString path2 = QCoreApplication::applicationDirPath() + "/log/Info.json";
//    qDebug() << "FileLoader::saveFileAsJsonDoc: path2: " << path2;

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qDebug() << "Can not open file: " << path;
        return false;
    }

    QJsonDocument doc(obj);
    file.write(doc.toJson());
    file.close();

    return true;
}

//-----------------------------------------------------------------

bool FileLoader::loadFirmwareFile(const QString &filePath)
{
    qDebug() << "FileLoader::loadFirmwareFile: " << filePath;
    QByteArray data = getFileAsBin(QUrl(filePath).toLocalFile());
    if (data.isEmpty()) return false;
    QStringList list = filePath.split("/");
    m_fwName = list.last();

    // Md5 hash
    QByteArray md5 = QCryptographicHash::hash(data, QCryptographicHash::Md5);
    qDebug() << "FileLoader::loadFirmwareFile: Md5 hash: " << md5.toHex();
    m_fwMd5 = md5.toBase64();
//    qDebug() << "MD5 base64: " << m_fwMd5;
    m_fwFile = data.toBase64();

    emit fwNameChanged();
    emit fwMd5Changed();
    emit fwFileChanged();
    return true;
}


//-----------------------------------------------------------------

}    // namespace util

