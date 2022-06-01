#ifndef IMEDIALOADER_H
#define IMEDIALOADER_H

#include <QString>
#include <QStringList>
#include <QByteArray>
#include <QJsonDocument>

namespace config
{

enum MediaType
{
    TypeImage,
    TypeSound,
    TypeVideo
};

class IMediaLoader
{
public:
    virtual ~IMediaLoader() {}

    virtual QByteArray getHash() const = 0;
    virtual QStringList getNames() const = 0;
    virtual QJsonDocument getInfoAsJson() const = 0;
    virtual QByteArray getElement(const QString &name) const = 0;
    virtual bool saveElement(const QString &name, const QByteArray &data) = 0;
    virtual bool removeElement(const QString &name) = 0;

    virtual void setNotifyBounce(int bounce) = 0;
    virtual int getNotifyBounce() const = 0;
    virtual void notifyEnable() = 0;
    virtual void notifyDisable() = 0;
    virtual bool isNotifyEnabled() const = 0;

signals:
    virtual void mediaChanged() = 0;

};

}   // namespace config


#endif // IMEDIALOADER_H

