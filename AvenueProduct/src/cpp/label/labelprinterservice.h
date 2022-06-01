#ifndef LABELPRINTERSERVICE_H
#define LABELPRINTERSERVICE_H

#include <QObject>
#include <QSslError>

class QWebSocketServer;
class QWebSocket;
class QJsonObject;

namespace label
{

class LabelPrinter;

class LabelPrinterService : public QObject
{
    Q_OBJECT

private:
    LabelPrinter      &m_printer;
    QWebSocketServer  *m_pServer;

private:
    LabelPrinterService(const LabelPrinterService&);
    LabelPrinterService& operator=(const LabelPrinterService&);

    void setConfig(quint16 port, bool secured);

private slots:
    void onNewConnection();
    void onDisconnected();
    void onTextMessageReceived(const QString &message);
    void onBinaryMessageReceived(const QByteArray &message);
    void onSslErrors(const QList<QSslError> &errors);

public:
    explicit LabelPrinterService(LabelPrinter &printer, const QString &cfgPath, QObject *parent = nullptr);
    explicit LabelPrinterService(LabelPrinter &printer, const QJsonObject &cfg, QObject *parent = nullptr);
    ~LabelPrinterService();

signals:

public slots:
};


}    // namespace label


#endif // LABELPRINTERSERVICE_H
