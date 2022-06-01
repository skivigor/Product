#ifndef ICONFIGLOADER_H
#define ICONFIGLOADER_H

#include <QVariant>
#include <QVariantList>
#include <QJsonDocument>
#include <QByteArray>

namespace config
{

enum DataType
{
    CFG_OBJECT,
    CFG_ARRAY
};

// Interface for all config loaders
class IConfigLoader
{
public:
    virtual ~IConfigLoader() {}

    virtual QVariantList getChapterAsVariantList(DataType type, const QString &chapter) const = 0;
    virtual QJsonDocument getChapterAsJsonDoc(DataType type, const QString &chapter) const = 0;

    virtual QVariant getAsVariant() const = 0;
    virtual QJsonDocument getAsJsonDoc() const = 0;
    virtual QByteArray getHash() const = 0;
    virtual bool saveConfig(const QJsonDocument &data) = 0;

    virtual void setNotifyBounce(int bounce) = 0;
    virtual int getNotifyBounce() const = 0;
    virtual void notifyEnable() = 0;
    virtual void notifyDisable() = 0;
    virtual bool isNotifyEnabled() const = 0;

signals:
    virtual void configChanged() = 0;

};


}    // namespace config


#endif // ICONFIGLOADER_H
