#ifndef SCANNER_H
#define SCANNER_H

#include <QObject>
#include <QString>
#include <QByteArray>

#include "trans/l2empty.h"
#include "trans/serialclient.h"

namespace stand
{

class Scanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString data READ getData NOTIFY dataChanged)

private:
    QString m_data;
    trans::L2Empty m_lvl2;
    trans::SerialClient m_port;

private:
    Scanner(const Scanner&);
    Scanner& operator=(const Scanner&);

private slots:
    void onRcvData(const QByteArray &data);

public:
    explicit Scanner(QObject *parent = nullptr);
    ~Scanner();

signals:
    void dataChanged();

public slots:
    QString getData();
    void clearData();
    bool open(const QString &port, int speed);
    void close();

};


}    // namespace stand


#endif // SCANNER_H
