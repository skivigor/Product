#ifndef AvScanner_H
#define AvScanner_H

#include <QObject>
#include <QSerialPort>
#include <QString>
#include <QByteArray>

#include "trans/l2empty.h"
#include "trans/serialclient.h"

namespace scan
{

class AvScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString data READ getData NOTIFY dataChanged)

private:
    QString m_data;
    QSerialPort    m_port;
//    trans::L2Empty m_lvl2;
//    trans::SerialClient m_port;

private:
    AvScanner(const AvScanner&);
    AvScanner& operator=(const AvScanner&);

private slots:
    void onReadyRead();
    void onError(QSerialPort::SerialPortError error);

public:
    explicit AvScanner(QObject *parent = nullptr);
    ~AvScanner();

signals:
    void dataChanged();

public slots:
    QString getData();
    void clearData();
    void close();

    bool open(const QString &portName, int baudRate, const QString &parity,
                 const QString &stopBits, const QString &flowCtrl);
    bool open(const QString &portName, int baudRate);

};


}    // namespace scan


#endif // AvScanner_H
