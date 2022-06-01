#ifndef SCRIPTTOOL_H
#define SCRIPTTOOL_H

#include <QObject>
#include <QJsonObject>
#include <vector>

namespace util
{

class ScriptTool : public QObject
{
    Q_OBJECT

private:
    ScriptTool(const ScriptTool&);
    ScriptTool& operator=(const ScriptTool&);

public:
    explicit ScriptTool(QObject *parent = nullptr);
    ~ScriptTool();

signals:

public slots:
    void wait(int ms);
    QJsonObject createVendorSettings(const QString &euiHex) const;
    QJsonObject createLoraSettings(const QString &euiHex, const QString &appEui = "0018B250554C5331") const;
    QJsonObject createWiFiSettings(const QString &euiHex) const;
    std::vector<int> createSerialNumber(const QString devId) const;
    std::vector<int> createHwVersion(const QString &ver) const;

    int arrayToInt(const QByteArray &data, int pos, int size) const;
    std::vector<int> intToArray(int value, int size) const;

    quint32 utcDateTimeToOffset() const;
    void utcDateTimeFromOffset(quint32 offset) const;

    std::vector<int> getProductScopeCommand(const QString &vendorKey) const;

    QString runShellScript(const QString &path, const QStringList &args) const;

};


}    // namespace util


#endif // SCRIPTTOOL_H
