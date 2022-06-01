#ifndef FILEMEDIALOADER_H
#define FILEMEDIALOADER_H

#include <QObject>
#include "imedialoader.h"

#include <QString>
#include <QStringList>
#include <QByteArray>
#include <QFileSystemWatcher>
#include <QTimer>

namespace config
{

class FileMediaLoader : public QObject, public IMediaLoader
{
    Q_OBJECT

private:
    const QString m_dirPath;                // path to dir with media files
    const MediaType m_type;
    QFileSystemWatcher m_watcher;
    QByteArray m_md5;
    int m_maxSize;
    bool m_notify;
    int m_bounce;

    QTimer m_timer;

private:
    QByteArray getMd5() const;

    FileMediaLoader(const FileMediaLoader&);
    FileMediaLoader& operator=(const FileMediaLoader&);

private slots:
    void notify();
    void onDirChanged(const QString &path);
    void onFileChanged(const QString &path);

public:
    explicit FileMediaLoader(const QString &path = "/conf/media/",
                             MediaType type = MediaType::TypeImage,
                             bool notify = true,
                             int bounce = 10000,
                             QObject *parent = 0);
    ~FileMediaLoader();

    // IMediaLoader implementation
    QByteArray getHash() const;
    QStringList getNames() const;
    QJsonDocument getInfoAsJson() const;
    QByteArray getElement(const QString &name) const;
    bool saveElement(const QString &name, const QByteArray &data);
    bool removeElement(const QString &name);
    void setNotifyBounce(int bounce);
    int getNotifyBounce() const;
    void notifyEnable();
    void notifyDisable();
    bool isNotifyEnabled() const;

signals:
    // IMediaLoader implementation
    void mediaChanged();

};


}    // namespace config


#endif // FILEMEDIALOADER_H
