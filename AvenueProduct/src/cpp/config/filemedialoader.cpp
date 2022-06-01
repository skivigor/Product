#include "filemedialoader.h"

#include <QCoreApplication>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QDir>
#include <QDataStream>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <QDebug>
#include "assert.h"

namespace config
{

FileMediaLoader::FileMediaLoader(const QString &path,
                                 MediaType type,
                                 bool notify,
                                 int bounce,
                                 QObject *parent)
    : m_dirPath(QCoreApplication::applicationDirPath() + path),
      m_type(type),
      m_md5(0),
      m_maxSize(0),
      m_notify(notify),
      m_bounce(bounce)
{
    Q_UNUSED(parent);

    if (m_type == MediaType::TypeImage) m_maxSize = 200000;
    if (m_type == MediaType::TypeSound) m_maxSize = 5000000;
    if (m_type == MediaType::TypeVideo) m_maxSize = 10000000;

    QObject::connect(&m_watcher, SIGNAL(directoryChanged(QString)), this, SLOT(onDirChanged(QString)), Qt::QueuedConnection);
    QObject::connect(&m_watcher, SIGNAL(fileChanged(QString)), this, SLOT(onFileChanged(QString)), Qt::QueuedConnection);

    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(notify()), Qt::QueuedConnection);

    if (m_notify) m_watcher.addPath(m_dirPath);

    m_md5 = getMd5();

}

FileMediaLoader::~FileMediaLoader()
{
}


//--------------- private -----------------------------------------------


QByteArray FileMediaLoader::getMd5() const
{
    QStringList names = getNames();

    QByteArray ba;
    QDataStream stream(&ba, QIODevice::WriteOnly);

    for (int i = 0; i < names.size(); i++)
    {
        QFileInfo info(m_dirPath + "/" + names.at(i));

        if (info.size() <= m_maxSize) stream << info.size();
    }

    if (ba.isEmpty()) return QByteArray(0);

    return QCryptographicHash::hash(ba, QCryptographicHash::Md5);
}

//------------------------------------------------------------------------

void FileMediaLoader::notify()
{
    QByteArray md5 = getMd5();

    if (m_md5 != md5)
    {
        m_md5 = md5;
        emit mediaChanged();
        return;
    }
}

//------------------------------------------------------------------------

void FileMediaLoader::onDirChanged(const QString &path)
{
    qDebug() << "CHANGED DIRECTORY: " << path;

    if (m_timer.isActive()) m_timer.stop();
    m_timer.start(m_bounce);

}

//------------------------------------------------------------------------

void FileMediaLoader::onFileChanged(const QString &path)
{
    qDebug() << "CHANGED FILES: " << path;
}


//--------------- public -------------------------------------------------

void FileMediaLoader::setNotifyBounce(int bounce)
{
    m_bounce = bounce;
}

//------------------------------------------------------------------------

int FileMediaLoader::getNotifyBounce() const
{
    return m_bounce;
}

//------------------------------------------------------------------------

QByteArray FileMediaLoader::getHash() const
{
    return m_md5;
}

//------------------------------------------------------------------------

QStringList FileMediaLoader::getNames() const
{
    QDir dir(m_dirPath);

    if (m_type == MediaType::TypeImage)
    {
        dir.setNameFilters(QStringList() << "*.jpg");

    } else if (m_type == MediaType::TypeSound)
    {
        dir.setNameFilters(QStringList() << "*.wav");

    } else if (m_type == MediaType::TypeVideo)
    {
        dir.setNameFilters(QStringList() << "*.flv");

    } else
    {
        return QStringList();
    }

    QStringList names = dir.entryList();
    QStringList::iterator iter = names.begin();

    for (; iter != names.end(); iter++)
    {
        QFileInfo info(dir, *iter);
        if (info.size() > m_maxSize) names.erase(iter);
    }

    return names;

}

//------------------------------------------------------------------------

QJsonDocument FileMediaLoader::getInfoAsJson() const
{
    QStringList list = getNames();
    QJsonArray arr;

    for (int i = 0; i < list.size(); i++)
    {
        QFileInfo info(m_dirPath + list.at(i));

        QJsonObject obj;
        obj.insert("name", QJsonValue(list.at(i)));
        obj.insert("size", QJsonValue(info.size()));

        arr.append(obj);
    }

    QJsonDocument doc(arr);

    return doc;

}

//------------------------------------------------------------------------

QByteArray FileMediaLoader::getElement(const QString &name) const
{
    QFile file(m_dirPath + "/" + name);
    if (!file.exists() || file.size() > m_maxSize) return QByteArray(0);
    if (!file.open(QIODevice::ReadOnly)) return QByteArray(0);

    QByteArray ba = file.readAll();
    file.close();
    if (ba.isEmpty()) return QByteArray(0);

    return ba;

}

//------------------------------------------------------------------------

bool FileMediaLoader::saveElement(const QString &name, const QByteArray &data)
{
    assert(!data.isEmpty());
    assert(data.size() <= m_maxSize);

    m_watcher.removePath(m_dirPath);

    QFile file(m_dirPath + "/" + name);
    if (file.exists())
    {
        if (!file.remove())
        {
            if (m_notify) m_watcher.addPath(m_dirPath);
            m_md5 = getMd5();
            return false;
        }
    }

    if (!file.open(QIODevice::WriteOnly))
    {
        if (m_notify) m_watcher.addPath(m_dirPath);
        m_md5 = getMd5();
        return false;
    }

    if (file.write(data) < 0)
    {
        if (m_notify) m_watcher.addPath(m_dirPath);
        m_md5 = getMd5();
        return false;
    }

    file.waitForBytesWritten(100);
    file.close();

    m_md5 = getMd5();
    if (m_notify) m_watcher.addPath(m_dirPath);

    return true;

}

//------------------------------------------------------------------------

bool FileMediaLoader::removeElement(const QString &name)
{
    QFile file(m_dirPath + "/" + name);

    if (!file.exists()) return false;

    m_watcher.removePath(m_dirPath);

    if (!file.remove())
    {
        if (m_notify) m_watcher.addPath(m_dirPath);
        m_md5 = getMd5();
        return false;
    }

    if (m_notify) m_watcher.addPath(m_dirPath);
    m_md5 = getMd5();

    return true;

}

//------------------------------------------------------------------------

void FileMediaLoader::notifyEnable()
{
    if (m_notify) return;

    m_notify = true;
    m_watcher.addPath(m_dirPath);
}

//------------------------------------------------------------------------

void FileMediaLoader::notifyDisable()
{
    if (!m_notify) return;

    m_notify = false;
    m_watcher.removePath(m_dirPath);
}

//------------------------------------------------------------------------

bool FileMediaLoader::isNotifyEnabled() const
{
    return m_notify;
}


}    // namespace config


