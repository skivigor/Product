#include "jsonconfigloader.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>
#include <QCryptographicHash>

#include <QDebug>
#include "utils/baseexception.h"
#include <assert.h>


namespace
{

QJsonDocument readConfig(QFile &file)
{
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        ess::BaseException e(__FILE__,
                             __PRETTY_FUNCTION__,
                             __LINE__,
                             QString("Can not open file: " + file.fileName()).toStdString());
        throw e;
    }

    QString str = file.readAll();
    file.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(str.toUtf8(), &err);

    if (err.error != QJsonParseError::NoError)
    {
        ess::BaseException e(__FILE__,
                             __PRETTY_FUNCTION__,
                             __LINE__,
                             QString("Error in config file" + file.fileName()).toStdString());
        throw e;
    }

    return doc;
}

}   // namespace


//-------------------------------------------------

namespace config
{

JsonConfigLoader::JsonConfigLoader(const QString &filePath,
                                   bool notify,
                                   int bounce,
                                   QObject *parent)
    : m_filePath(filePath),
      m_md5(0),
      m_notify(notify),
      m_bounce(bounce)
{
    Q_UNUSED(parent);

    QObject::connect(&m_watcher, SIGNAL(fileChanged(QString)), this, SLOT(onFileChanged(QString)), Qt::QueuedConnection);

    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(notify()), Qt::QueuedConnection);

    if (m_notify) m_watcher.addPath(m_filePath);

    m_md5 = getMd5();

}

JsonConfigLoader::~JsonConfigLoader()
{
}


//-------- private ----------------------------------------------

QByteArray JsonConfigLoader::getMd5() const
{
    QFile file;
    file.setFileName(m_filePath);

    QJsonDocument doc;

    try
    {
        doc = readConfig(file);
    }

    catch (ess::BaseException &e)
    {
        qDebug() << e.what();
        qFatal("Crash of application");
    }

    return QCryptographicHash::hash(doc.toBinaryData(), QCryptographicHash::Md5);
}

//---------------------------------------------------------------

void JsonConfigLoader::notify()
{
    QByteArray md5 = getMd5();

    if (m_md5 != md5)
    {
        m_md5 = md5;
        emit configChanged();
    }
}

//---------------------------------------------------------------

void JsonConfigLoader::onFileChanged(const QString &path)
{
    qDebug() << "CHANGED CONFIG: " << path;

    if (m_timer.isActive()) m_timer.stop();
    m_timer.start(m_bounce);
}

//-------- public ----------------------------------------------

QVariantList JsonConfigLoader::getChapterAsVariantList(DataType type, const QString &chapter) const         // can throw ess::BaseException
{
    QVariantList data;

    QFile file;
    file.setFileName(m_filePath);

    QJsonDocument cfg;

    try
    {
        cfg = readConfig(file);
    }

    catch (ess::BaseException &e)
    {
        qDebug() << e.what();
        qFatal("Crash of application");
    }

    QJsonObject jObject = cfg.object();

    if (type == DataType::CFG_ARRAY)
    {
        assert(jObject[chapter].isArray());

        return jObject[chapter].toArray().toVariantList();
    }

    if (type == DataType::CFG_OBJECT)
    {
        assert(jObject[chapter].isObject());

        QVariantMap map = jObject[chapter].toObject().toVariantMap();
        data.append(map);

        return data;
    }

    return data;

}

//---------------------------------------------------------------

QJsonDocument JsonConfigLoader::getChapterAsJsonDoc(DataType type, const QString &chapter) const
{
    QFile file;
    file.setFileName(m_filePath);

    QJsonDocument cfg;

    try
    {
        cfg = readConfig(file);
    }

    catch (ess::BaseException &e)
    {
        qDebug() << e.what();
        qFatal("Crash of application");
    }

    QJsonObject jObject = cfg.object();

    if (type == DataType::CFG_ARRAY)
    {
        assert(jObject[chapter].isArray());

        return QJsonDocument(jObject[chapter].toArray());
    }

    if (type == DataType::CFG_OBJECT)
    {
        assert(jObject[chapter].isObject());

        return QJsonDocument(jObject[chapter].toObject());

    }

    return QJsonDocument();

}

//---------------------------------------------------------------

QVariant JsonConfigLoader::getAsVariant() const
{

    QFile file;
    file.setFileName(m_filePath);

    QJsonDocument doc;

    try
    {
        doc = readConfig(file);
    }

    catch (ess::BaseException &e)
    {
        qDebug() << e.what();
        qFatal("Crash of application");
    }

    return doc.toVariant();
}

//---------------------------------------------------------------

QJsonDocument JsonConfigLoader::getAsJsonDoc() const
{
    QFile file;
    file.setFileName(m_filePath);

    QJsonDocument doc;

    try
    {
        doc = readConfig(file);
    }

    catch (ess::BaseException &e)
    {
        qDebug() << e.what();
        qFatal("Crash of application");
    }

    return doc;

}

//---------------------------------------------------------------

QByteArray JsonConfigLoader::getHash() const
{
    return m_md5;
}

//---------------------------------------------------------------

bool JsonConfigLoader::saveConfig(const QJsonDocument &data)
{
    assert(!data.isEmpty());
    //if (data.isEmpty()) return false;

    m_watcher.removePath(m_filePath);

    QFile file(m_filePath);

    if (!file.open(QIODevice::ReadWrite | QIODevice::Truncate))
    {
        m_md5 = getMd5();
        if (m_notify) m_watcher.addPath(m_filePath);
        return false;
    }

    if (file.write(data.toJson()) < 0)
    {
        m_md5 = getMd5();
        if (m_notify) m_watcher.addPath(m_filePath);
        return false;
    }

    file.waitForBytesWritten(100);
    file.close();

    m_md5 = getMd5();
    if (m_notify) m_watcher.addPath(m_filePath);

    return true;
}

//---------------------------------------------------------------

void JsonConfigLoader::setNotifyBounce(int bounce)
{
    m_bounce = bounce;
}

//---------------------------------------------------------------

int JsonConfigLoader::getNotifyBounce() const
{
    return m_bounce;
}

//---------------------------------------------------------------

void JsonConfigLoader::notifyEnable()
{
    if (m_notify) return;

    m_notify = true;
    m_watcher.addPath(m_filePath);
}

//---------------------------------------------------------------

void JsonConfigLoader::notifyDisable()
{
    if (!m_notify) return;

    m_notify = false;
    m_watcher.removePath(m_filePath);
}

//---------------------------------------------------------------

bool JsonConfigLoader::isNotifyEnabled() const
{
    return m_notify;
}


}    // namespace config

