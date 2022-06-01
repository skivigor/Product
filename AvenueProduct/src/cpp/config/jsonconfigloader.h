#ifndef JSONCONFIGLOADER_H
#define JSONCONFIGLOADER_H

#include <QObject>
#include "iconfigloader.h"

#include <QString>
#include <QByteArray>
#include <QFileSystemWatcher>
#include <QTimer>

namespace config
{

class JsonConfigLoader : public QObject, public IConfigLoader
{
    Q_OBJECT

private:
    const QString m_filePath;      // path to config file
    QFileSystemWatcher m_watcher;
    QByteArray m_md5;
    bool m_notify;
    int m_bounce;

    QTimer m_timer;

private:
    QByteArray getMd5() const;

    JsonConfigLoader(const JsonConfigLoader&);                 // disable copy constructor
    JsonConfigLoader& operator=(const JsonConfigLoader&);      // disable operator =

private slots:
    void notify();
    void onFileChanged(const QString &path);

public:
    explicit JsonConfigLoader(const QString &filePath,
                              bool notify = true,
                              int bounce = 10000,
                              QObject *parent = 0);
    ~JsonConfigLoader();

    // IConfigLoader implementation
    QVariantList getChapterAsVariantList(DataType type, const QString &chapter) const;
    QJsonDocument getChapterAsJsonDoc(DataType type, const QString &chapter) const;
    QVariant getAsVariant() const;
    QJsonDocument getAsJsonDoc() const;
    QByteArray getHash() const;
    bool saveConfig(const QJsonDocument &data);
    void setNotifyBounce(int bounce);
    int getNotifyBounce() const;
    void notifyEnable();
    void notifyDisable();
    bool isNotifyEnabled() const;

signals:
    // IConfigLoader implementation
    void configChanged();

};


}    // namespace config


#endif // JSONCONFIGLOADER_H
